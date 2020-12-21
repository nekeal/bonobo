from unittest import mock

import pytest

from bonobo.shops.entities import GeocodedPlace
from bonobo.shops.factories import ShopFactory
from bonobo.shops.services import GeocodingUrlParser, ShopGeocodingService


class TestGeocodingUrlParser:
    @pytest.mark.parametrize(
        "url,expected_lat,expected_long,expected_place",
        (
            (
                "https://www.google.com/maps/place/Navigare+Yacht+Club/@50.0985528,19.9722389,17.59z/",
                50.0985528,
                19.9722389,
                "Navigare Yacht Club",
            ),
            (
                "https://www.google.com/maps/place/Eiffel+Tower/@48.8569014,2.2901011,16.21z/",
                48.8569014,
                2.2901011,
                "Eiffel Tower",
            ),
        ),
    )
    def test_parse_valid_url(self, url, expected_lat, expected_long, expected_place):
        service = GeocodingUrlParser(url)
        result = service.parse()

        assert result == GeocodedPlace(expected_lat, expected_long, expected_place)


class TestShopGeocodingService:
    def setup_method(self, method):
        self.maps_url = "https://www.google.com/maps/place/Bonobo+Shop/@10,10,17.59z/"
        self.shop = ShopFactory.build(maps_url=self.maps_url)
        self.service = ShopGeocodingService(self.shop, save=False)

    def test_get_geocoded_place(self, monkeypatch, maps_url, geocoded_place):
        shop = ShopFactory.build(maps_url=maps_url)
        service = ShopGeocodingService(shop, save=False)
        parsed_geocoded_place = service.get_geocoded_place()

        assert parsed_geocoded_place == geocoded_place

    @pytest.mark.parametrize(
        "maps_url",
        (
            "",
            "https://google.com/wrong/url",
        ),
    )
    def test_shop_is_not_updated_with_wrong_url(self, monkeypatch, maps_url):
        print(maps_url)
        self.shop.maps_url = maps_url
        m_update_with_geocoded_place = mock.Mock(return_value=None)
        shop, updated = self.service.run()
        assert not updated
        assert not m_update_with_geocoded_place.call_count

    def test_shop_is_updated_with_valid_url(self, geocoded_place):
        shop, updated = self.service.run()
        assert updated
        assert (
            GeocodedPlace(shop.location.x, shop.location.y, shop.place_name)
            == geocoded_place
        )

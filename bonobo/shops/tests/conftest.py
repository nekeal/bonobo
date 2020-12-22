import pytest
from django.contrib.gis.gdal.geometries import Point

from bonobo.shops.entities import GeocodedPlace
from bonobo.shops.factories import ShopFactory


@pytest.fixture
def maps_url():
    return "https://www.google.com/maps/place/Bonobo+Shop/@10,10,17.59z/"


@pytest.fixture
def geocoded_place():
    return GeocodedPlace(10, 10, "Bonobo Shop")


@pytest.fixture
def shop(db, maps_url):
    return ShopFactory(
        maps_url=maps_url,
        slug="bonobo-shop",
        place_name="Bonobo Shop",
        location=Point(10, 10),
    )

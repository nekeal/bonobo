import re
import urllib.parse
from typing import Optional, Tuple

from bonobo.shops.entities import GeocodedPlace
from bonobo.shops.models import Shop


class GeocodingUrlParser:
    def __init__(self, url) -> None:
        self.url = url

    def parse(self) -> Optional[GeocodedPlace]:
        place_re = re.search(r"place/(.+)/@(.+),(.+),(.+)/", self.url)
        if not place_re:
            return None
        lat = float(place_re.group(2))
        long = float(place_re.group(3))
        place = urllib.parse.unquote(place_re.group(1).replace("+", " "))
        return GeocodedPlace(lat, long, place)


class ShopGeocodingService:
    def __init__(self, shop: Shop, save=True):
        self.shop = shop
        self.save = save

    def get_geocoded_place(self) -> Optional[GeocodedPlace]:
        print(self.shop.maps_url)
        return GeocodingUrlParser(self.shop.maps_url).parse()

    def run(self) -> Tuple[Shop, bool]:
        if not self.shop.maps_url:
            return self.shop, False

        geocoded_place = self.get_geocoded_place()
        if not geocoded_place:
            return self.shop, False
        self.shop.update_with_geocoded_place(geocoded_place, save=self.save)
        return self.shop, True

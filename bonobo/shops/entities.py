from dataclasses import dataclass

from dataclasses_json.api import dataclass_json
from django.contrib.gis.geos.point import Point


@dataclass_json
@dataclass
class GeocodedPlace:
    latitude: float
    longitude: float
    place: str

    @property
    def point(self):
        return Point(self.longitude, self.latitude)

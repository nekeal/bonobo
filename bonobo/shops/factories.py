import factory
from django.contrib.gis.geos.point import Point
from factory.django import DjangoModelFactory

from bonobo.shops.models import Shop


class ShopFactory(DjangoModelFactory):
    maps_url = factory.Sequence(
        lambda n: f"https://www.google.com/maps/place/Place+{n}/@{float(n)},{float(n)},17.59z/"
    )
    slug = factory.Sequence(lambda n: f"shop-{n}")
    place_name = factory.Sequence(lambda n: f"Place {n}")
    location = factory.Sequence(lambda n: Point(float(n), float(n)))

    class Meta:
        model = Shop

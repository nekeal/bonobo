import factory
from django.contrib.gis.geos.point import Point
from django.utils import timezone
from factory import fuzzy
from factory.django import DjangoModelFactory

from bonobo.shops.models import Income, Shop


class ShopFactory(DjangoModelFactory):
    maps_url = factory.Sequence(
        lambda n: f"https://www.google.com/maps/place/Place+{n}/@{float(n)},{float(n)},17.59z/"
    )
    slug = factory.Sequence(lambda n: f"shop-{n}")
    place_name = factory.Sequence(lambda n: f"Place {n}")
    location = factory.Sequence(lambda n: Point(float(n), float(n)))

    class Meta:
        model = Shop


class IncomeFactory(DjangoModelFactory):
    shop = factory.SubFactory(ShopFactory)
    when = factory.fuzzy.FuzzyDate(
        start_date=timezone.now().date().replace(day=1, month=1),
        end_date=timezone.now().date(),
    )
    value = factory.Sequence(lambda n: n)

    class Meta:
        model = Income

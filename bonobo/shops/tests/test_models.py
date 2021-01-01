from datetime import date

import pytest
from django.contrib.gis.geos.point import Point

from bonobo.shops.factories import IncomeFactory, ShopFactory
from bonobo.shops.models import Income, Shop


class TestShopQuerySet:
    def test_annotate_metrics_for_month(self, shop):
        values = (10, 100, 200, 300)
        income1 = IncomeFactory.build(shop=shop, when=date(2020, 1, 1), value=values[0])
        income2 = IncomeFactory.build(shop=shop, when=date(2020, 1, 1), value=values[1])
        income3 = IncomeFactory.build(shop=shop, when=date(2020, 2, 1), value=values[2])
        income4 = IncomeFactory.build(shop=shop, when=date(2019, 2, 1), value=values[3])
        Income.objects.bulk_create([income1, income2, income3, income4])
        result = Shop.objects.annotate_metrics(2020, 1).get()

        assert result.income_month_sum == sum(values[:2])
        assert result.income_year_sum == sum(values[:3])

    def test_calculating_income_for_period(self, shop):
        income1 = IncomeFactory.build(shop=shop, when=date(2020, 1, 1), value=100)
        income2 = IncomeFactory.build(shop=shop, when=date(2020, 1, 2), value=200)
        income3 = IncomeFactory.build(shop=shop, when=date(2020, 1, 3), value=300)
        Income.objects.bulk_create([income1, income2, income3])
        assert shop.get_income_for_period(date(2020, 1, 2), date(2020, 1, 3)) == 500

    @pytest.mark.parametrize(
        ("radius", "expected_ids"),
        (
            (1, set()),
            (
                1481,
                {
                    1,
                },
            ),
            (
                1482,
                {
                    1,
                    2,
                },
            ),
        ),
    )
    @pytest.mark.django_db
    def test_find_nearby(self, radius, expected_ids):
        Shop.objects.bulk_create(
            [
                ShopFactory.build(id=1, location=Point(x=10, y=15)),
                ShopFactory.build(id=2, location=Point(x=20, y=25)),
            ]
        )

        point = Point(10, 15.5)
        result = {
            shop.id
            for shop in Shop.objects.find_nearby(point, radius=radius, unit="km")
        }
        assert expected_ids == result

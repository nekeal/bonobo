import re
from datetime import date

import pytest
from django.contrib.gis.geos.point import Point
from django.db import connection
from django.utils import timezone
from psycopg2._range import DateRange

from bonobo.shops.choices import EmployeeRoleChoices
from bonobo.shops.factories import IncomeFactory, ShopFactory
from bonobo.shops.models import Income, Shop, Employment, Salary


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

    @pytest.mark.django_db
    def test_shop_reference_is_automatically_assigned(self):
        shop = ShopFactory(reference="random")
        assert shop.reference == "random"
        shop.refresh_from_db()
        assert re.match(f"bonobo-{timezone.now().year}-\\d+", shop.reference)

    @pytest.mark.django_db
    def test_sequence_is_created(self):
        ShopFactory()
        with connection.cursor() as cursor:
            cursor.execute(
                f"select exists (select relname from pg_class "
                f"where relkind = 'S' "
                f"and relname = 'shop_reference_{timezone.now().year}');"
            )
            assert cursor.fetchone()[0] is True

    def test_closing_shop_gives_all_employees_salary(self, shop, admin_user):
        shop2 = ShopFactory()
        employee1 = Employment.objects.create(user=admin_user, shop=shop, role=EmployeeRoleChoices.CASHIER, timespan=DateRange(date(2020, 12, 1)))
        employee2 = Employment.objects.create(user=admin_user, shop=shop, role=EmployeeRoleChoices.CASHIER, timespan=DateRange(date(2020, 12, 1), date(2021, 1, 1)))
        employee3 = Employment.objects.create(user=admin_user, shop=shop2, role=EmployeeRoleChoices.CASHIER, timespan=DateRange(date(2020, 12, 1)))
        shop.close()
        employee1_salary = Salary.objects.get()  # only single salary
        assert employee1_salary.value == 2000
        assert employee1_salary.when == timezone.now().date()
        employee1.refresh_from_db()
        employee2.refresh_from_db()
        employee3.refresh_from_db()
        assert employee1.timespan.upper == timezone.now().date()
        assert employee2.timespan.upper == date(2021, 1, 1)
        assert employee3.timespan.upper is None

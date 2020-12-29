import datetime

from django.contrib.gis.db import models as gis_models
from django.contrib.postgres.fields import DateRangeField
from django.db import connection, models
from django.db.models import Q, QuerySet
from django.db.models.aggregates import Sum

from bonobo.common.models import OwnedModel, TimeStampedModel
from bonobo.shops.choices import EmployeeRoleChoices
from bonobo.shops.entities import GeocodedPlace


class ShopQuerySet(QuerySet["Shop"]):
    def annotate_metrics(self, year, month=None):
        qs = self.annotate(
            income_year_sum=Sum("incomes__value", filter=Q(incomes__when__year=year)),
        )
        if month:
            qs = qs.annotate(
                income_month_sum=Sum(
                    "incomes__value", filter=Q(incomes__when__month=month)
                ),
            )
        # return qs
        # breakpofrint()
        # qs = self.raw("SELECT shops_shop.id,"
        #                 "shops_shop.created_at,"
        #                 "shops_shop.modified_at,"
        #                 "shops_shop.created_by_id,"
        #                 "shops_shop.modified_by_id,"
        #                 "shops_shop.maps_url,"
        #                 "shops_shop.slug,"
        #                 "shops_shop.place_name,"
        #                 "shops_shop.location :: bytea,"
        #                 "SUM(shops_income.value) FILTER"
        #                 "( "
        #                 "WHERE shops_income.when BETWEEN '%(year)s-01-01' AND '%(year)s-12-31') AS income_year_sum "
        #                 "FROM shops_shop "
        #                 "LEFT OUTER JOIN shops_income ON (shops_shop.id = shops_income.shop_id) "
        #                 "GROUP BY shops_shop.id;", {"year": year})
        return qs


class Shop(TimeStampedModel, OwnedModel):
    maps_url = models.URLField(blank=True)
    slug = models.SlugField()
    place_name = models.CharField(max_length=200, blank=True)
    location = gis_models.PointField(geography=True, null=True)

    def update_with_geocoded_place(
        self, geocoded_place: GeocodedPlace, save=True
    ) -> None:
        self.place_name = geocoded_place.place
        self.location = geocoded_place.point
        if save:
            self.save()

    objects = ShopQuerySet.as_manager()

    def __str__(self):
        return self.slug

    def get_income_for_period(self, begin: datetime.datetime, end: datetime.datetime):
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT COALESCE(SUM(value), 0)"
                " FROM shops_income"
                " WHERE shop_id=%s"
                " AND shops_income.when BETWEEN %s AND %s",
                [self.id, begin.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")],
            )
            return cursor.fetchone()[0]


class Income(models.Model):
    shop = models.ForeignKey(
        "Shop",
        on_delete=models.PROTECT,
        unique_for_month="when",
        related_name="incomes",
    )
    when = models.DateField(blank=True, default=datetime.date.today)
    value = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.shop.slug} {self.when} {self.value}"


class Employment(models.Model):
    user = models.ForeignKey(
        "accounts.CustomUser", on_delete=models.PROTECT, related_name="employments"
    )
    shop = models.ForeignKey(
        "Shop", on_delete=models.PROTECT, related_name="shop_employments"
    )
    role = models.CharField(
        max_length=20,
        choices=EmployeeRoleChoices.choices,
    )
    timespan = DateRangeField(null=True)

    def __str__(self):
        return f"{self.user.first_name} {self.user.last_name} {self.shop.slug}"


class Salary(models.Model):
    employee = models.ForeignKey(
        "accounts.CustomUser",
        on_delete=models.PROTECT,
        unique_for_month="when",
        related_name="salaries",
    )
    when = models.DateField(blank=True, default=datetime.date.today)

    def __str__(self):
        return f"{self.employee.first_name} {self.employee.last_name} - {self.when}"

    class Meta:
        verbose_name_plural = "Salaries"

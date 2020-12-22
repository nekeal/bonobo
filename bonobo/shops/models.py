import datetime

from django.contrib.gis.db import models as gis_models
from django.contrib.postgres.fields import DateRangeField
from django.db import models

from bonobo.common.models import OwnedModel, TimeStampedModel
from bonobo.shops.choices import EmployeeRoleChoices
from bonobo.shops.entities import GeocodedPlace


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

    def __str__(self):
        return self.slug


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

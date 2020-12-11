# from django.contrib.gis.db import models as gis_models
import datetime

from django.contrib.postgres.fields import DateRangeField
from django.db import models
from bonobo.common.models import TimeStampedModel, OwnedModel


class Shop(TimeStampedModel, OwnedModel):
    slug = models.SlugField()
    # location = gis_models.PointField(geography=True)


    def __str__(self):
        return self.slug


class Income(models.Model):
    shop = models.ForeignKey("Shop", on_delete=models.PROTECT, unique_for_month="when", related_name="incomes")
    when = models.DateField(blank=True, default=datetime.date.today)
    value = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.shop.slug} {self.when} {self.value}"


class Employment(models.Model):
    user = models.ForeignKey('accounts.CustomUser', on_delete=models.PROTECT, related_name="employments")
    shop = models.ForeignKey('Shop', on_delete=models.PROTECT, related_name="shop_employments")
    # timespan TODO: range field or two separated fields?

    def __str__(self):
        return f"{self.user.first_name} {self.user.last_name} {self.shop.slug}"


class Salary(models.Model):
    employee = models.ForeignKey("accounts.CustomUser", on_delete=models.PROTECT, unique_for_month="when", related_name="salaries")
    when = models.DateField(blank=True, default=datetime.date.today)

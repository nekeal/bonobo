# type: ignore
from datetime import timedelta
from typing import Any

from django.contrib import admin, messages
from django.contrib.admin.widgets import AdminDateWidget
from django.contrib.gis.admin import GeoModelAdmin
from django.contrib.postgres.fields import DateRangeField
from django.contrib.postgres.forms import RangeWidget
from django.db.models import QuerySet
from django.http import HttpRequest
from django.utils import timezone

from bonobo.shops.models import Employment, Income, Salary, Shop
from bonobo.shops.services import ShopGeocodingService


@admin.register(Shop)
class ShopAdmin(GeoModelAdmin):
    list_display = (
        "slug",
        "reference",
        "get_coordinates",
        "get_income_month_sum",
        "get_current_year_income",
    )
    readonly_fields = ("get_coordinates",)
    actions = ["close_shops"]

    def close_shops(self, request, queryset):
        for shop in queryset:
            shop.close()
        messages.success(request, "Successfully closed selected shops", )

    def get_coordinates(self, instance):
        return f"{instance.location.x}, {instance.location.y}"

    get_coordinates.short_description = "Coordinates"
    get_coordinates.admin_order_field = "location"

    def get_income_month_sum(self, instance: Shop):
        now = timezone.now()
        previous_month_begin = (now.replace(day=1) - timedelta(days=1)).replace(day=1)
        value = instance.get_income_for_period(
            previous_month_begin, now.replace(day=1) - timedelta(days=1)
        )
        return f"{value:,}"

    get_income_month_sum.short_description = "Previous month income"

    def get_current_year_income(self, instance):
        now = timezone.now()
        current_year_begin = now.replace(month=1, day=1)
        current_year_end = now.replace(month=12, day=31)
        value = instance.get_income_for_period(current_year_begin, current_year_end)
        return f"{value:,}"

    get_current_year_income.short_description = "Current year income"

    def get_queryset(self, request: HttpRequest) -> QuerySet:
        now = timezone.now()
        qs = (
            super(ShopAdmin, self)
            .get_queryset(request)
            .annotate_metrics(year=now.year, month=now.month - 1)
        )
        return qs

    def save_model(self, request: Any, obj: Shop, form: Any, change: Any) -> None:
        if obj.maps_url:
            obj, updated = ShopGeocodingService(obj, save=False).run()
        return super(ShopAdmin, self).save_model(request, obj, form, change)


@admin.register(Income)
class IncomeAdmin(admin.ModelAdmin):
    list_display = ("shop", "when", "value")
    date_hierarchy = "when"

    def get_queryset(self, request):
        return super().get_queryset(request).select_related("shop")


@admin.register(Employment)
class EmploymentAdmin(admin.ModelAdmin):
    list_display = ("get_user", "role", "get_shop", "timespan")
    formfield_overrides = {
        DateRangeField: {"widget": RangeWidget(AdminDateWidget())},
    }

    def get_user(self, instance):
        return instance.user.get_full_name()

    get_user.short_description = "Employee"
    get_user.admin_order_field = "user"

    def get_shop(self, instance):
        return instance.shop.slug

    get_shop.short_description = "Shop"
    get_shop.admin_order_field = "shop__slug"

    def get_queryset(self, request):
        return super().get_queryset(request).select_related("user", "shop")


@admin.register(Salary)
class SalaryAdmin(admin.ModelAdmin):
    list_display = ("get_user", "get_date", "value")

    def get_user(self, instance):
        return instance.employee.get_full_name()

    get_user.short_description = "Employee"
    get_user.admin_order_field = "user"

    def get_date(self, instance):
        return instance.when.strftime("%Y %B")

    get_date.short_description = "Date"
    get_date.admin_order_field = "when"

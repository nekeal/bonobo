from django.contrib import admin
from django.contrib.gis.admin import GeoModelAdmin

from bonobo.shops.models import Shop, Income, Employment, Salary


@admin.register(Shop)
class ShopAdmin(GeoModelAdmin):
    list_display = ('slug', 'get_coordinates')
    readonly_fields = ("get_coordinates",)

    def get_coordinates(self, instance):
        return f"{instance.location.x}, {instance.location.y}"

    get_coordinates.short_description = "Coordinates"
    get_coordinates.admin_order_field = "location"


@admin.register(Income)
class IncomeAdmin(admin.ModelAdmin):
    list_display = ("shop", "get_date", "value")

    def get_date(self, instance):
        return instance.when.strftime("%Y %B")

    get_date.short_description = "Date"
    get_date.admin_order_field = "when"

    def get_queryset(self, request):
        return super().get_queryset(request).select_related("shop")


@admin.register(Employment)
class EmployemntAdmin(admin.ModelAdmin):
    list_display = ("get_user", "get_shop", "timespan")

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
    list_display = ("get_user", 'get_date')

    def get_user(self, instance):
        return instance.employee.get_full_name()

    get_user.short_description = "Employee"
    get_user.admin_order_field = "user"

    def get_date(self, instance):
        return instance.when.strftime("%Y %B")

    get_date.short_description = "Date"
    get_date.admin_order_field = "when"

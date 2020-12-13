from django.contrib import admin
from django.contrib.gis.admin import GeoModelAdmin

from bonobo.shops.models import Shop, Income, Employment, Salary


@admin.register(Shop)
class ShopAdmin(GeoModelAdmin):
    list_display = ('slug', 'location')


@admin.register(Income)
class IncomeAdmin(admin.ModelAdmin):
    pass


@admin.register(Employment)
class EmployemntAdmin(admin.ModelAdmin):
    pass


@admin.register(Salary)
class SalaryAdmin(admin.ModelAdmin):
    pass

from django.contrib import admin

from bonobo.shops.models import Shop, Income, Employment


@admin.register(Shop)
class ShopAdmin(admin.ModelAdmin):
    pass


@admin.register(Income)
class IncomeAdmin(admin.ModelAdmin):
    pass


@admin.register(Employment)
class EmployemntAdmin(admin.ModelAdmin):
    pass

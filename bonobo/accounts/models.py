from django.contrib.auth.models import AbstractUser
from django.db import models

from bonobo.shops.choices import EmployeeRoleChoices


class CustomUser(AbstractUser):
    role = models.CharField(max_length=20, choices=EmployeeRoleChoices.choices)
    shop = models.ForeignKey("shops.Shop", on_delete=models.SET_NULL, null=True, related_name="Employees")
    base_salary = models.PositiveSmallIntegerField(null=True, blank=True)

from django.contrib.auth.models import AbstractUser
from django.db import models


class CustomUser(AbstractUser):
    base_salary = models.PositiveSmallIntegerField(null=True, blank=True)

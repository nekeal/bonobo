from django.db.models import TextChoices


class EmployeeRoleChoices(TextChoices):
    CASHIER = "CASHIER", "CASHIER"
    MANAGER = "MANAGER", "MANAGER"

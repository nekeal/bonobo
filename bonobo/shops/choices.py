from django.db.models import TextChoices


class EmployeeRoleChoices(TextChoices):
    CASHIER = "CASHIER", "Cashier"
    MANAGER = "MANAGER", "Manager"

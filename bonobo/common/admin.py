from django.contrib import admin
from django.db import models


class OwnedModelAdminMixin:

    def save_model(self, request, obj, form, change) -> models.Model:
        if not obj.pk:
            obj.created_by = request.user
        obj.modified_by = request.user
        return super().save_model(request, obj, form, change)  # type: ignore[misc] # noqa

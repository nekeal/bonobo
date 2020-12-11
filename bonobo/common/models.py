from django.db import models

from bonobo.accounts.models import CustomUser


class TimeStampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class OwnedModel(models.Model):
    created_by = models.ForeignKey('accounts.CustomUser', on_delete=models.CASCADE,
                                   blank=True, null=True, related_name='%(class)s_created')
    modified_by = models.ForeignKey('accounts.CustomUser', on_delete=models.CASCADE,
                                    blank=True, null=True, related_name='%(class)s_modified')

    class Meta:
        abstract = True

    def is_owner(self, user: 'CustomUser') -> bool:
        return user == self.created_by

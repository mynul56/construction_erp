"""
core/models.py — Base model with timestamps and soft-delete.
"""
import uuid
from django.db import models


class SoftDeleteManager(models.Manager):
    """Returns only non-deleted records by default."""
    def get_queryset(self):
        return super().get_queryset().filter(is_deleted=False)


class AllObjectsManager(models.Manager):
    """Returns all records including soft-deleted."""
    pass


class BaseModel(models.Model):
    """
    Abstract base for all domain models.
    - UUID primary key (avoids sequential ID enumeration)
    - created_at / updated_at auto-timestamps
    - Soft delete via is_deleted flag
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)

    objects = SoftDeleteManager()
    all_objects = AllObjectsManager()

    class Meta:
        abstract = True
        ordering = ['-created_at']

    def soft_delete(self):
        self.is_deleted = True
        self.save(update_fields=['is_deleted', 'updated_at'])

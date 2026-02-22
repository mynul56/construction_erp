"""
Inventory app — Materials and stock items.
"""
from django.db import models
from core.models import BaseModel
from apps.projects.models import Project


class InventoryCategory(models.TextChoices):
    STEEL = 'Steel', 'Steel'
    CEMENT = 'Cement', 'Cement'
    TIMBER = 'Timber', 'Timber'
    SAFETY = 'Safety', 'Safety'
    ELECTRICAL = 'Electrical', 'Electrical'
    PLUMBING = 'Plumbing', 'Plumbing'
    TOOLS = 'Tools', 'Tools'
    OTHER = 'Other', 'Other'


class InventoryItem(BaseModel):
    """A material or supply item tracked in the ERP."""
    name = models.CharField(max_length=200)
    category = models.CharField(
        max_length=30, choices=InventoryCategory.choices, default=InventoryCategory.OTHER
    )
    quantity = models.FloatField(default=0)
    unit = models.CharField(max_length=20, default='pcs')
    unit_price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    low_stock_threshold = models.FloatField(default=10)
    location = models.CharField(max_length=200, blank=True)
    project = models.ForeignKey(
        Project, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='inventory_items'
    )
    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['name']

    def __str__(self):
        return f'{self.name} ({self.quantity} {self.unit})'

    @property
    def is_low_stock(self):
        return self.quantity <= self.low_stock_threshold

    @property
    def total_value(self):
        return round(self.quantity * float(self.unit_price), 2)

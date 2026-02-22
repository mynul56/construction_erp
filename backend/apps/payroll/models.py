"""
Payroll app — Monthly payroll records per worker.
"""
from django.db import models
from core.models import BaseModel
from apps.workforce.models import Worker


class PayrollStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    PAID = 'paid', 'Paid'
    CANCELLED = 'cancelled', 'Cancelled'


class PayrollRecord(BaseModel):
    """Monthly salary record for a worker."""
    worker = models.ForeignKey(Worker, on_delete=models.CASCADE, related_name='payroll_records')
    month = models.PositiveSmallIntegerField()    # 1–12
    year = models.PositiveSmallIntegerField()
    base_salary = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    bonus = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    deductions = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    status = models.CharField(
        max_length=20, choices=PayrollStatus.choices, default=PayrollStatus.PENDING
    )
    paid_at = models.DateTimeField(null=True, blank=True)
    notes = models.CharField(max_length=300, blank=True)

    class Meta:
        unique_together = ('worker', 'month', 'year')
        ordering = ['-year', '-month']

    def __str__(self):
        return f'{self.worker.name} — {self.month}/{self.year}'

    @property
    def net_salary(self):
        return float(self.base_salary) + float(self.bonus) - float(self.deductions)

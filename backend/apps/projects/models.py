"""
Projects app — Construction project model.
"""
from django.db import models
from core.models import BaseModel
from apps.authentication.models import User


class SiteManagerProfile(BaseModel):
    """Extended profile for site managers."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='site_manager_profile')
    employee_id = models.CharField(max_length=20, unique=True)
    department = models.CharField(max_length=100, blank=True)
    years_of_experience = models.PositiveIntegerField(default=0)
    certifications = models.TextField(blank=True, help_text='Comma-separated list')

    def __str__(self):
        return f'{self.user.name} - Site Manager'


class ProjectStatus(models.TextChoices):
    PLANNING = 'planning', 'Planning'
    IN_PROGRESS = 'in_progress', 'In Progress'
    ON_HOLD = 'on_hold', 'On Hold'
    COMPLETED = 'completed', 'Completed'
    CANCELLED = 'cancelled', 'Cancelled'


class Project(BaseModel):
    """A construction project site."""
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    location = models.CharField(max_length=300)
    status = models.CharField(
        max_length=20, choices=ProjectStatus.choices, default=ProjectStatus.PLANNING
    )
    progress = models.FloatField(default=0.0, help_text='0–100 percent')
    budget = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    spent = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    start_date = models.DateField(null=True, blank=True)
    due_date = models.DateField(null=True, blank=True)
    site_manager = models.ForeignKey(
        User, on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='managed_projects',
        limit_choices_to={'role': 'site_manager'},
    )
    workers = models.ManyToManyField(
        User, blank=True, related_name='assigned_projects'
    )

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.name

    @property
    def worker_count(self):
        return self.workers.count()

    @property
    def budget_utilization(self):
        if self.budget == 0:
            return 0
        return round(float(self.spent) / float(self.budget) * 100, 1)

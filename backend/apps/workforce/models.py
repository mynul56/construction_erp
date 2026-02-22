"""
Workforce app — Worker profiles and attendance.
"""
from django.db import models
from core.models import BaseModel
from apps.authentication.models import User
from apps.projects.models import Project


class Worker(BaseModel):
    """Extended profile for site workers."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='worker_profile')
    employee_id = models.CharField(max_length=20, unique=True)
    designation = models.CharField(max_length=100)
    daily_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    joining_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return f'{self.user.name} — {self.designation}'

    @property
    def name(self):
        return self.user.name


class AttendanceStatus(models.TextChoices):
    PRESENT = 'present', 'Present'
    ABSENT = 'absent', 'Absent'
    LATE = 'late_arrival', 'Late Arrival'
    ON_LEAVE = 'on_leave', 'On Leave'


class Attendance(BaseModel):
    """Daily attendance record per worker per project."""
    worker = models.ForeignKey(Worker, on_delete=models.CASCADE, related_name='attendances')
    project = models.ForeignKey(
        Project, on_delete=models.SET_NULL, null=True, blank=True,
        related_name='attendances'
    )
    date = models.DateField()
    status = models.CharField(
        max_length=20, choices=AttendanceStatus.choices, default=AttendanceStatus.PRESENT
    )
    check_in = models.TimeField(null=True, blank=True)
    check_out = models.TimeField(null=True, blank=True)
    notes = models.CharField(max_length=300, blank=True)

    class Meta:
        unique_together = ('worker', 'date')
        ordering = ['-date']

    def __str__(self):
        return f'{self.worker.name} — {self.date} ({self.status})'

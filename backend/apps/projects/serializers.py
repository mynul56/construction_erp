from rest_framework import serializers
from .models import Project


class ProjectSerializer(serializers.ModelSerializer):
    worker_count = serializers.ReadOnlyField()
    budget_utilization = serializers.ReadOnlyField()
    site_manager_name = serializers.CharField(
        source='site_manager.name', read_only=True
    )

    class Meta:
        model = Project
        fields = [
            'id', 'name', 'description', 'location', 'status',
            'progress', 'budget', 'spent', 'budget_utilization',
            'start_date', 'due_date', 'site_manager', 'site_manager_name',
            'worker_count', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

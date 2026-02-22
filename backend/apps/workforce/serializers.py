from rest_framework import serializers
from apps.authentication.serializers import UserSerializer
from .models import Worker, Attendance


class WorkerSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    user_id = serializers.UUIDField(write_only=True)

    class Meta:
        model = Worker
        fields = [
            'id', 'user', 'user_id', 'employee_id', 'designation',
            'daily_rate', 'joining_date', 'created_at',
        ]
        read_only_fields = ['id', 'created_at']


class AttendanceSerializer(serializers.ModelSerializer):
    worker_name = serializers.CharField(source='worker.name', read_only=True)
    worker_designation = serializers.CharField(source='worker.designation', read_only=True)
    project_name = serializers.CharField(source='project.name', read_only=True)
    avatar_initial = serializers.SerializerMethodField()

    class Meta:
        model = Attendance
        fields = [
            'id', 'worker', 'worker_name', 'worker_designation',
            'avatar_initial', 'project', 'project_name',
            'date', 'status', 'check_in', 'check_out', 'notes',
        ]
        read_only_fields = ['id']

    def get_avatar_initial(self, obj):
        return obj.worker.name[0].upper() if obj.worker.name else 'W'


class CheckInSerializer(serializers.Serializer):
    project_id = serializers.UUIDField(required=False, allow_null=True)
    notes = serializers.CharField(required=False, allow_blank=True)

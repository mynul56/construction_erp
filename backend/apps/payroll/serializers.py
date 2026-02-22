from rest_framework import serializers
from .models import PayrollRecord


class PayrollRecordSerializer(serializers.ModelSerializer):
    net_salary = serializers.ReadOnlyField()
    worker_name = serializers.CharField(source='worker.name', read_only=True)
    worker_role = serializers.CharField(source='worker.designation', read_only=True)
    avatar_initial = serializers.SerializerMethodField()

    class Meta:
        model = PayrollRecord
        fields = [
            'id', 'worker', 'worker_name', 'worker_role', 'avatar_initial',
            'month', 'year', 'base_salary', 'bonus', 'deductions',
            'net_salary', 'status', 'paid_at', 'notes',
        ]
        read_only_fields = ['id']

    def get_avatar_initial(self, obj):
        return obj.worker.name[0].upper() if obj.worker.name else 'W'

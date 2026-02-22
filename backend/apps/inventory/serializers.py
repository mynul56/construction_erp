from rest_framework import serializers
from .models import InventoryItem


class InventoryItemSerializer(serializers.ModelSerializer):
    is_low_stock = serializers.ReadOnlyField()
    total_value = serializers.ReadOnlyField()
    project_name = serializers.CharField(source='project.name', read_only=True)

    class Meta:
        model = InventoryItem
        fields = [
            'id', 'name', 'category', 'quantity', 'unit',
            'unit_price', 'total_value', 'low_stock_threshold',
            'is_low_stock', 'location', 'project', 'project_name',
            'notes', 'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

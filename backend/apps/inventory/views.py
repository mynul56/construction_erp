"""
Inventory views — CRUD and low-stock filter.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from .models import InventoryItem
from .serializers import InventoryItemSerializer


class InventoryListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = InventoryItem.objects.select_related('project').all()
        # Filter by project
        project_id = request.query_params.get('project')
        if project_id:
            qs = qs.filter(project_id=project_id)
        # Filter by category
        category = request.query_params.get('category')
        if category:
            qs = qs.filter(category=category)
        return Response({
            'success': True,
            'count': qs.count(),
            'data': InventoryItemSerializer(qs, many=True).data,
        })

    def post(self, request):
        if request.user.role not in ('admin', 'site_manager'):
            return Response(
                {'success': False, 'message': 'Permission denied.'},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = InventoryItemSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {'success': True, 'data': serializer.data},
            status=status.HTTP_201_CREATED
        )


class InventoryDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def _get_item(self, pk):
        try:
            return InventoryItem.objects.get(pk=pk)
        except InventoryItem.DoesNotExist:
            return None

    def get(self, request, pk):
        item = self._get_item(pk)
        if not item:
            return Response({'success': False, 'message': 'Not found.'}, status=404)
        return Response({'success': True, 'data': InventoryItemSerializer(item).data})

    def patch(self, request, pk):
        if request.user.role not in ('admin', 'site_manager'):
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        item = self._get_item(pk)
        if not item:
            return Response({'success': False, 'message': 'Not found.'}, status=404)
        serializer = InventoryItemSerializer(item, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'success': True, 'data': serializer.data})

    def delete(self, request, pk):
        if request.user.role != 'admin':
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        item = self._get_item(pk)
        if not item:
            return Response({'success': False, 'message': 'Not found.'}, status=404)
        item.soft_delete()
        return Response({'success': True, 'message': 'Item deleted.'})


class LowStockView(APIView):
    """GET /api/inventory/low-stock/ — items at or below threshold."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from django.db.models import F
        qs = InventoryItem.objects.filter(
            quantity__lte=F('low_stock_threshold')
        )
        return Response({
            'success': True,
            'count': qs.count(),
            'data': InventoryItemSerializer(qs, many=True).data,
        })

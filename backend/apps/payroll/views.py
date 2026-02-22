"""
Payroll views — monthly summary and per-worker records.
"""
from datetime import date
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.db.models import Sum, Count

from .models import PayrollRecord, PayrollStatus
from .serializers import PayrollRecordSerializer
from apps.workforce.models import Worker


class PayrollSummaryView(APIView):
    """GET /api/payroll/summary/?month=M&year=Y"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ('admin', 'site_manager'):
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)

        today = date.today()
        month = int(request.query_params.get('month', today.month))
        year = int(request.query_params.get('year', today.year))

        qs = PayrollRecord.objects.filter(month=month, year=year)
        agg = qs.aggregate(
            total_payroll=Sum('base_salary') + Sum('bonus') - Sum('deductions'),
            paid=Sum('base_salary', filter=qs.filter(status='paid').query),
        )

        # Totals
        records = list(qs.select_related('worker__user'))
        total = sum(r.net_salary for r in records)
        paid = sum(r.net_salary for r in records if r.status == PayrollStatus.PAID)
        pending = total - paid
        worker_count = qs.values('worker').count()

        # Monthly trend (last 6 months)
        monthly_trend = []
        m, y = month, year
        for _ in range(6):
            m -= 1
            if m == 0:
                m = 12
                y -= 1
            s = PayrollRecord.objects.filter(month=m, year=y).aggregate(
                t=Sum('base_salary')
            )['t'] or 0
            monthly_trend.insert(0, float(s))

        # Top earners
        top = sorted(records, key=lambda r: r.net_salary, reverse=True)[:5]

        return Response({
            'success': True,
            'data': {
                'month': month,
                'year': year,
                'total_payroll': total,
                'paid_amount': paid,
                'pending_amount': pending,
                'worker_count': worker_count,
                'monthly_trend': monthly_trend,
                'top_earners': PayrollRecordSerializer(top, many=True).data,
            }
        })


class PayrollWorkerListView(APIView):
    """GET /api/payroll/workers/?month=M&year=Y"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ('admin', 'site_manager'):
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        today = date.today()
        month = int(request.query_params.get('month', today.month))
        year = int(request.query_params.get('year', today.year))
        qs = PayrollRecord.objects.filter(
            month=month, year=year
        ).select_related('worker__user').order_by('-base_salary')
        return Response({
            'success': True,
            'data': PayrollRecordSerializer(qs, many=True).data,
        })


class PayrollCreateUpdateView(APIView):
    """POST /api/payroll/ — create; PATCH /api/payroll/<pk>/"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != 'admin':
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        serializer = PayrollRecordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {'success': True, 'data': serializer.data},
            status=status.HTTP_201_CREATED
        )

    def patch(self, request, pk=None):
        if request.user.role != 'admin':
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        try:
            record = PayrollRecord.objects.get(pk=pk)
        except PayrollRecord.DoesNotExist:
            return Response({'success': False, 'message': 'Not found.'}, status=404)
        serializer = PayrollRecordSerializer(record, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'success': True, 'data': serializer.data})

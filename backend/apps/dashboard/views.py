"""
Dashboard view — single endpoint that aggregates KPIs for the Flutter DashboardPage.
Matches DashboardStatsEntity + ProjectSummary exactly.
"""
from datetime import date, timedelta
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Sum, F, Count

from apps.projects.models import Project, ProjectStatus
from apps.workforce.models import Attendance, Worker, AttendanceStatus
from apps.inventory.models import InventoryItem
from apps.payroll.models import PayrollRecord
from apps.projects.serializers import ProjectSerializer


class DashboardStatsView(APIView):
    """
    GET /api/dashboard/stats/
    Single aggregated response matching Flutter's DashboardStatsEntity.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        today = date.today()
        thirty_days_ago = today - timedelta(days=30)

        # ── Worker attendance today ─────────────────────────────────────
        total_workers = Worker.objects.count()
        present_today = Attendance.objects.filter(
            date=today,
            status__in=[AttendanceStatus.PRESENT, AttendanceStatus.LATE]
        ).count()

        # ── Active projects ─────────────────────────────────────────────
        active_projects = Project.objects.filter(
            status=ProjectStatus.IN_PROGRESS
        ).count()

        # ── Monthly payroll total ───────────────────────────────────────
        monthly_payroll = PayrollRecord.objects.filter(
            month=today.month, year=today.year
        ).aggregate(
            t=Sum(F('base_salary') + F('bonus') - F('deductions'))
        )['t'] or 0

        # ── Low stock items ─────────────────────────────────────────────
        low_stock_count = InventoryItem.objects.filter(
            quantity__lte=F('low_stock_threshold')
        ).count()

        # ── Project completion average ──────────────────────────────────
        from django.db.models import Avg
        avg_progress = Project.objects.aggregate(
            avg=Avg('progress')
        )['avg'] or 0

        # ── Recent projects for list ────────────────────────────────────
        recent_projects = Project.objects.select_related('site_manager').order_by(
            '-updated_at'
        )[:5]

        # ── Weekly attendance trend (last 7 days) ──────────────────────
        weekly = []
        for i in range(6, -1, -1):
            d = today - timedelta(days=i)
            count = Attendance.objects.filter(
                date=d,
                status__in=[AttendanceStatus.PRESENT, AttendanceStatus.LATE]
            ).count()
            weekly.append({'day': d.strftime('%a'), 'count': count})

        return Response({
            'success': True,
            'data': {
                'total_workers': total_workers,
                'present_today': present_today,
                'absent_today': total_workers - present_today,
                'active_projects': active_projects,
                'monthly_payroll': float(monthly_payroll),
                'low_stock_count': low_stock_count,
                'avg_project_progress': round(float(avg_progress), 1),
                'weekly_attendance': weekly,
                'recent_projects': ProjectSerializer(recent_projects, many=True).data,
            }
        })

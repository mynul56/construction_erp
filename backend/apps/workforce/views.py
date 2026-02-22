"""
Workforce views — Worker list, attendance by date, check-in.
"""
from datetime import date, datetime, time
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from .models import Worker, Attendance, AttendanceStatus
from .serializers import WorkerSerializer, AttendanceSerializer, CheckInSerializer
from apps.projects.models import Project


class WorkerListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role not in ('admin', 'site_manager'):
            return Response(
                {'success': False, 'message': 'Permission denied.'},
                status=status.HTTP_403_FORBIDDEN
            )
        qs = Worker.objects.select_related('user').all()
        return Response({
            'success': True,
            'data': WorkerSerializer(qs, many=True).data
        })


class AttendanceListView(APIView):
    """GET /api/workforce/attendance/?date=YYYY-MM-DD"""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        date_str = request.query_params.get('date')
        if date_str:
            try:
                target_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            except ValueError:
                return Response(
                    {'success': False, 'message': 'Invalid date format. Use YYYY-MM-DD.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        else:
            target_date = date.today()

        qs = Attendance.objects.filter(date=target_date).select_related(
            'worker__user', 'project'
        )
        # Workers only see their own attendance
        if request.user.role == 'worker':
            try:
                worker = request.user.worker_profile
                qs = qs.filter(worker=worker)
            except Worker.DoesNotExist:
                return Response({'success': True, 'data': []})

        return Response({
            'success': True,
            'date': str(target_date),
            'data': AttendanceSerializer(qs, many=True).data,
        })


class CheckInView(APIView):
    """POST /api/workforce/attendance/checkin/"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            worker = request.user.worker_profile
        except Worker.DoesNotExist:
            return Response(
                {'success': False, 'message': 'Worker profile not found.'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = CheckInSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        today = date.today()
        project = None
        project_id = serializer.validated_data.get('project_id')
        if project_id:
            try:
                project = Project.objects.get(pk=project_id)
            except Project.DoesNotExist:
                pass

        now_time = datetime.now().time()

        # Late if after 9:00 AM
        is_late = now_time > time(9, 0)
        att_status = AttendanceStatus.LATE if is_late else AttendanceStatus.PRESENT

        attendance, created = Attendance.objects.get_or_create(
            worker=worker,
            date=today,
            defaults={
                'project': project,
                'status': att_status,
                'check_in': now_time,
                'notes': serializer.validated_data.get('notes', ''),
            }
        )

        if not created:
            return Response(
                {'success': False, 'message': 'Already checked in today.'},
                status=status.HTTP_409_CONFLICT
            )

        return Response({
            'success': True,
            'message': f'Checked in at {now_time.strftime("%H:%M")}.',
            'data': AttendanceSerializer(attendance).data,
        }, status=status.HTTP_201_CREATED)


class CheckOutView(APIView):
    """POST /api/workforce/attendance/checkout/"""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            worker = request.user.worker_profile
        except Worker.DoesNotExist:
            return Response(
                {'success': False, 'message': 'Worker profile not found.'},
                status=status.HTTP_404_NOT_FOUND
            )

        today = date.today()
        try:
            attendance = Attendance.objects.get(worker=worker, date=today)
        except Attendance.DoesNotExist:
            return Response(
                {'success': False, 'message': 'No check-in found for today.'},
                status=status.HTTP_404_NOT_FOUND
            )

        attendance.check_out = datetime.now().time()
        attendance.save(update_fields=['check_out', 'updated_at'])

        return Response({
            'success': True,
            'message': f'Checked out at {attendance.check_out.strftime("%H:%M")}.',
            'data': AttendanceSerializer(attendance).data,
        })

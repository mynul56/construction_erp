from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

from core.permissions import IsAdmin, IsSiteManager
from .models import Project
from .serializers import ProjectSerializer


class ProjectListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        qs = Project.objects.select_related('site_manager').all()
        # Workers only see their assigned projects
        if request.user.role == 'worker':
            qs = qs.filter(workers=request.user)
        serializer = ProjectSerializer(qs, many=True)
        return Response({'success': True, 'data': serializer.data})

    def post(self, request):
        if request.user.role not in ('admin', 'site_manager'):
            return Response(
                {'success': False, 'message': 'Permission denied.'},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = ProjectSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {'success': True, 'data': serializer.data},
            status=status.HTTP_201_CREATED
        )


class ProjectDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def _get_project(self, pk):
        try:
            return Project.objects.get(pk=pk)
        except Project.DoesNotExist:
            return None

    def get(self, request, pk):
        project = self._get_project(pk)
        if not project:
            return Response(
                {'success': False, 'message': 'Project not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        return Response({'success': True, 'data': ProjectSerializer(project).data})

    def patch(self, request, pk):
        if request.user.role not in ('admin', 'site_manager'):
            return Response(
                {'success': False, 'message': 'Permission denied.'},
                status=status.HTTP_403_FORBIDDEN
            )
        project = self._get_project(pk)
        if not project:
            return Response(
                {'success': False, 'message': 'Project not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        serializer = ProjectSerializer(project, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'success': True, 'data': serializer.data})

    def delete(self, request, pk):
        if request.user.role != 'admin':
            return Response(
                {'success': False, 'message': 'Only admins can delete projects.'},
                status=status.HTTP_403_FORBIDDEN
            )
        project = self._get_project(pk)
        if not project:
            return Response(
                {'success': False, 'message': 'Project not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        project.soft_delete()
        return Response({'success': True, 'message': 'Project deleted.'})

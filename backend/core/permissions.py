"""
core/permissions.py — Role-based permission classes matching Flutter UserRole enum.
"""
from rest_framework.permissions import BasePermission


class IsWorker(BasePermission):
    """Allows any authenticated user (worker or above)."""
    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated)


class IsSiteManager(BasePermission):
    """Allows site managers and admins."""
    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            request.user.role in ('site_manager', 'admin')
        )


class IsAdmin(BasePermission):
    """Allows only admins."""
    def has_permission(self, request, view):
        return bool(
            request.user and
            request.user.is_authenticated and
            request.user.role == 'admin'
        )


class IsOwnerOrAdmin(BasePermission):
    """Object-level: owner of record or admin."""
    def has_object_permission(self, request, view, obj):
        if request.user.role == 'admin':
            return True
        return getattr(obj, 'user', None) == request.user

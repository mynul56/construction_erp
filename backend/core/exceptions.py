"""
core/exceptions.py — Uniform JSON error response shape.
"""
from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status


def custom_exception_handler(exc, context):
    """
    Converts DRF default exceptions into a consistent shape:
    {
        "success": false,
        "message": "...",
        "errors": { ... }   ← optional field-level details
    }
    """
    response = exception_handler(exc, context)

    if response is not None:
        data = response.data
        # Extract a human-readable message
        if isinstance(data, dict):
            # Try common keys first
            message = (
                data.get('detail') or
                data.get('non_field_errors', [''])[0] if isinstance(data.get('non_field_errors'), list) else None or
                'Validation error'
            )
            errors = {k: v for k, v in data.items() if k not in ('detail',)}
        elif isinstance(data, list):
            message = str(data[0]) if data else 'Error'
            errors = {}
        else:
            message = str(data)
            errors = {}

        response.data = {
            'success': False,
            'message': str(message),
        }
        if errors:
            response.data['errors'] = errors

    return response


class ServiceError(Exception):
    """Raise from service/use-case layer for business logic errors."""
    def __init__(self, message: str, status_code: int = status.HTTP_400_BAD_REQUEST):
        self.message = message
        self.status_code = status_code
        super().__init__(message)

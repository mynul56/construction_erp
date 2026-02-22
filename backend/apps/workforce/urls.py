from django.urls import path
from .views import WorkerListView, AttendanceListView, CheckInView, CheckOutView

urlpatterns = [
    path('workers/', WorkerListView.as_view(), name='worker-list'),
    path('attendance/', AttendanceListView.as_view(), name='attendance-list'),
    path('attendance/checkin/', CheckInView.as_view(), name='attendance-checkin'),
    path('attendance/checkout/', CheckOutView.as_view(), name='attendance-checkout'),
]

from django.urls import path
from .views import PayrollSummaryView, PayrollWorkerListView, PayrollCreateUpdateView

urlpatterns = [
    path('summary/', PayrollSummaryView.as_view(), name='payroll-summary'),
    path('workers/', PayrollWorkerListView.as_view(), name='payroll-workers'),
    path('', PayrollCreateUpdateView.as_view(), name='payroll-create'),
    path('<uuid:pk>/', PayrollCreateUpdateView.as_view(), name='payroll-update'),
]

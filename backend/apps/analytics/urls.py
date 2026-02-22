from django.urls import path
from .views import AnalyticsMetricsView

urlpatterns = [
    path('metrics/', AnalyticsMetricsView.as_view(), name='analytics-metrics'),
]

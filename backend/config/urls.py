"""
Main URL configuration.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('apps.authentication.urls')),
    path('api/dashboard/', include('apps.dashboard.urls')),
    path('api/workforce/', include('apps.workforce.urls')),
    path('api/inventory/', include('apps.inventory.urls')),
    path('api/payroll/', include('apps.payroll.urls')),
    path('api/analytics/', include('apps.analytics.urls')),
    path('api/projects/', include('apps.projects.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

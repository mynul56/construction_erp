from django.urls import path
from .views import InventoryListCreateView, InventoryDetailView, LowStockView

urlpatterns = [
    path('', InventoryListCreateView.as_view(), name='inventory-list-create'),
    path('low-stock/', LowStockView.as_view(), name='inventory-low-stock'),
    path('<uuid:pk>/', InventoryDetailView.as_view(), name='inventory-detail'),
]

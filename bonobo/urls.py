"""bonobo URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
import debug_toolbar
from django.contrib import admin
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from bonobo.views import HomepageTemplateView
from bonobo.shops.views import ShopReadOnlyViewSet, StatisticsTemplateView

router = DefaultRouter()
router.register("shops", ShopReadOnlyViewSet, "shop")

urlpatterns = [
    path("", HomepageTemplateView.as_view()),
    path("admin/", admin.site.urls),
    path("admin/statistics/<int:year>", StatisticsTemplateView.as_view(), name="custom_admin:shop-statistics"),
    path("__debug__/", include(debug_toolbar.urls)),
    path("api/", include(router.urls)),
]

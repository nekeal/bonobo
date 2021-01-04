from django.contrib.gis.geos.point import Point
from django.db.models import QuerySet
from django.views.generic import TemplateView, ListView

from bonobo.shops.models import Shop
from bonobo.shops.serializers import ShopViewSetListInputSerializer


class HomepageTemplateView(ListView):
    template_name = "index.html"

    def get_queryset(self) -> QuerySet[Shop]:
        input_serializer = ShopViewSetListInputSerializer(data=self.request.GET)
        if not input_serializer.is_valid():
            return Shop.objects.none()
        qs = Shop.objects.find_nearby(
            Point(x=input_serializer.data["long"], y=input_serializer.data["lat"]),
            radius=input_serializer.data["radius"],
            unit=input_serializer.data["unit"],
        )
        print(len(qs))
        return qs

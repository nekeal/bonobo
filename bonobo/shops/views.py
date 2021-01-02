from django.contrib.gis.geos.point import Point
from rest_framework import mixins, viewsets
from rest_framework.response import Response

from bonobo.shops.models import Shop
from bonobo.shops.serializers import ShopModelSerializer, ShopViewSetListInputSerializer


class ShopReadOnlyViewSet(mixins.ListModelMixin, viewsets.GenericViewSet):
    """
    Available filters:
    lat: float
    long: float
    radius: float
    unit: ["cm", "m", "km"], default: "m"
    """

    queryset = Shop.objects.all()
    serializer_class = ShopModelSerializer

    def list(self, request, *args, **kwargs):
        input_serializer = ShopViewSetListInputSerializer(data=request.GET)
        input_serializer.is_valid(raise_exception=True)
        queryset = Shop.objects.find_nearby(
            Point(x=input_serializer.data["long"], y=input_serializer.data["lat"]),
            radius=input_serializer.data["radius"],
            unit=input_serializer.data["unit"],
        )
        shop_serializer = self.get_serializer(queryset, many=True)
        return Response(shop_serializer.data)

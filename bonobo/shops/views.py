from typing import Any, Dict

from django.contrib.gis.geos.point import Point
from django.views.generic import TemplateView
from rest_framework import mixins, viewsets
from rest_framework.response import Response

from bonobo.shops.models import Shop
from bonobo.shops.serializers import ShopModelSerializer, ShopViewSetListInputSerializer
from bonobo.shops.services import StatisticsResolverService


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


class StatisticsTemplateView(TemplateView):
    template_name = "admin_statistics.html"

    def get_context_data(self, **kwargs: Any) -> Dict[str, Any]:
        year = self.kwargs["year"]
        context = super().get_context_data(**kwargs)
        try:
            context.update(
                {
                    "most_fired_employee": StatisticsResolverService.get_the_most_ofted_fired_employee(
                        year
                    ),
                    "most_profitable_shop": StatisticsResolverService.get_most_profitable_shop(year),
                    "employer_with_most_dynamic_salary": StatisticsResolverService.get_employer_with_most_dynamic_salary(year),
                    "shop_with_most_employees": StatisticsResolverService.get_shop_with_most_new_employees(year),
                    "most_stable_shop": StatisticsResolverService.get_most_stable_shop(year),
                }
            )
        except IndexError:
            context["error_message"] = True

        return context

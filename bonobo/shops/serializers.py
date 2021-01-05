from rest_flex_fields import FlexFieldsModelSerializer
from rest_framework import serializers

from bonobo.shops.models import Shop


class ShopViewSetListInputSerializer(serializers.Serializer):
    lat = serializers.FloatField()
    long = serializers.FloatField()
    radius = serializers.FloatField(default=1000)
    unit = serializers.ChoiceField(
        choices=["m", "km", "cm"], required=False, default="m"
    )


class ShopModelSerializer(FlexFieldsModelSerializer):
    distance = serializers.SerializerMethodField("get_distance")

    class Meta:
        model = Shop
        fields = ("id", "slug", "reference", "maps_url", "location", "distance")

    def get_distance(self, instance):
        return instance.distance

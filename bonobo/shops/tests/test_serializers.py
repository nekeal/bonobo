import pytest

from bonobo.shops.serializers import ShopViewSetListInputSerializer


class TestShopViewSetListInputSerializer:
    @pytest.mark.parametrize(
        ("field", "required"),
        (("lat", True), ("long", True), ("radius", False), ("unit", False)),
    )
    def test_requirdness_of_fields(self, field, required):
        serializer = ShopViewSetListInputSerializer()
        assert serializer.fields[field].required is required

    @pytest.mark.parametrize(
        ("field", "default"),
        (
            ("radius", 1000),
            ("unit", "m"),
        ),
    )
    def test_default_values(self, field, default):
        serializer = ShopViewSetListInputSerializer()
        assert serializer.fields[field].default == default

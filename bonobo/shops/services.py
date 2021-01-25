import re
import urllib.parse
from typing import Optional, Tuple

from django.db import connection
from django.utils import timezone

from bonobo.accounts.models import CustomUser
from bonobo.shops.entities import GeocodedPlace
from bonobo.shops.models import Shop


class GeocodingUrlParser:
    def __init__(self, url) -> None:
        self.url = url

    def parse(self) -> Optional[GeocodedPlace]:
        place_re = re.search(r"place/(.+)/@(.+),(.+),(.+)/", self.url)
        if not place_re:
            return None
        lat = float(place_re.group(2))
        long = float(place_re.group(3))
        place = urllib.parse.unquote(place_re.group(1).replace("+", " "))
        return GeocodedPlace(lat, long, place)


class ShopGeocodingService:
    def __init__(self, shop: Shop, save=True):
        self.shop = shop
        self.save = save

    def get_geocoded_place(self) -> Optional[GeocodedPlace]:
        return GeocodingUrlParser(self.shop.maps_url).parse()

    def run(self) -> Tuple[Shop, bool]:
        if not self.shop.maps_url:
            return self.shop, False

        geocoded_place = self.get_geocoded_place()
        if not geocoded_place:
            return self.shop, False
        self.shop.update_with_geocoded_place(geocoded_place, save=self.save)
        return self.shop, True


class StatisticsResolverService:
    @classmethod
    def _execute_sql(cls, query, args=()):
        with connection.cursor() as cursor:
            cursor.execute(query, args)
            return cursor.fetchall()

    @classmethod
    def get_the_most_ofted_fired_employee(cls, year=None):
        year = year or timezone.now().year - 1
        result = CustomUser.objects.raw(
            """
        SELECT "accounts_customuser"."id",
        "accounts_customuser"."first_name",
        "accounts_customuser"."last_name",
        COUNT("shops_employment"."id") AS "fired_count"
        FROM "accounts_customuser"
                 LEFT OUTER JOIN "shops_employment" ON
                ("accounts_customuser"."id" = "shops_employment"."user_id")
        WHERE extract('year' from upper(timespan)) = %s
        GROUP BY "accounts_customuser"."id"
        order by fired_count limit 1;
        """,
            (year,),
        )
        return result[0]

    @classmethod
    def get_most_profitable_shop(cls, year):
        return Shop.objects.raw(
            """SELECT "shops_shop"."id",
       "shops_shop"."slug",
       "shops_shop"."place_name",
       "shops_shop"."reference",
       SUM("shops_income"."value") AS "total_income"
        FROM "shops_shop"
                 LEFT OUTER JOIN "shops_income" ON ("shops_shop"."id" = "shops_income"."shop_id")
        WHERE extract('year' from "shops_income"."when") = %s
        GROUP BY "shops_shop"."id"
        ORDER BY "total_income" limit 1""",
            (year,),
        )[0]

    @classmethod
    def get_employer_with_most_dynamic_salary(cls, year):
        return CustomUser.objects.raw("""SELECT "accounts_customuser"."id",
       "accounts_customuser"."first_name",
       "accounts_customuser"."last_name",
       min(lower(se.timespan)) as first_employment_date,
       now()::date as current_employment_time,
       Min("shops_salary"."value") as "min_salary",
        Max("shops_salary"."value") as "max_salary",
       Max("shops_salary"."value") - MIN("shops_salary"."value") AS "delta"
        FROM "accounts_customuser"
                 LEFT OUTER JOIN "shops_salary" ON ("accounts_customuser"."id" = "shops_salary"."employee_id")
                 INNER JOIN shops_employment se on accounts_customuser.id = se.user_id where extract('year' from "shops_salary"."when") = %s
        GROUP BY "accounts_customuser"."id"
        ORDER BY delta DESC limit 1;
        """, (year,))[0]

    @classmethod
    def get_shop_with_most_new_employees(cls, year):
        return Shop.objects.raw("""SELECT "shops_shop"."id",
       "shops_shop"."slug",
       "shops_shop"."place_name",
       COUNT("shops_employment"."id") AS "new_employments"
        FROM "shops_shop"
                 LEFT OUTER JOIN "shops_employment" ON ("shops_shop"."id" = "shops_employment"."shop_id")
        where extract('year' from (lower(timespan))) = %s
        GROUP BY "shops_shop"."id"
        ORDER BY new_employments DESC limit 1;
        """, (year,))[0]

    @classmethod
    def get_most_stable_shop(cls, year):
        return Shop.objects.raw("""
        SELECT "shops_shop"."id",
               "shops_shop"."slug",
               "shops_shop"."place_name",
               COUNT("shops_employment"."id") filter (where extract('year' from lower(timespan)) = 2021 or extract('year' from upper(timespan)) = 2021) AS "changed_employments"
        FROM "shops_shop"
                 LEFT OUTER JOIN "shops_employment" ON ("shops_shop"."id" = "shops_employment"."shop_id")
        GROUP BY "shops_shop"."id"
        ORDER BY changed_employments limit 1
        """)[0]

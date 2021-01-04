# Generated by Django 3.1.4 on 2021-01-05 09:26

import django.contrib.gis.db.models.fields
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('shops', '0004_salary_value'),
    ]

    operations = [
        migrations.AlterField(
            model_name='shop',
            name='location',
            field=django.contrib.gis.db.models.fields.PointField(blank=True, geography=True, null=True, srid=4326),
        ),
    ]
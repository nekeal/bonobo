from .base import *

DATABASES = {
    "default": {
        "ENGINE": "django.contrib.gis.db.backends.postgis",
        "NAME": os.environ.get("POSTGRES_DB", "bonobo"),
        "USER": os.environ.get("POSTGRES_USER", "bonobo"),
        "PASSWORD": os.environ.get("POSTGRES_PASSWORD", "bonobo"),
        "HOST": os.environ.get("POSTGRES_HOST", "localhost"),
    }
}
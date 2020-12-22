from .base import *

INTERNAL_IPS = [
    "127.0.0.1",
]

DATABASES = {
    "default": {
        "ENGINE": "django.contrib.gis.db.backends.postgis",
        "NAME": os.environ.get("POSTGRES_DB", "bonobo"),
        "USER": os.environ.get("POSTGRES_USER", "bonobo"),
        "PASSWORD": os.environ.get("POSTGRES_PASSWORD", "bonobo"),
        "HOST": os.environ.get("POSTGRES_HOST", "localhost"),
    }
}

INSTALLED_APPS.insert(0, "debug_toolbar")
MIDDLEWARE.insert(0, "debug_toolbar.middleware.DebugToolbarMiddleware")

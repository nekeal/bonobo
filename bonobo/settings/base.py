"""
Django settings for bonobo project.

Generated by 'django-admin startproject' using Django 3.1.4.

For more information on this file, see
https://docs.djangoproject.com/en/3.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.1/ref/settings/
"""
import os
from pathlib import Path

from dotenv import load_dotenv

PROJECT_NAME = "bonobo"

BASE_DIR = Path(__file__).parents[2]

SECRET_KEY = ")87onm69)=1ex#s0-dv7d_b=g9n@gpoc&c$g7k0p=h(#d6k32l"

DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = [
    "jazzmin",
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django.contrib.gis",
    "django_extensions",
    "bonobo.accounts",
    "bonobo.shops",
    "bonobo.common",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "bonobo.urls"

AUTH_USER_MODEL = "accounts.CustomUser"

JAZZMIN_SETTINGS = {
    # title of the window
    "site_title": "Bonobo Admin",
    # Title on the login screen
    "site_header": "Bonobo",
    # square logo to use for your site, must be present in static files, used for favicon and brand on top left
    "site_logo": "img/logo.png",
    # Welcome text on the login screen
    "welcome_sign": "Welcome to bonobo",
    # Copyright on the footer
    "copyright": "nekeal, SirPatrykKawa",
    # The model admin to search from the search bar, search bar omitted if excluded
    "search_model": "accounts.User",
    # Field name on user model that contains avatar image
    "user_avatar": None,
    # Links to put along the top menu
    "topmenu_links": [
        # Url that gets reversed (Permissions can be added)
        {"name": "Home", "url": "admin:index", "permissions": ["auth.view_user"]},
        # external url that opens in a new window (Permissions can be added)
        {
            "name": "Support",
            "url": "https://github.com/farridav/django-jazzmin/issues",
            "new_window": True,
        },
        # model admin to link to (Permissions checked against model)
        {"model": "accounts.User"},
        # App with dropdown menu to all its models pages (Permissions checked against models)
        {"app": "shops"},
    ],
    # Whether to display the side menu
    "show_sidebar": True,
    # Whether to aut expand the menu
    "navigation_expanded": True,
    # Hide these apps when generating side menu
    "hide_apps": [],
    # Hide these models when generating side menu
    "hide_models": [],
    # List of apps to base side menu ordering off of
    "order_with_respect_to": ["accounts"],
    # Custom links to append to app groups, keyed on app name
    "custom_links": {},
    # Custom icons per model in the side menu See https://www.fontawesomecheatsheet.com/font-awesome-cheatsheet-5x/
    # for a list of icon classes
    "icons": {
        "auth.Group": "fas fa-users",
        "accounts.CustomUser": "fas fa-user",
        "shops.Shop": "fas fa-store",
        "shops.Income": "fas fa-dollar-sign",
        "shops.Employment": "fas fa-user-cog",
        "shops.Salary": "fas fa-money-bill",
    },
}

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [
            BASE_DIR.joinpath("templates"),
        ],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "bonobo.wsgi.application"


# Database
# https://docs.djangoproject.com/en/3.1/ref/settings/#databases

# Password validation
# https://docs.djangoproject.com/en/3.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]


# Internationalization
# https://docs.djangoproject.com/en/3.1/topics/i18n/

LANGUAGE_CODE = "en-us"

TIME_ZONE = "Europe/Warsaw"

USE_I18N = True

USE_L10N = True

USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.1/howto/static-files/

STATICFILES_DIRS = [
    "static",
]

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR.joinpath("public")
MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR.joinpath("media")

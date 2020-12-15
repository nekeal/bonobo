# pull official base image
FROM python:3.8-slim

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install libs
RUN apt-get update && \
    apt-get install -y gdal-bin --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# set work directory
WORKDIR /app

# install dependencies
ADD requirements.txt ./
RUN pip install -r requirements.txt
ADD . ./
RUN python manage.py collectstatic --noinput
EXPOSE 8000
CMD python manage.py migrate && \
    python manage.py runserver 0.0.0.0:8000

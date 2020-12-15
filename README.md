# Bonobo

Super simple chain of shops manager.

## Getting Started

### virtualenv
Setup project environment with [virtualenv](https://virtualenv.pypa.io) and [pip](https://pip.pypa.io).

```bash
$ git clone https://github.com/nekeal/bonobo.git
$ cd bonobo
$ virtualenv venv
$ source venv/bin/activate
$ make bootstrap

$ python manage.py migrate
$ python manage.py runserver
```

### docker-compose

You can also develop using docker-compose. 

    $ make bootstrap-docker

## Contributing

I appreciate contributions, so please feel free to fix bugs, improve app and provide documentation.
Just make a pull request.

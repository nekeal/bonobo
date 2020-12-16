.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

TAGS := -t $(DOCKER_REGISTRY):$(shell git rev-parse HEAD) -t $(DOCKER_REGISTRY):$(shell git rev-parse --abbrev-ref HEAD)

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -f coverage.xml
	rm -fr htmlcov/
	rm -fr .pytest_cache

test: ## run tests quickly with the default Python
	pytest

test-all: ## run tests on every Python version with tox
	tox

coverage: ## check code coverage quickly with the default Python
	pytest --cov=bonobo
	run coverage report -m
	coverage html
	$(BROWSER) htmlcov/index.html

quality-check: ## check quality of code
	black --check bonobo
	isort --check bonobo
	flake8 bonobo
	mypy bonobo

autoformatters: ## runs auto formatters
	black bonobo
	isort bonobo

bootstrap:  ## install requirements
	pip install -r requirements-dev.txt
	python manage.py migrate
	python manage.py loaddata fixtures/*

rebuild-db:  ## recreates database with fixtures
	echo yes | python manage.py reset_db
	python manage.py migrate
	python manage.py loaddata fixtures/*

bootstrap-docker:  ## install requirements
	docker-compose up -d
	docker-compose exec web python manage.py loaddata fixtures/*

docker-build:  ## hi
	git stash --quiet
	docker build $(TAGS) .
	git stash pop --quiet | true

docker-push:
	docker push $(DOCKER_REGISTRY)

#
# DEVELOPMENT targets
#

.PHONY: up
up: ##
	## Start the application in development mode
	docker-compose -f docker-compose.yml -f docker-compose.dev-override.yml up --build -d

.PHONY: down
down: ##
	## Stop the application
	docker-compose -f docker-compose.yml -f docker-compose.dev-override.yml down

.PHONY: reload
reload: ##
	## Reload (stop and start) the application in development mode
	make down
	make up

.PHONY: status
status: ##
	## Get status of running containers
	docker-compose -f docker-compose.yml ps

.PHONY: clean
clean: ##
	## Clean intermediary build files
	find . -path ./.venv -prune -o -name '*.pyc' -print -exec rm -rf -- "{}" +
	find . -path ./.venv -prune -o -name '__pycache__' -print -exec rm -rf -- "{}" +
	find . -path ./.venv -prune -o -name '.cache' -print -exec rm -rf -- "{}" +
	find . -path ./.venv -prune -o -name '.pytest_cache' -print -exec rm -rf -- "{}" +
	find . -path ./.venv -prune -o -name '.mypy_cache' -print -exec rm -rf -- "{}" +

.PHONY: help
help: ##
	## Shows this help menu
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'


#
# TEST targets
#

.PHONY: test
test: ## 
	## Run tests and generate code coverage 
	docker-compose -f docker-compose.yml -f docker-compose.dev-override.yml build api
	docker-compose run -v $(shell pwd)/out:/out -v $(shell pwd)/tests/:/app/tests \
		--rm api pytest -vv -l --doctest-modules \
		--cov=./fake-api --cov-report term-missing \
		--cov-report xml:/out/test-coverage.xml --cov-report html:/out/test-coverage-html \
		--junitxml=/out/test-results.xml \
		./tests/
	docker-compose run -v $(shell pwd)/out:/out --rm api coverage2clover -i /out/test-coverage.xml \
		-o /out/test-coverage-clover.xml

.PHONY: lint
lint: ## 
  ## Run lint check on application code
	docker-compose -f docker-compose.yml -f docker-compose.dev-override.yml build api
	## NOTE: We execute these linters in a special way by passing the full command to bash.  This is
	##       necessary because you apparently can't pass a pipe ('|') to docker run, and we need
	##       the tee command to happen in the context of the container, otherwise will happen
	##       in the context of the host machine which may not have the appropriate permissions.
	## @see https://stackoverflow.com/questions/30072544/pipeline-in-docker-exec-from-command-line-and-from-python-api
	docker-compose run -v $(shell pwd)/out:/out -v $(shell pwd)/tests/:/app/tests --rm api /bin/bash -c \
		"pylint --output-format=pylint_junit.JUnitReporter fake-api tests | tee /out/lint-results.xml"

.PHONY: type-check
type-check: ##
	## Run static type check on application code
	docker-compose -f docker-compose.yml -f docker-compose.dev-override.yml build api
	docker-compose run -v $(shell pwd)/out:/out -v $(shell pwd)/tests/:/app/tests \
		--rm api mypy --junit-xml /out/typecheck-results.xml fake-api tests

#
# CONTAINER targets
#

.PHONY: connect-api
connect-api: ##
	## Connect a bash terminal session to the API server container
	docker exec -it flask-api /bin/bash

.PHONY: connect-worker
connect-worker: ##
	## Connect a bash terminal session to the Celery worker container
	docker exec -it flask-worker /bin/bash

.PHONY: connect-queue
connect-queue: ##
	## Connect a bash terminal session to the Redis queue container
	docker exec -it flask-queue /bin/bash

.PHONY: log-api
log-api: ##
	## Tail the logs of API server container
	docker logs flask-api -f

.PHONY: log-worker
log-worker: ##
	## Tail the logs of the Celery worker container
	docker logs flask-worker -f

.PHONY: log-queue
log-queue: ##
	## Tail the logs of the Redis queue container
	docker logs flask-queue -f 


#
# REDIS targets
#

.PHONY: start-queue
start-queue: ##
	## Start Redis queue.  Useful for when you want to debug locally, and need the queue running.
	## NOTE: This will take down the application if it is still running.
	make down
	docker-compose -f docker-compose.yml -f docker-compose.dev-override.yml up queue

.PHONY: redis-cli
redis-cli: ##
	## Start shell session with local Redis instance
	docker-compose exec queue redis-cli

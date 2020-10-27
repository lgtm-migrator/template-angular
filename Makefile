.DEFAULT_GOAL := help
STACK         := angular
NETWORK       := proxynetwork
WWW           := $(STACK)_www
WWWFULLNAME   := $(WWW).1.$$(docker service ps -f 'name=$(PRWWWOXY)' $(WWW) -q --no-trunc | head -n1)

%:
	@:

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

apps/node_modules:
	cd apps
	npm install

contributors: node_modules ## Contributors
	@npm run contributors

contributors-add: node_modules ## add Contributors
	@npm run contributors add

contributors-check: node_modules ## check Contributors
	@npm run contributors check

contributors-generate: node_modules ## generate Contributors
	@npm run contributors generate

docker-create-network: ## create network
	docker network create --driver=overlay $(NETWORK)

docker-deploy: ## deploy
	docker stack deploy -c docker-compose.yml $(STACK)

docker-image-pull: ## Get docker image
	docker image pull koromerzhin/angular:latest

docker-logs: ## logs docker
	docker service logs -f --tail 100 --raw $(WWWFULLNAME)

docker-service-ls: ## docker service
	@docker service ls

docker-stack-ps: ## docker stack ps
	@docker stack ps $(STACK)

docker-showstack: ## Show stack
	@make docker-stack-ps -i
	@make docker-service-ls -i

git-commit: node_modules ## Commit data
	npm run commit

git-check: node_modules ## CHECK before
	@make contributors-check -i
	@git status

install: apps/node_modules ## Installation
	@make docker-create-network -i
	@make docker-deploy -i

linter-readme: node_modules ## linter README.md
	@npm run linter-readme README.md

node_modules: ## npm install
	npm install

ssh: ## ssh
	docker exec -ti $(WWWFULLNAME) /bin/bash
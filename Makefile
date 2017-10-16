PROJECT:=nserv
REPO:=kkasravi/$(PROJECT)
VERSION=latest
IMAGE:=$(REPO):$(VERSION)

.PHONY:  build run schemas

all: build

build:
	@echo building
	@docker build --no-cache -t $(IMAGE) .

debug: env-up
	@docker-compose exec --privileged nserv env GODEBUGGER=$(GODEBUGGER) /go/src/github.com/nervanasystems/nserv/scripts/godebug attach bin/apiserver

dev: env-up
	@echo "create shell in $(IMAGE) ..."
	@docker-compose exec --privileged nserv /bin/bash -l

env-down:
	@echo "Stopping nserv"
	@docker-compose down

env-api:
	@echo "Starting image $(IMAGE) ..."
	@docker-compose run nserv /bin/bash

env-up:
	@scripts/env-up $(IMAGE) 

local-source: env-up
	@echo "Copying down cmd/, pkg/, sample/, vendor/ ..."
	@docker cp $(shell docker-compose ps -q):/go/src/github.com/nervanasystems/nserv/cmd .
	@docker cp $(shell docker-compose ps -q):/go/src/github.com/nervanasystems/nserv/pkg .
	@docker cp $(shell docker-compose ps -q):/go/src/github.com/nervanasystems/nserv/sample .
	@docker cp $(shell docker-compose ps -q):/go/src/github.com/nervanasystems/nserv/vendor .

logs: env-up
	@echo "Fetch logs for $(IMAGE) ..."
	@docker-compose logs -f nserv

validate: env-up
	@kubectl --kubeconfig=kubeconfig api-versions

create-supervisor: env-up
	@docker-compose exec nserv kubectl --kubeconfig=kubeconfig create -f sample/supervisor.yaml

get-supervisor: env-up
	@docker-compose exec nserv kubectl --kubeconfig=kubeconfig get supervisor tfcluster -oyaml

delete-supervisor: env-up
	@docker-compose exec nserv kubectl --kubeconfig=kubeconfig delete supervisor tfcluster

clean:
	@echo "Removing image $(IMAGE) ..."
	@docker rmi $(IMAGE) --force

scrub:
	@echo "Removing <none> image ..."
	@docker images | grep '<none>' | awk '{print $$3}' | xargs docker rmi --force

schemas: env-up
	@echo Generating schemas
	@docker-compose exec -d -T nserv kubectl --kubeconfig=kubeconfig proxy
	@docker-compose exec nserv openapi2jsonschema http://127.0.0.1:8001/swagger.json
	@docker-compose exec nserv pkill kubectl
	@docker cp $(shell docker-compose ps -q):/go/src/github.com/nervanasystems/nserv/schemas .

test: env-up
	@echo Running tests
	@docker-compose exec nserv go test ./pkg/...

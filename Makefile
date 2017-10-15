PROJECT:=nserv
REPO:=kkasravi/$(PROJECT)
VERSION=latest
IMAGE:=$(REPO):$(VERSION)

.PHONY:  build run schemas

all: build

build:
	@echo building
	@docker build -t $(IMAGE) .

debug:
	@docker-compose exec --privileged nserv env GODEBUGGER=$(GODEBUGGER) /go/src/github.com/nervanasystems/nserv/scripts/godebug attach bin/apiserver

dev:
	@echo "create shell in $(IMAGE) ..."
	@docker-compose exec --privileged nserv /bin/bash -l

env-down:
	@echo "Stopping nserv"
	@docker-compose down

env-api:
	@echo "Starting image $(IMAGE) ..."
	@docker-compose run nserv /bin/bash

env-up:
	@echo "Bringing up apiserver $(IMAGE) ..."
	@docker-compose up -d
	@docker-compose ps

logs:
	@echo "Fetch logs for $(IMAGE) ..."
	@docker-compose logs -f nserv

validate:
	@kubectl --kubeconfig=kubeconfig api-versions

create-cluster:
	@docker-compose exec nserv kubectl --kubeconfig=kubeconfig create -f sample/cluster.yaml

get-cluster:
	@docker-compose exec nserv kubectl --kubeconfig=kubeconfig get cluster tfcluster -oyaml

delete-cluster:
	@docker-compose exec nserv kubectl --kubeconfig=kubeconfig delete cluster tfcluster

clean:
	@echo "Removing image $(IMAGE) ..."
	@docker rmi $(IMAGE)

scrub:
	@echo "Removing <none> image ..."
	@docker images | grep '<none>' | awk '{print $$3}' | xargs docker rmi --force

schemas:
	@echo Generating schemas
	@docker-compose exec -d -T nserv kubectl --kubeconfig=kubeconfig proxy
	@docker-compose exec nserv openapi2jsonschema http://127.0.0.1:8001/swagger.json
	@docker-compose exec nserv pkill kubectl

test:
	@echo Running tests
	@docker-compose exec nserv go test ./pkg/...

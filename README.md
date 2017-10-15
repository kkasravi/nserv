# nserv

nserv is easily built on a mac but runs everything in docker containers. It can also be built on other platforms. nserv has leveraged the kubernetes [apiserver-builder](https://github.com/kubernetes-incubator/apiserver-builder) to create the basic scaffolding of a User Api Server `[UAS]`

## Prerequisites
- docker client for mac [Docker](https://www.docker.com/docker-mac)


## Installation
1. `cd $GOPATH/src/github.com/nervanasystems/nserv`
2. `git clone git@github.com:kkasravi/nerv.git`

## Building
1. `cd $GOPATH/src/github.com/nervanasystems/nserv`
1. `make build`

## Running
1. `cd $GOPATH/src/github.com/nervanasystems/nserv`
2. `make env-up`

## Example
1. `cd $GOPATH/src/github.com/nervanasystems/nserv`
2. `make create-cluster`
3. `make get-cluster`
4. `make delete-cluster`

## Stopping
1. `cd $GOPATH/src/github.com/nervanasystems/nserv`
2. `make env-down`

FROM golang:1.9.1

ENV GODEBUGGER=gdb
ENV GOPATH=/go

RUN apt-get update && apt-get install -y \
  netcat \
  python-pip \
  apt-transport-https \
  ca-certificates \
  software-properties-common \
  gnupg2 \
  gdb \
  vim

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

RUN echo "deb [arch=amd64] https://download.docker.com/linux/debian jessie stable" | tee /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y \
  docker-ce=17.09.0~ce-0~debian

RUN go get -u github.com/derekparker/delve/cmd/dlv
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl
WORKDIR /usr/local
RUN curl -LO https://github.com/kubernetes-incubator/apiserver-builder/releases/download/v0.1-alpha.19/apiserver-builder-v0.1-alpha.19-linux-amd64.tar.gz
RUN tar xf apiserver-builder-v0.1-alpha.19-linux-amd64.tar.gz && rm apiserver-builder-v0.1-alpha.19-linux-amd64.tar.gz

WORKDIR /tmp
RUN curl -LO https://github.com/coreos/etcd/releases/download/v3.2.9/etcd-v3.2.9-linux-amd64.tar.gz
RUN tar xf etcd-v3.2.9-linux-amd64.tar.gz 
RUN mv etcd-v3.2.9-linux-amd64/etcd /usr/local/bin
RUN mv etcd-v3.2.9-linux-amd64/etcdctl /usr/local/bin
RUN rm -rf etcd-v3.2.9-linux-amd64

RUN pip install openapi2jsonschema
RUN mkdir -p /go/src/github.com/nervanasystems
ADD . /go/src/github.com/nervanasystems/nserv
WORKDIR /go/src/github.com/nervanasystems/nserv
RUN scripts/create
CMD /bin/bash

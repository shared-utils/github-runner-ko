FROM ghcr.io/actions/actions-runner:latest

USER root
RUN apt-get update && apt-get install -y \
    curl git jq ca-certificates wget

# Install Go
RUN wget https://go.dev/dl/go1.25.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz && \
    rm go1.25.0.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/runner/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Install kubectl
RUN curl -Lo /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install ko
RUN curl -sfL https://github.com/ko-build/ko/releases/latest/download/ko_Linux_x86_64.tar.gz \
    | tar -xz -C /usr/local/bin/

USER runner
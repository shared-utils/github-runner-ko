FROM ghcr.io/actions/actions-runner:latest

USER root
RUN apt-get update && apt-get install -y \
    curl git jq ca-certificates

# Install kubectl (needed for ko apply)
RUN curl -Lo /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install ko
RUN curl -sfL https://github.com/ko-build/ko/releases/latest/download/ko_Linux_x86_64.tar.gz \
    | tar -xz -C /usr/local/bin/

USER runner
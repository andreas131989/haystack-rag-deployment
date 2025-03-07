# Use Ubuntu 20.04 as the base image
FROM ubuntu:20.04

LABEL maintainer="Andreas Krivas <an.krivas@gmail.com>" \
      description="Production-grade environment for deploying Haystack RAG with k3s/k3d, kubectl, and Helm."

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Docker CLI in one layer, then clean up to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        wget \
        ca-certificates \
        bash \
        sudo \
        apt-transport-https \
        gnupg2 \
        docker.io && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl (latest stable release)
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Helm using the official installation script
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install k3d using its official installation script
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Set the working directory and create a persistent directory for kubeconfig
WORKDIR /app
RUN mkdir -p /app/config

# Copy the repository files into the container
COPY . .

# Automatically set KUBECONFIG in bashrc so that new shells know where to find it.
RUN echo 'export KUBECONFIG=/app/config/kubeconfig.yaml' >> ~/.bashrc

# Set the default command to run the deploy script, then drop into an interactive shell.
CMD ["bash", "-c", "./scripts/deploy.sh && exec bash"]

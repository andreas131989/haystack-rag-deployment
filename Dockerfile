# Deployment container with all necessary tools

FROM ubuntu:20.04 as deploy-container
LABEL maintainer="Andreas Krivas <an.krivas@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and Docker CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    chmod +x kubectl && mv kubectl /usr/local/bin/

# Install Helm using the official script
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install k3d using its official installation script
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create working directory and persistent config directory
WORKDIR /app
RUN mkdir -p /app/config

# Copy deployment scripts and Kubernetes manifests
COPY scripts/ scripts/
COPY kubernetes/ kubernetes/

# Ensure new shells automatically export KUBECONFIG
RUN echo 'export KUBECONFIG=/app/config/kubeconfig.yaml' >> ~/.bashrc

# Set the default command to run the deploy script and then drop into a shell
CMD ["bash", "-c", "./scripts/deploy.sh && exec bash"]

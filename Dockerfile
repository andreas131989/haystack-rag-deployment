FROM ubuntu:20.04
LABEL maintainer="Andreas Krivas <an.krivas@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl \
      git \
      wget \
      ca-certificates \
      bash \
      sudo \
      gettext-base \
      apt-transport-https \
      gnupg2 \
      docker.io && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl, Helm, and k3d
RUN set -ex && \
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt) && \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && mv kubectl /usr/local/bin/ && \
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash && \
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create working directory and persistent config directory
WORKDIR /app
RUN mkdir -p /app/config

# Copy deployment assets into the container
COPY scripts/ scripts/
COPY release/ release/
COPY kubernetes-static-routing/ kubernetes-static-routing/
COPY charts/ charts/
COPY cert-manager/ cert-manager/

# Ensure new shells automatically export KUBECONFIG
RUN echo 'export KUBECONFIG=/app/config/kubeconfig.yaml' >> /root/.bashrc

# Set the default command and source env variables
CMD ["bash", "-c", "if [ -f /app/config/.env ]; then source /app/config/.env; fi && ./scripts/deploy.sh && exec bash"]

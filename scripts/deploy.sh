#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*"
}

CLUSTER_NAME="haystack-cluster"

# Create k3d cluster if it doesn't exist
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    log "Cluster '$CLUSTER_NAME' already exists. Skipping creation."
else
    log "Creating k3d cluster '$CLUSTER_NAME'..."
    k3d cluster create "$CLUSTER_NAME" --wait
fi

# Write kubeconfig to persistent location
KUBECONFIG_FILE="/app/config/kubeconfig.yaml"
log "Writing kubeconfig to $KUBECONFIG_FILE..."
k3d kubeconfig get "$CLUSTER_NAME" > "$KUBECONFIG_FILE"
export KUBECONFIG="$KUBECONFIG_FILE"
log "Cluster '$CLUSTER_NAME' is active. KUBECONFIG set to $KUBECONFIG_FILE."

# Import the locally built images into the cluster.
log "Importing images into k3d cluster..."
k3d image import backend-indexing:local -c "$CLUSTER_NAME"
k3d image import backend-query:local -c "$CLUSTER_NAME"
k3d image import frontend:local -c "$CLUSTER_NAME"

# Deploy Kubernetes manifests from the kubernetes/ directory
log "Deploying Kubernetes manifests..."
kubectl apply -R -f kubernetes/

# Wait for deployments to be ready
# log "Waiting for deployments to be ready..."
# kubectl rollout status deployment/haystack-rag-backend-query -n default --timeout=120s
# kubectl rollout status deployment/haystack-rag-backend-indexing -n default --timeout=120s
# kubectl rollout status deployment/haystack-rag-frontend -n default --timeout=120s

log "Deployment complete! You can now interact with your cluster."

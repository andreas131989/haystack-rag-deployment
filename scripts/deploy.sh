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
    k3d cluster create "$CLUSTER_NAME" --wait \
      --port '32090:32090@server:0' \
      --port '32091:32091@server:0'
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

# Deploy Helm charts from the charts/ directory in the haystack namespace
kubectl create ns haystack
log "Deploying Helm chart 'haystack'..."
helm upgrade --install haystack ./charts --namespace haystack

# Wait for helm deployments to be ready
log "Waiting for helm Haystack release to be ready..."
kubectl rollout status deployment/haystack-rag-backend-query -n haystack --timeout=300s
kubectl rollout status deployment/haystack-rag-backend-indexing -n haystack --timeout=300s
kubectl rollout status deployment/haystack-rag-frontend -n haystack --timeout=300s

log "Deployment complete! You can now interact with your cluster."

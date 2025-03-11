#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*"
}

CLUSTER_NAME="haystack-cluster"

if [ ! -f /app/config/.env ]; then
    echo "Error: .env not found. Exiting." >&2
    exit 1
fi

# Create k3d cluster if it doesn't exist
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    log "Cluster '$CLUSTER_NAME' already exists. Skipping creation."
else
    log "Creating k3d cluster '$CLUSTER_NAME'..."
    k3d cluster create "$CLUSTER_NAME" --servers 1 --agents 1 --wait \
      --port '32080:32080@server:0' \
      --port '32081:32081@server:0' \
      --port '32090:32090@server:0' \
      --port '32091:32091@server:0' \
      --port '32092:32092@server:0' \
      --k3s-arg "--service-cidr=10.100.0.0/16@server:0"

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

# Deploy cert-manager and cluster issuer
log "Deploying cert-manager..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.9.1 --set installCRDs=true
kubectl apply -f cert-manager/cluster-issuer.yaml

# Deploy Helm charts from the charts/ directory in the haystack namespace
log "Deploying Helm chart 'haystack'..."
export $(cat /app/config/.env | xargs)
helm upgrade --install haystack ./charts --namespace haystack --create-namespace \
  --set secrets.openaiApiKey="$OPENAI_KEY" \
  --set secrets.opensearchPassword="$OPENSEARCH_PASSWORD" \
  --set secrets.opensearchUser="$OPENSEARCH_USER"

# Wait for helm deployments to be ready
log "Waiting for helm Haystack release to be ready..."
# kubectl rollout status deployment/haystack-rag-backend-query -n haystack --timeout=300s
# kubectl rollout status deployment/haystack-rag-backend-indexing -n haystack --timeout=300s
# kubectl rollout status deployment/haystack-rag-frontend -n haystack --timeout=300s

log "Deployment complete! You can now interact with your cluster."

#!/bin/bash
set -euo pipefail

# Logging function for consistent output
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*"
}

# Define the cluster name
CLUSTER_NAME="haystack-cluster"

# Check if the k3d cluster already exists; if not, create it.
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    log "Cluster '$CLUSTER_NAME' already exists. Skipping creation."
else
    log "Creating k3d cluster '$CLUSTER_NAME'..."
    k3d cluster create "$CLUSTER_NAME" --wait
fi

# Write the kubeconfig output to a persistent file (in /app/config)
KUBECONFIG_FILE="/app/config/kubeconfig.yaml"
log "Writing kubeconfig to $KUBECONFIG_FILE..."
k3d kubeconfig get "$CLUSTER_NAME" > "$KUBECONFIG_FILE"
export KUBECONFIG="$KUBECONFIG_FILE"
log "Cluster '$CLUSTER_NAME' is active. KUBECONFIG is set to $KUBECONFIG_FILE."

# Wait for all nodes to become ready
log "Waiting for all cluster nodes to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=120s

log "k3d cluster '$CLUSTER_NAME' is up and running."

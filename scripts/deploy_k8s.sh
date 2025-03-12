#!/bin/bash
set -euo pipefail

log() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $*"
}

# Deploy k8s manifests 
log "Deploying k8s release manifests..."

# Load environment variables from .env
export $(cat /app/config/.env | xargs)

# Preprocess only the Secret files with envsubst
find /app/release/rag/templates/ -name "secrets.yaml" -exec sh -c 'envsubst < {} > {}.tmp && mv {}.tmp {}' \;

# Apply all manifests in the directory recursively in default namespace
kubectl apply -R -f /app/release/


# Wait for k8s deployments to be ready
log "Waiting for kubernetes deployment to be ready..."
kubectl rollout status deployment/haystack-rag-backend-query -n default --timeout=300s
kubectl rollout status deployment/haystack-rag-backend-indexing -n default --timeout=300s
kubectl rollout status deployment/haystack-rag-frontend -n default --timeout=300s

log "Deployment of kubernetes manifests completed!"
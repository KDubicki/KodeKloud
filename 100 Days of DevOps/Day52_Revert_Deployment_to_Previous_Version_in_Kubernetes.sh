# !/bin/bash

# =================================================================
# Check History
# =================================================================
kubectl rollout history deployment/nginx-deployment

# =================================================================
# Rollback
# =================================================================
kubectl rollout undo deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment

# =================================================================
# Verify
# =================================================================
kubectl get pods
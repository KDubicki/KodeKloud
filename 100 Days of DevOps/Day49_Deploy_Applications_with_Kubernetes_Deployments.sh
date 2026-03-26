# !/bin/bash

# =================================================================
# Create the Deployment
# =================================================================
kubectl create deployment httpd --image=httpd:latest

# =================================================================
# Verify
# =================================================================
# Check the deployment status
kubectl get deployments
# Check the actual pod that the deployment spun up
kubectl get pods


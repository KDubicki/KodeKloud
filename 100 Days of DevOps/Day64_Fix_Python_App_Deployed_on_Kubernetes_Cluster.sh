# !/bin/bash

# =================================================================
# Fix the Deployment Image
# =================================================================
kubectl set image deployment/python-deployment-xfusion python-container-xfusion=poroko/flask-demo-app

# =================================================================
# Find the Service Name
# =================================================================
kubectl get svc

# =================================================================
# Extract and Fix the Service
# =================================================================
kubectl get svc python-service-xfusion -o yaml > fix-svc.yaml
nano fix-svc.yaml

"""
ports:
  - nodePort: 32345     (This was requested in the task)
    port: 5000          (Flask's default port)
    protocol: TCP
    targetPort: 5000
"""

# =================================================================
# Apply the Fixed Service
# =================================================================
kubectl apply -f fix-svc.yaml

# =================================================================
# Verify
# =================================================================
kubectl get pods
curl -I http://localhost:32345
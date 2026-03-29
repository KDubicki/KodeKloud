# !/bin/bash

# =================================================================
# Create the Combined YAML File
# =================================================================
cat << 'EOF' > web-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx-app
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30011
EOF

# =================================================================
# Deploy the Architecture
# =================================================================
kubectl apply -f web-deployment.yaml

# =================================================================
# Verify the Deployment and Replicas
# =================================================================
kubectl get deployments
kubectl get pods

# =================================================================
# Verify
# =================================================================
kubectl get svc nginx-service
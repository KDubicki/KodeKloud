# !/bin/bash

# =================================================================
# Create the Combined Configuration File
# =================================================================
cat << 'EOF' > grafana-setup.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana-deployment-datacenter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana-container
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
    - port: 3000
      targetPort: 3000
      nodePort: 32000
EOF

# =================================================================
# Deploy the Architecture
# =================================================================
kubectl apply -f grafana-setup.yaml

# =================================================================
# Verify
# =================================================================
kubectl get all -l app=grafana
kubectl get pods
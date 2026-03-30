# !/bin/bash

# =================================================================
# Create the Unified Configuration File
# =================================================================
cat << 'EOF' > redis-setup.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
data:
  redis-config: "maxmemory 2mb"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis-container
        image: redis:alpine
        ports:
        - containerPort: 6379
        resources:
          requests:
            cpu: "1"
        volumeMounts:
        - name: data
          mountPath: /redis-master-data
        - name: redis-config
          mountPath: /redis-master
      volumes:
      - name: data
        emptyDir: {}
      - name: redis-config
        configMap:
          name: my-redis-config
EOF

# =================================================================
# Deploy
# =================================================================
kubectl apply -f redis-setup.yaml

# =================================================================
# Verify
# =================================================================
kubectl get pods
kubectl describe configmap my-redis-config
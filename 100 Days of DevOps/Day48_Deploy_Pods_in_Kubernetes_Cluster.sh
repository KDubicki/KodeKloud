# !/bin/bash

# =================================================================
# Create the YAML File
# =================================================================
cat << 'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-nginx
  labels:
    app: nginx_app
spec:
  containers:
  - name: nginx-container
    image: nginx:latest
EOF

# =================================================================
# Apply the Configuration
# =================================================================
kubectl apply -f pod.yaml

# =================================================================
# Verify
# =================================================================
# 1. Check if the pod is in a 'Running' state
kubectl get pods
# 2. Verify the label was applied correctly
kubectl get pods --show-labels
# 3. Verify the container inside the pod has the correct name
kubectl describe pod pod-nginx | grep -A 2 "Containers:"
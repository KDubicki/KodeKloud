# !/bin/bash

# =================================================================
# Create the YAML Configuration File
# =================================================================
cat << 'EOF' > httpd-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpd-pod
spec:
  containers:
  - name: httpd-container
    image: httpd:latest
    resources:
      requests:
        memory: "15Mi"
        cpu: "100m"
      limits:
        memory: "20Mi"
        cpu: "100m"
EOF

# =================================================================
# Apply the Configuration
# =================================================================
kubectl apply -f httpd-pod.yaml

# =================================================================
# Verify
# =================================================================
# Check that the pod is running
kubectl get pods
# Inspect the pod details to verify the limits and requests
kubectl describe pod httpd-pod | grep -A 5 "Limits:"
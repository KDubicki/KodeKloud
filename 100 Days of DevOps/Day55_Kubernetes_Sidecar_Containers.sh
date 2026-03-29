# !/bin/bash

# =================================================================
# Create the Pod Configuration File
# =================================================================
cat << 'EOF' > webserver.yaml
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  volumes:
  - name: shared-logs
    emptyDir: {}
  containers:
  - name: nginx-container
    image: nginx:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: sidecar-container
    image: ubuntu:latest
    command: ["sh", "-c", "while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
EOF

# =================================================================
# Deploy the Pod
# =================================================================
kubectl apply -f webserver.yaml
kubectl get pods

# =================================================================
# Test the Sidecar
# =================================================================
kubectl logs webserver -c sidecar-container
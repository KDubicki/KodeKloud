# !/bin/bash

# =================================================================
# Create the Pod Configuration File
# =================================================================
cat << 'EOF' > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-share-devops
spec:
  volumes:
  - name: volume-share
    emptyDir: {}
  containers:
  - name: volume-container-devops-1
    image: fedora:latest
    command: ["sleep", "3600"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/blog
  - name: volume-container-devops-2
    image: fedora:latest
    command: ["sleep", "3600"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/cluster
EOF

# =================================================================
# Deploy the Pod
# =================================================================
kubectl apply -f pod.yaml
kubectl get pods

# =================================================================
# Create the File in Container 1
# =================================================================
kubectl exec volume-share-devops -c volume-container-devops-1 -- sh -c "echo 'Welcome to xFusionCorp Industries' > /tmp/blog/blog.txt"

# =================================================================
# Verify the File in Container 2
# =================================================================
kubectl exec volume-share-devops -c volume-container-devops-2 -- cat /tmp/cluster/blog.txt
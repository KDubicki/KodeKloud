# !/bin/bash

# =================================================================
# Create the Configuration File
# =================================================================
cat << 'EOF' > ic-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ic-deploy-datacenter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ic-datacenter
  template:
    metadata:
      labels:
        app: ic-datacenter
    spec:
      volumes:
      - name: ic-volume-datacenter
        emptyDir: {}
      initContainers:
      - name: ic-msg-datacenter
        image: debian:latest
        command: ['/bin/bash', '-c', 'echo Init Done - Welcome to xFusionCorp Industries > /ic/blog']
        volumeMounts:
        - name: ic-volume-datacenter
          mountPath: /ic
      containers:
      - name: ic-main-datacenter
        image: debian:latest
        command: ['/bin/bash', '-c', 'while true; do cat /ic/blog; sleep 5; done']
        volumeMounts:
        - name: ic-volume-datacenter
          mountPath: /ic
EOF

# =================================================================
# Deploy the Configuration
# =================================================================
kubectl apply -f ic-deploy.yaml


# =================================================================
# Verify the Deployment and Pods
# =================================================================
kubectl get deployments
kubectl get pods

# =================================================================
# Final Verification
# =================================================================
kubectl logs -l app=ic-datacenter
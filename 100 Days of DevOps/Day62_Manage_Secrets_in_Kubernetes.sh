# !/bin/bash

# =================================================================
# Create the Kubernetes Secret
# =================================================================
kubectl create secret generic ecommerce --from-file=/opt/ecommerce.txt

# =================================================================
# Create the Pod Configuration File
# =================================================================
cat << 'EOF' > secret-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-xfusion
spec:
  containers:
  - name: secret-container-xfusion
    image: debian:latest
    command: ["sleep", "3600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /opt/apps
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: ecommerce
EOF

# =================================================================
# Deploy the Pod
# =================================================================
kubectl apply -f secret-pod.yaml

# =================================================================
# Verify the Pod
# =================================================================
kubectl get pods


# =================================================================
# Verify the Secret Inside the Container
# =================================================================
kubectl exec secret-xfusion -- cat /opt/apps/ecommerce.txt
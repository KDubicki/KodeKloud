# !/bin/bash

# =================================================================
# Create the Pod Configuration File
# =================================================================
cat << 'EOF' > print-envars.yaml
apiVersion: v1
kind: Pod
metadata:
  name: print-envars-greeting
spec:
  restartPolicy: Never
  containers:
  - name: print-env-container
    image: bash
    command: ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"']
    env:
    - name: GREETING
      value: "Welcome to"
    - name: COMPANY
      value: "Stratos"
    - name: GROUP
      value: "Group"
EOF

# =================================================================
# Deploy the Pod
# =================================================================
kubectl apply -f print-envars.yaml

# =================================================================
# Verify
# =================================================================
kubectl get pods
kubectl logs -f print-envars-greeting
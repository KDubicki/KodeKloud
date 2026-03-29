# !/bin/bash

# =================================================================
# Create the Master Configuration File
# =================================================================
cat << 'EOF' > storage-setup.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-xfusion
spec:
  storageClassName: manual
  capacity:
    storage: 3Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-xfusion
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-xfusion
  labels:
    app: xfusion-app
spec:
  containers:
  - name: container-xfusion
    image: httpd:latest
    ports:
    - containerPort: 80
    volumeMounts:
    - mountPath: "/usr/local/apache2/htdocs"
      name: shared-storage
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: pvc-xfusion
---
apiVersion: v1
kind: Service
metadata:
  name: web-xfusion
spec:
  type: NodePort
  selector:
    app: xfusion-app
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30008
EOF

# =================================================================
# Deploy
# =================================================================
kubectl apply -f storage-setup.yaml

# =================================================================
# Verify the PVC Binding
# =================================================================
kubectl get pv,pvc

# =================================================================
# Verify the Pod and Service
# =================================================================
kubectl get pods
kubectl get svc web-xfusion
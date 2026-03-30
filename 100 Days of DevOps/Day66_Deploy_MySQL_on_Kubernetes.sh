# !/bin/bash

# =================================================================
# Create the Unified Configuration File
# =================================================================
cat << 'EOF' > mysql-stack.yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-root-pass
stringData:
  password: "YUIidhb667"
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-user-pass
stringData:
  username: "kodekloud_aim"
  password: "BruCStnMT5"
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-db-url
stringData:
  database: "kodekloud_db1"
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/mysql-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql-container
        image: mysql:5.7
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-root-pass
              key: password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-db-url
              key: database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: password
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
---
apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  selector:
    app: mysql
  ports:
    - port: 3306
      targetPort: 3306
      nodePort: 30007
EOF

# =================================================================
# Deploy
# =================================================================
kubectl apply -f mysql-stack.yaml


# =================================================================
# Verify
# =================================================================
kubectl get pv,pvc
kubectl get secrets
kubectl get pods
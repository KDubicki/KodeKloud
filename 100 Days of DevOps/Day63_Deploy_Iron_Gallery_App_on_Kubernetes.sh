# !/bin/bash

# =================================================================
# Create the Unified Configuration File
# =================================================================
cat << 'EOF' > iron-gallery-stack.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: iron-namespace-xfusion
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iron-gallery-deployment-xfusion
  namespace: iron-namespace-xfusion
  labels:
    run: iron-gallery
spec:
  replicas: 1
  selector:
    matchLabels:
      run: iron-gallery
  template:
    metadata:
      labels:
        run: iron-gallery
    spec:
      containers:
      - name: iron-gallery-container-xfusion
        image: kodekloud/irongallery:2.0
        resources:
          limits:
            memory: "100Mi"
            cpu: "50m"
        volumeMounts:
        - name: config
          mountPath: /usr/share/nginx/html/data
        - name: images
          mountPath: /usr/share/nginx/html/uploads
      volumes:
      - name: config
        emptyDir: {}
      - name: images
        emptyDir: {}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: iron-db-deployment-xfusion
  namespace: iron-namespace-xfusion
  labels:
    db: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      db: mariadb
  template:
    metadata:
      labels:
        db: mariadb
    spec:
      containers:
      - name: iron-db-container-xfusion
        image: kodekloud/irondb:2.0
        env:
        - name: MYSQL_DATABASE
          value: "database_web"
        - name: MYSQL_ROOT_PASSWORD
          value: "Str0ngR00tP@ssw0rd!"
        - name: MYSQL_PASSWORD
          value: "Str0ngUserP@ssw0rd!"
        - name: MYSQL_USER
          value: "ironuser"
        volumeMounts:
        - name: db
          mountPath: /var/lib/mysql
      volumes:
      - name: db
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: iron-db-service-xfusion
  namespace: iron-namespace-xfusion
spec:
  type: ClusterIP
  selector:
    db: mariadb
  ports:
  - protocol: TCP
    port: 3306
    targetPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: iron-gallery-service-xfusion
  namespace: iron-namespace-xfusion
spec:
  type: NodePort
  selector:
    run: iron-gallery
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 32678
EOF

# =================================================================
# Deploy
# =================================================================
kubectl apply -f iron-gallery-stack.yaml

# =================================================================
# Verify the Resources
# =================================================================
kubectl get pods -n iron-namespace-xfusion
kubectl get svc -n iron-namespace-xfusion

# =================================================================
# Verify the Installation Page
# =================================================================
curl -I http://localhost:32678
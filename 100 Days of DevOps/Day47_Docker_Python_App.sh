# !/bin/bash

# =================================================================
# Log in
# =================================================================
ssh steve@stapp02
sudo su -

# =================================================================
# Create the Dockerfile
# =================================================================
# 1. Navigate to the correct directory
cd /python_app

# 2. Create the Dockerfile
cat << 'EOF' > Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY src/ /app/
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 5004
CMD ["python", "server.py"]
EOF

# =================================================================
# Build the Docker Image
# =================================================================
docker build -t nautilus/python-app .

# =================================================================
# Deploy the Container
# =================================================================
docker run -d --name pythonapp_nautilus -p 8098:5004 nautilus/python-app

# =================================================================
# Test the Application
# =================================================================
curl localhost:8098
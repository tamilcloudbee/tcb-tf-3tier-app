#!/bin/bash
exec > /var/log/userdata-apptier.log 2>&1
echo "Starting FastAPI App Tier setup..."

# Update package list and install dependencies
echo "Updating package lists..."
apt update -y

echo "Installing Python, pip, virtualenv, Git..."
apt install -y python3 python3-pip python3-venv git curl

# Clone application
echo "Cloning FastAPI repository..."
mkdir -p /var/www/fastapi
cd /var/www/fastapi
git clone https://github.com/tamilcloudbee/tcb-fastapi-app.git .

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "Installing FastAPI, Gunicorn, Uvicorn, and MySQL connector..."
pip install fastapi pymysql gunicorn uvicorn python-multipart

# Create FastAPI service
echo "Creating systemd service for FastAPI..."
cat <<EOF > /etc/systemd/system/fastapi.service
[Unit]
Description=FastAPI with Gunicorn Service
After=network.target

[Service]
User=root
WorkingDirectory=/var/www/fastapi
ExecStart=/var/www/fastapi/venv/bin/gunicorn -w 4 -k uvicorn.workers.UvicornWorker main:app --bind 0.0.0.0:8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start FastAPI service
echo "Starting FastAPI service..."
systemctl daemon-reload
systemctl enable fastapi
systemctl start fastapi

# Validate installation
echo "Validating FastAPI setup..."
dpkg -l | grep -E "python3|pip|git|curl"
systemctl status fastapi --no-pager

echo "FastAPI App Tier setup completed!"

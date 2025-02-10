#!/bin/bash

exec > /var/log/userdata-app.log 2>&1

echo "Starting application tier setup..."

# Function to retry a command up to 5 times
retry_command() {
    local retries=5
    local count=0
    local delay=10
    local command=$1
    until $command; do
        ((count++))
        if [ $count -ge $retries ]; then
            echo "Command failed after $count attempts: $command"
            return 1
        fi
        echo "Command failed. Retrying ($count/$retries)..."
        sleep $delay
    done
}

# Install required packages
echo "Updating packages..."
retry_command "apt update -y"

echo "Installing Python3, Git, and dependencies..."
retry_command "apt install -y python3 python3-pip git python3-venv curl"

# Set up Python virtual environment for FastAPI
echo "Setting up Python virtual environment..."
mkdir -p /var/www/fastapi
cd /var/www/fastapi
python3 -m venv venv
source venv/bin/activate

# Install FastAPI, Gunicorn, Uvicorn, pymysql
echo "Installing FastAPI and dependencies..."
pip install fastapi pymysql gunicorn uvicorn python-multipart

# Create FastAPI app
echo "Creating FastAPI application..."
cat <<EOF > /var/www/fastapi/main.py
from fastapi import FastAPI, Form
from fastapi.middleware.cors import CORSMiddleware
import pymysql

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db_connection():
    return pymysql.connect(
        host="DB_TIER_IP_HERE",
        user="tcbadmin",
        password="Tcb@2025",
        database="tcb_db"
    )

@app.post("/register/")
async def submit_form(
    name: str = Form(...), 
    email: str = Form(...), 
    phone: str = Form(...), 
    message: str = Form(...),
    course: str = Form(...),
):
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        cursor.execute(
            "INSERT INTO tcb_enquiry (name, email, phone, message, course) VALUES (%s, %s, %s, %s, %s)",
            (name, email, phone, message, course)
        )
        conn.commit()
    except Exception as e:
        conn.rollback()
        return {"status": "error", "message": f"Error saving data: {str(e)}"}
    finally:
        cursor.close()
        conn.close()
    
    return {"status": "success", "message": "Data saved successfully"}

@app.get("/enquiries/")
async def get_enquiries():
    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)
    
    try:
        cursor.execute("SELECT * FROM tcb_enquiry")
        rows = cursor.fetchall()
        return rows
    except Exception as e:
        return {"status": "error", "message": f"Error fetching data: {str(e)}"}
    finally:
        cursor.close()
        conn.close()
EOF

# Replace `DB_TIER_IP_HERE` with the actual IP address of the database tier
echo "Updating database connection..."
DB_TIER_IP="DB_TIER_IP_HERE"
sed -i "s|DB_TIER_IP_HERE|$DB_TIER_IP|g" /var/www/fastapi/main.py

# Create systemd service for FastAPI
echo "Creating Gunicorn service..."
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

echo "Application tier setup completed."


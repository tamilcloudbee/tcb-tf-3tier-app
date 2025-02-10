#!/bin/bash
exec > /var/log/userdata-db.log 2>&1
echo "Starting Database Server setup..."

# Update package list and install dependencies
echo "Updating package lists..."
apt update -y

echo "Installing MySQL Server..."
apt install -y mysql-server libmysqlclient-dev

# Enable and start MySQL
echo "Enabling and starting MySQL..."
systemctl enable mysql
systemctl start mysql

# Configure MySQL and create database
echo "Configuring MySQL root user and creating database..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Root@123'; FLUSH PRIVILEGES;"
mysql -u root -pRoot@123 -e "CREATE DATABASE tcb_db;"
mysql -u root -pRoot@123 -e "CREATE USER 'tcbadmin'@'%' IDENTIFIED BY 'Tcb@2025';"
mysql -u root -pRoot@123 -e "GRANT ALL PRIVILEGES ON tcb_db.* TO 'tcbadmin'@'%'; FLUSH PRIVILEGES;"

# Create `tcb_enquiry` table
echo "Creating tcb_enquiry table..."
mysql -u tcbadmin -pTcb@2025 -D tcb_db -e "
CREATE TABLE IF NOT EXISTS tcb_enquiry (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    course VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"

# Validate installation
echo "Validating MySQL setup..."
dpkg -l | grep -E "mysql-server|libmysqlclient-dev"
systemctl status mysql --no-pager
mysql -u tcbadmin -pTcb@2025 -D tcb_db -e "SHOW TABLES;"

echo "Database Server setup completed!"

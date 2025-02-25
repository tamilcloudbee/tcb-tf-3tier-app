#!/bin/bash

# Update package list and install necessary packages
apt update -y
apt upgrade -y

# Install Apache2, MySQL, Python, Git, and other required packages
apt install apache2 mysql-server python3 python3-pip git -y

# Check if Python3 is installed and validate version
if ! command -v python3 &> /dev/null
then
    echo "Python3 is not installed. Installing Python3..."
    apt install python3 -y
else
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo "Python3 version $PYTHON_VERSION is installed."
    
    # Check Python3 version
    if [[ "$PYTHON_VERSION" < "3.6" ]]; then
        echo "Python version is older than 3.6. Upgrading..."
        apt install python3.8 -y
        python3 = python3.8
    fi
fi

# Install Python modules
pip3 install flask mysql-connector

# Start Apache2 and MySQL services
systemctl start apache2
systemctl enable apache2
systemctl start mysql
systemctl enable mysql

# Create MySQL database and user with password T@milcloud8ee
mysql -e "CREATE DATABASE IF NOT EXISTS tamilcloudbee;"
mysql -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'T@milcloud8ee';"
mysql -e "GRANT ALL PRIVILEGES ON tamilcloudbee.* TO 'admin'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Create table in the database
mysql -e "USE tamilcloudbee; CREATE TABLE IF NOT EXISTS students_enquiry (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(255) NOT NULL,
    course VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    mobile VARCHAR(255) NOT NULL,
    query TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"

# Clone your website repository into the Apache web directory
cd /var/www/html
rm -rf *   # Remove the default Apache welcome page
git clone https://github.com/tamilcloudbee/tcb-web-app.git .  # Replace with your Git repo URL
cat register/register-index-mon0lith.html >  register/index.html
rm -rf register/register-index-mon0lith.html

# Set correct permissions
chown -R www-data:www-data /var/www/html

# Create a Python script to handle form submission
cat <<EOF > /var/www/html/enquiry.py
import mysql.connector
import json
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    student_name = data.get('studentName')
    course = data.get('course')
    email = data.get('email')
    mobile = data.get('mobile')
    query = data.get('query')

    if not student_name or not course or not email or not mobile or not query:
        return jsonify({'success': False, 'message': 'All fields are required.'}), 400

    # Connect to MySQL and insert the data into the students_enquiry table
    conn = mysql.connector.connect(
        host="localhost", user="admin", password="T@milcloud8ee", database="tamilcloudbee"
    )
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO students_enquiry (student_name, course, email, mobile, query)
        VALUES (%s, %s, %s, %s, %s)
    """, (student_name, course, email, mobile, query))

    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({'success': True, 'message': 'Enquiry submitted successfully!'}), 200

@app.route('/get-enquiries', methods=['GET'])
def get_enquiries():
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM students_enquiry")
    enquiries = cursor.fetchall()
    cursor.close()
    return jsonify(enquiries)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)  # Change port to 5000 to avoid conflict with Apache
EOF

# Install Flask for Python
pip3 install Flask

# Start the Python application (Flask app)
python3 /var/www/html/enquiry.py &

# Configure Apache as a reverse proxy for Flask (port 5000)
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    
    ProxyPass /flaskapp http://127.0.0.1:5000
    ProxyPassReverse /flaskapp http://127.0.0.1:5000

    # Other Apache settings can go here
</VirtualHost>
EOF

# Enable required Apache modules
sudo a2enmod proxy
sudo a2enmod proxy_http

# Restart Apache to apply the changes
sudo systemctl restart apache2

# Done
echo "Setup complete. Apache is running, Flask app is running on port 5000."

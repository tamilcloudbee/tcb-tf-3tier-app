#!/bin/bash
exec > /var/log/userdata-frontend.log 2>&1
echo "Starting Frontend Webserver setup..."

# Update package list and install dependencies
echo "Updating package lists..."
apt update -y

echo "Installing Apache, Git, and required utilities..."
apt install -y apache2 git curl net-tools

# Enable and start Apache
echo "Starting Apache Webserver..."
systemctl enable apache2
systemctl start apache2

# Clone and deploy website
echo "Cloning frontend website repository..."
rm -rf /var/www/html/*
git clone https://github.com/tamilcloudbee/tcb-web-app /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Replace API endpoint in frontend files with App Tier private IP
APP_TIER_IP="<APP_TIER_PRIVATE_IP>"  # This should be replaced dynamically in Terraform

echo "Updating API endpoint in frontend..."
sed -i "s|your-alb-url.com|http://$APP_TIER_IP:8000|g" /var/www/html/register/index.html
sed -i "s|your-alb-url.com|http://$APP_TIER_IP:8000|g" /var/www/html/admin/index.html

# Configure Apache as a Reverse Proxy
echo "Configuring Apache as a Reverse Proxy..."
cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    Alias /admin /var/www/html/admin
    <Directory /var/www/html/admin>
        AllowOverride All
        Require all granted
    </Directory>

    Alias /register /var/www/html/register
    <Directory /var/www/html/register>
        AllowOverride All
        Require all granted
    </Directory>

    ProxyPass /api http://$APP_TIER_IP:8000/
    ProxyPassReverse /api http://$APP_TIER_IP:8000/
</VirtualHost>
EOF

# Enable necessary Apache modules and restart Apache
a2enmod proxy proxy_http
systemctl restart apache2

# Validate installation
echo "Validating Frontend Webserver setup..."
dpkg -l | grep -E "apache2|git|curl|net-tools"
systemctl status apache2 --no-pager

echo "Frontend Webserver setup completed!"


#!/bin/bash

# Assign environment variables to local variables
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"
DB_PASSWORD="${DB_PASSWORD}"
DB_USER="${DB_USER}"
EFS_ID="${EFS_ID}"
FILE="/var/www/html/latest.tar.gz"

# Update the system and install necessary packages
sudo yum update -y
sudo yum install -y amazon-efs-utils
sudo yum install -y nfs-utils
sudo mkdir -p /var/www/html/
sudo mount -t efs -o tls $EFS_ID:/ /var/www/html

# Install and start Memcached
sudo yum install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached

# Install Apache, PHP, and related packages
sudo yum install -y httpd
sudo yum remove -y php*
sudo yum clean -y all
sudo amazon-linux-extras enable php8.0 memcached1.5
sudo yum clean -y metadata
sudo yum install -q -y php php-gd php-mysqli php-cli php-fpm php-opcache php-common
sudo yum install -y php-xml
sudo yum install -y gcc make php php-pear php-devel libmemcached libmemcached-devel zlib-devel memcached
sudo pecl update-channels
"echo n n n n n n y y" | sudo pecl install memcached

# Start Apache web server
sudo systemctl start httpd
sudo systemctl enable httpd

# Download and configure WordPress
if [[ -e $FILE ]]; then
    sleep 300
else  
    cd /var/www/html
    sudo wget https://wordpress.org/latest.tar.gz
    sudo tar -xzvf latest.tar.gz
    sudo cp -r wordpress/* .
    cd ..
    sudo chown -R apache:apache html
    cd ./html
    sudo rm -rf wordpress/
    sudo rm -rf latest.tar.gz
    sudo cp wp-config-sample.php wp-config.php
    sudo chown -R apache:apache wp-config.php
    cat <<EOT >> credfile.txt
define( 'AS3CF_SETTINGS', serialize( array (
    'provider' => 'aws',
    'use-server-roles' => true,
) ) );
EOT
    sudo sed -i "s/database_name_here/$DB_NAME/" wp-config.php
    sudo sed -i "s/username_here/$DB_USER/" wp-config.php
    sudo sed -i "s/password_here/$DB_PASSWORD/" wp-config.php
    sudo sed -i "s/localhost/$DB_HOST/" wp-config.php
    sudo sed -i "/define( 'WP_DEBUG', false );/r credfile.txt" wp-config.php
    sudo rm credfile.txt
fi

# Add Memcached extension to PHP configuration
echo extension=memcached.so | sudo tee -a /etc/php.ini

# Restart Apache to apply changes
sudo systemctl restart httpd
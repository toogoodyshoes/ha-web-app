#!/bin/bash

DB_NAME="wordpress"
DB_USERNAME="wpadmin"
DB_PASSWORD="wpadminat123"
DB_HOST=""

yum update -y

#install apache server 
yum install -y httpd

#install php
amazon-linux-extras enable php7.4
yum clean metadata 
yum install php php-devel
amazon-linux-extras install -y php7.4
systemctl start httpd
systemctl enable httpd

#install wordpress
cd /var/www
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php

#change wp-config with DB details
cp -r wordpress/* /var/www/html/
sed -i "s/database_name_here/$DB_NAME/g" /var/www/html/wp-config.php
sed -i "s/username_here/$DB_USERNAME/g" /var/www/html/wp-config.php
sed -i "s/password_here/$DB_PASSWORD/g" /var/www/html/wp-config.php
sed -i "s/localhost/$DB_HOST/g" /var/www/html/wp-config.php
### keys update

#change httpd.conf file to allowoverride
#  enable .htaccess files in Apache config using sed command
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Change OWNER and permission of directory /var/www
chown -R apache /var/www
chgrp -R apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

systemctl restart httpd
systemctl enable httpd
systemctl start httpd

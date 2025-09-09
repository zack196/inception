#!/bin/sh

set -e

# Set environment variables for database connection
MARIADB_ROOT_PASSWORD=$(cat ${MARIADB_ROOT_PASSWORD})
MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD})

if [ ! -f /var/www/html/index.php ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz
    tar -xvzf latest.tar.gz
    mv wordpress/* /var/www/html/
    rm -f latest.tar.gz
    rm -rf wordpress
    chown -R www-data:www-data /var/www/html/*
    
    # Update wp-config.php if it is not already updated
    if [ ! -f /var/www/html/wp-config.php ]; then
        cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
        chown www-data:www-data /var/www/html/wp-config.php
        echo "wp-config.php created from sample."
        
        # Update wp-config.php with environment variables
        sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
        sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
        sed -i "s/password_here/${MARIADB_PASSWORD}/" /var/www/html/wp-config.php
        sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
        
        # Redis configuration
        echo "Configuring Redis..."
        sed -i "/^require_once.*wp-settings\.php/i\
           define('WP_CACHE', true);\
           define('WP_REDIS_HOST', 'redis');\
           define('WP_REDIS_PORT', 6379);" /var/www/html/wp-config.php

        apk add --no-cache curl unzip

        # Install the plugin
        mkdir -p /var/www/html/wp-content/plugins
        cd /var/www/html/wp-content/plugins
        curl -L -o redis-cache.zip https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip
        unzip -q redis-cache.zip && rm redis-cache.zip
        
        # Enable the drop-in (what "wp redis enable" would do)
        cp /var/www/html/wp-content/plugins/redis-cache/includes/object-cache.php \
           /var/www/html/wp-content/object-cache.php

    fi
fi

exec php-fpm83 -F
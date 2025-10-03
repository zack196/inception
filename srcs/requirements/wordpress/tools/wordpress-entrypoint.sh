#!/bin/sh

set -e

# Set environment variables for database connection
MARIADB_ROOT_PASSWORD="$(cat "$MARIADB_ROOT_PASSWORD")"
MARIADB_PASSWORD="$(cat "$MARIADB_PASSWORD")"
ADMIN_PASS="$(cat "$ADMIN_PASS")"

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


        echo "WordPress installation ..."
    
        if ! wp core is-installed --allow-root --path=/var/www/html; then
            wp core install \
                --url="$SITE_URL" \
                --title="$SITE_TITLE" \
                --admin_user="$ADMIN_USER" \
                --admin_password="$ADMIN_PASS" \
                --admin_email="$ADMIN_EMAIL" \
                --skip-email \
                --allow-root \
                --path=/var/www/html
        fi

        # Create second user once
        if ! wp user get "$WORDPRESS_2USER" --allow-root --path=/var/www/html >/dev/null 2>&1; then
            wp user create \
                "$WORDPRESS_2USER" "$WORDPRESS_2USER_EMAIL" \
                --role=author \
                --user_pass="$WORDPRESS_2USER_PASSWORD" \
                --allow-root \
                --path=/var/www/html
        fi
    fi
fi

echo "Wordpress instalition is finished!"

exec php-fpm83 -F
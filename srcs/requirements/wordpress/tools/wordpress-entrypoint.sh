#!/bin/sh
set -e

DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_HOST=${DB_HOST}

if [ ! -f index.php ]; then
  echo "📦 Downloading WordPress..."
  curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
  tar -xzf /tmp/wordpress.tar.gz -C /tmp/
  mv /tmp/wordpress/* /var/www/wordpress/
  rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
  chown -R nobody:nobody /var/www/wordpress
fi

exec php-fpm83 -F

#!/bin/sh
set -e

DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_HOST=${DB_HOST:-mariadb}

# 1) Wait for MariaDB to accept connections
echo "⏳ Waiting for MariaDB at ${DB_HOST}:3306..."
until nc -z "$DB_HOST" 3306; do
  sleep 1
done
echo "✅ MariaDB is reachable."

# 2) Download WordPress into the bind-mounted volume if missing
if [ ! -f index.php ]; then
  echo "📦 Downloading WordPress..."
  curl -fsSL -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz
  tar -xzf /tmp/wordpress.tar.gz -C /tmp/
  mv /tmp/wordpress/* /var/www/wordpress/
  rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
  chown -R nobody:nobody /var/www/wordpress
fi

# (B) Now wait for DB
echo "⏳ Waiting for MariaDB at ${DB_HOST}:3306..."
until nc -z "$DB_HOST" 3306; do sleep 1; done
echo "✅ MariaDB is reachable."

# 3) (Optional) Auto-generate wp-config.php so setup page is skipped
if [ ! -f wp-config.php ] && [ -f wp-config-sample.php ]; then
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
  sed -i "s/username_here/${DB_USER}/"      wp-config.php
  sed -i "s/password_here/${DB_PASSWORD}/"  wp-config.php
  sed -i "s/localhost/${DB_HOST}/"          wp-config.php

  # Add salts (best effort; if offline, you can fill later)
  SALTS="$(curl -fsSL https://api.wordpress.org/secret-key/1.1/salt/ || true)"
  if [ -n "$SALTS" ]; then
    awk -v r="$SALTS" '
      /AUTH_KEY|SECURE_AUTH_KEY|LOGGED_IN_KEY|NONCE_KEY|AUTH_SALT|SECURE_AUTH_SALT|LOGGED_IN_SALT|NONCE_SALT/ {next}
      {print}
      /<?php/ {print r}
    ' wp-config.php > wp-config.php.new && mv wp-config.php.new wp-config.php
  fi

  chown nobody:nobody wp-config.php
fi

# 4) Start PHP-FPM in foreground (Nginx will talk to port 9000)
exec php-fpm83 -F

#!/bin/bash
# set -euo pipefail

# Read secrets (provided by docker-compose secrets)
ROOT_PW="$(cat /run/secrets/db_root_password)"
USER_PW="$(cat /run/secrets/db_password)"

# Env from .env (or compose 'environment:')
DB_NAME="${DB_NAME:-wordpress}"
DB_USER="${DB_USER:-wpuser}"

# First-time initialization if system tables are missing
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MariaDB datadir..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db >/dev/null

  echo "Starting temporary server (socket only)..."
  mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --datadir=/var/lib/mysql &
  pid="$!"

  echo "Waiting for server..."
  for i in {1..60}; do
    mysqladmin --socket=/run/mysqld/mysqld.sock ping &>/dev/null && break
    sleep 1
  done

  echo "Configuring root/user/database..."
  mariadb --protocol=SOCKET --socket=/run/mysqld/mysqld.sock <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PW}';
    DELETE FROM mysql.user WHERE user='' OR host NOT IN ('localhost','127.0.0.1','::1');
    FLUSH PRIVILEGES;

    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${USER_PW}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  echo "Shutting down temporary server..."
  mysqladmin --protocol=SOCKET --socket=/run/mysqld/mysqld.sock -uroot -p"${ROOT_PW}" shutdown
  wait "$pid"
fi

echo "Launching MariaDB..."
exec "$@"

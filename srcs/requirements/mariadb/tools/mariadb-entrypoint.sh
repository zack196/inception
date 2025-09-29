#!/bin/sh

set -e

MARIADB_ROOT_PASSWORD=$(cat ${MARIADB_ROOT_PASSWORD})
MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD})
MARIADB_ROOT_USER_PASSWORD=$(cat ${ROOT_USER_PASSWORD})

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "Initialise database..."
    mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql --skip-test-db

    TMP=/tmp/.tmpfile

    echo "mysql commands..."

    echo "FLUSH PRIVILEGES;" >> ${TMP}
	echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';" >> ${TMP}
	echo "CREATE DATABASE ${WORDPRESS_DB_NAME};" >> ${TMP}
    echo "CREATE USER '${WORDPRESS_DB_ROOT}'@'%' IDENTIFIED BY '${MARIADB_ROOT_USER_PASSWORD}';" >> ${TMP}
	echo "CREATE USER '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';" >> ${TMP}
	echo "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_DB_ROOT}'@'%' IDENTIFIED BY '${MARIADB_ROOT_USER_PASSWORD}';" >> ${TMP}
	echo "GRANT ALL PRIVILEGES ON ${WORDPRESS_DB_NAME}.* TO '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';" >> ${TMP}
	echo "FLUSH PRIVILEGES;" >> ${TMP}

    mariadbd --user=mysql --bootstrap < ${TMP}
    
    rm -f ${TMP}

    echo "Database initialized successfully."

fi
exec mariadbd --user=mysql --datadir=/var/lib/mysql
FROM alpine:3.21.4

# Install server + client
RUN apk update && apk add --no-cache mariadb mariadb-client bash

# Runtime dirs
RUN mkdir -p /run/mysqld /docker-entrypoint-initdb.d \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Basic server config
COPY conf/my.cnf /etc/my.cnf

# Entrypoint does first-run init + user/db creation
COPY tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
CMD ["mysqld", "--user=mysql", "--console"]

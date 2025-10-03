FROM alpine:3.21.4

RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    bash 
 
RUN mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql

COPY ./conf/my.cnf /etc/my.cnf.d/mariadb-server.cnf

COPY ./tools/mariadb-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["mariadb-entrypoint.sh"]
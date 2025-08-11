
FROM alpine:3.21.4

RUN apk update && apk add --no-cache mariadb mariadb-client bash

RUN mkdir -p /run/mysqld /docker-entrypoint-initdb.d \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/my.cnf /etc/my.cnf

COPY tools/mariadb-entrypoint.sh /usr/local/bin/mariadb-entrypoint.sh

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

USER mysql

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]

CMD ["mysqld", "--user=mysql", "--console"]
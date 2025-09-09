FROM alpine:3.21.4

RUN apk add --no-cache \
      unzip \
      curl \
      php83 \
      php83-fpm \
      php83-mysqli \
      php83-pdo \
      php83-pdo_mysql \
      php83-opcache \
      php83-ctype \
      php83-pecl-redis \
      php83-session

RUN adduser -D -G www-data www-data

COPY ./conf/www.conf /etc/php83/php-fpm.d/www.conf

EXPOSE 9000

COPY ./tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
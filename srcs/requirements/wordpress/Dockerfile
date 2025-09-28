FROM alpine:3.21.4

RUN apk add --no-cache \
      unzip \
      curl \
      php83 \
      php83-mysqli \
      php83-pdo \
      php83-pdo_mysql \
      php83-opcache \
      php83-ctype \
      php83-pecl-redis \
      php83-session \
      php83-cli \
      php83-phar \
      php83-fpm \
      php83-mbstring \
      php83-iconv \
      php83-xml \
      php83-dom \
      php83-curl \
      php83-zip \
      php83-gd 


RUN adduser -D -G www-data www-data

# Download WP-CLI and make it executable
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp


COPY ./conf/www.conf /etc/php83/php-fpm.d/www.conf

EXPOSE 9000

COPY ./tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
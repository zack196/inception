FROM alpine:3.21.4

RUN apk update && apk add \
		php83 \
		php83-fpm \
		php83-mysqli \
		php83-json \
		php83-session \
		php83-curl \
		php83-mbstring \
		php83-xml \
		php83-tokenizer \
		php83-gd \
		curl \
		unzip \
		su-exec \
		shadow \
		bash


COPY /conf/www.conf /etc/php83/php-fpm.d/www.conf

COPY tools/wordpress-entrypoint.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
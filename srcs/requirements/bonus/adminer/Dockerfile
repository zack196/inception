FROM alpine:3.21.4

RUN apk update

RUN apk add --no-cache \
    curl \
    wget \
    php83 \
    php83-mysqli \
    php83-session 

RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php"

RUN mv adminer-4.8.1.php index.php

EXPOSE 8080

CMD ["php83", "-S", "0.0.0.0:8080", "-t", "./"]
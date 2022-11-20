FROM php:8.1-fpm as php

# For production, set all to 1
# For local, set all to 0
ENV PHP_OPCACHE_ENABLE=0
ENV PHP_OPCACHE_ENABLE_CLI=0
ENV PHP_OPCACHE_VALIDATE_TIMESTAMP=0
ENV PHP_OPCACHE_REVALIDATE_FREQ=0

RUN usermod -u 1000 www-data

RUN apt-get update -y
RUN apt-get install -y unzip libpq-dev libcurl4-gnutls-dev nginx
RUN docker-php-ext-install pdo pdo_mysql bcmath curl opcache

WORKDIR /var/www

COPY --chown=www-data . .

COPY ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY ./docker/php/php-fpm.conf /usr/local/etc/php/php-fpm.d/www.conf
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf

COPY --from=composer:2.3.5 /usr/bin/composer /usr/bin/composer

RUN php artisan cache:clear
RUN php artisan config:clear

RUN chmod -R 755 /var/www/storage
RUN chmod -R 755 /var/www/bootstrap

ENTRYPOINT [ "docker/entrypoint.sh" ]
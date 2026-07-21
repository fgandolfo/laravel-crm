FROM php:8.3-fpm-alpine

RUN apk add --no-cache nginx supervisor nodejs npm git unzip libpng-dev \
    libzip-dev icu-dev oniguruma-dev freetype-dev libjpeg-turbo-dev

RUN mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs /run/nginx \
 && chown -R www-data:www-data /var/lib/nginx /run/nginx

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install pdo_mysql mbstring bcmath gd intl zip exif pcntl calendar

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && npm install && npm run build \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]

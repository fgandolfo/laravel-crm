#!/bin/sh
set -e
sed -i "s/listen = 9000/listen = 127.0.0.1:9000/" /usr/local/etc/php-fpm.d/www.conf || true
php artisan config:cache || true
php artisan route:cache || true
php artisan storage:link || true
touch /var/www/html/storage/installed || true
chown -R www-data:www-data /var/www/html/storage/app/public
exec supervisord -c /etc/supervisord.conf

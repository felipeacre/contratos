#!/bin/sh
# Garante que o www-data seja dono dos uploads mesmo após volume mount
chown -R www-data:www-data /var/www/html/uploads 2>/dev/null || true
chmod -R 775 /var/www/html/uploads 2>/dev/null || true

exec docker-php-entrypoint "$@"

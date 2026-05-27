#!/usr/bin/env bash
set -e

if [ -f /data/params ]; then
    set -a
    # shellcheck disable=SC1091
    source /data/params
    set +a
fi

export NGINX_PORT="${NGINX_PORT:-8080}"
export CATALOGUE_HOST="${CATALOGUE_HOST:-roboshop-catalogue}"
export CATALOGUE_PORT="${CATALOGUE_PORT:-8080}"
export USER_HOST="${USER_HOST:-roboshop-user}"
export USER_PORT="${USER_PORT:-8080}"
export CART_HOST="${CART_HOST:-roboshop-cart}"
export CART_PORT="${CART_PORT:-8080}"
export SHIPPING_HOST="${SHIPPING_HOST:-roboshop-shipping}"
export SHIPPING_PORT="${SHIPPING_PORT:-8080}"
export PAYMENT_HOST="${PAYMENT_HOST:-roboshop-payment}"
export PAYMENT_PORT="${PAYMENT_PORT:-8080}"
export RATINGS_HOST="${RATINGS_HOST:-roboshop-ratings}"
export RATINGS_PORT="${RATINGS_PORT:-8080}"
export ORDERS_HOST="${ORDERS_HOST:-roboshop-orders}"
export ORDERS_PORT="${ORDERS_PORT:-8080}"

mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp

envsubst '${NGINX_PORT} ${CATALOGUE_HOST} ${CATALOGUE_PORT} ${USER_HOST} ${USER_PORT} ${CART_HOST} ${CART_PORT} ${SHIPPING_HOST} ${SHIPPING_PORT} ${PAYMENT_HOST} ${PAYMENT_PORT} ${RATINGS_HOST} ${RATINGS_PORT} ${ORDERS_HOST} ${ORDERS_PORT}' \
    < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

#!/usr/bin/env bash
set -e

if [ -f /data/params ]; then
    set -a
    # shellcheck disable=SC1091
    source /data/params
    set +a
fi

: "${NGINX_PORT:?NGINX_PORT is required}"
: "${CATALOGUE_HOST:?CATALOGUE_HOST is required}"
: "${CATALOGUE_PORT:?CATALOGUE_PORT is required}"
: "${USER_HOST:?USER_HOST is required}"
: "${USER_PORT:?USER_PORT is required}"
: "${CART_HOST:?CART_HOST is required}"
: "${CART_PORT:?CART_PORT is required}"
: "${SHIPPING_HOST:?SHIPPING_HOST is required}"
: "${SHIPPING_PORT:?SHIPPING_PORT is required}"
: "${PAYMENT_HOST:?PAYMENT_HOST is required}"
: "${PAYMENT_PORT:?PAYMENT_PORT is required}"
: "${RATINGS_HOST:?RATINGS_HOST is required}"
: "${RATINGS_PORT:?RATINGS_PORT is required}"
: "${ORDERS_HOST:?ORDERS_HOST is required}"
: "${ORDERS_PORT:?ORDERS_PORT is required}"

mkdir -p /tmp/client_temp /tmp/proxy_temp /tmp/fastcgi_temp /tmp/uwsgi_temp /tmp/scgi_temp

envsubst '${NGINX_PORT} ${CATALOGUE_HOST} ${CATALOGUE_PORT} ${USER_HOST} ${USER_PORT} ${CART_HOST} ${CART_PORT} ${SHIPPING_HOST} ${SHIPPING_PORT} ${PAYMENT_HOST} ${PAYMENT_PORT} ${RATINGS_HOST} ${RATINGS_PORT} ${ORDERS_HOST} ${ORDERS_PORT}' \
    < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

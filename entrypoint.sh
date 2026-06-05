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

# Cluster DNS (from pod resolv.conf) — nginx caches upstream IPs without this + variable proxy_pass.
export DNS_RESOLVER="${DNS_RESOLVER:-$(awk '/^nameserver/{print $2; exit}' /etc/resolv.conf)}"
: "${DNS_RESOLVER:?DNS_RESOLVER is required}"

# Nginx resolver ignores resolv.conf search domains; short Service names must be FQDN.
K8S_DNS_SUFFIX="${K8S_DNS_SUFFIX:-default.svc.cluster.local}"
qualify_host() {
    local host="$1"
    if [[ "$host" != *.* ]]; then
        printf '%s.%s' "$host" "$K8S_DNS_SUFFIX"
    else
        printf '%s' "$host"
    fi
}
CATALOGUE_HOST=$(qualify_host "$CATALOGUE_HOST")
USER_HOST=$(qualify_host "$USER_HOST")
CART_HOST=$(qualify_host "$CART_HOST")
SHIPPING_HOST=$(qualify_host "$SHIPPING_HOST")
PAYMENT_HOST=$(qualify_host "$PAYMENT_HOST")
RATINGS_HOST=$(qualify_host "$RATINGS_HOST")
ORDERS_HOST=$(qualify_host "$ORDERS_HOST")
export CATALOGUE_HOST USER_HOST CART_HOST SHIPPING_HOST PAYMENT_HOST RATINGS_HOST ORDERS_HOST

envsubst '${NGINX_PORT} ${DNS_RESOLVER} ${CATALOGUE_HOST} ${CATALOGUE_PORT} ${USER_HOST} ${USER_PORT} ${CART_HOST} ${CART_PORT} ${SHIPPING_HOST} ${SHIPPING_PORT} ${PAYMENT_HOST} ${PAYMENT_PORT} ${RATINGS_HOST} ${RATINGS_PORT} ${ORDERS_HOST} ${ORDERS_PORT}' \
    < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;' -c /etc/nginx/nginx.conf

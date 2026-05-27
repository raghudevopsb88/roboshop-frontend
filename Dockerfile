FROM docker.io/library/node:20 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM docker.io/redhat/ubi9:latest
RUN dnf install -y nginx gettext && dnf clean all
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/out .
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
    && mkdir -p /var/log/nginx /tmp \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]

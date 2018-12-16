FROM nginx:stable-alpine

RUN \
    apk add --no-cache inotify-tools jq bash openssl && \
    wget https://raw.githubusercontent.com/containous/traefik/v1.7.6/contrib/scripts/dumpcerts.sh -O /usr/bin/dumpcerts.sh && \
    chmod +x /usr/bin/dumpcerts.sh && \
    mkdir -p /run/nginx

COPY entrypoint.sh /entrypoint.sh
COPY nginx.sh /usr/bin/nginx.sh

ENTRYPOINT [ "/entrypoint.sh" ]

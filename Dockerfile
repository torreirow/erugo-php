# Erugo (upstream image wardy784/erugo) repackaged on Alpine 3.22 with PHP 8.3.
#
# Upstream runs on Alpine 3.19 (end-of-life), where php83 is stuck at 8.3.14 and does not
# receive the PHP2Shell fix (CVE-2026-109618/109619). The application, vendor/ and the built
# frontend assets come unchanged from the pinned upstream image; only the runtime is new.
# Mirrors the final stage of upstream's docker/alpine/Dockerfile.
ARG UPSTREAM=wardy784/erugo@sha256:0d9d31365e180408baee86172694a420418a7e05badd158fe84eb873a9f77753
FROM ${UPSTREAM} AS upstream

FROM alpine:3.22

ARG PHP_MIN=8.3.36
ARG APP_VERSION=unknown

ENV APP_VERSION=${APP_VERSION}
ENV TZ=UTC
ENV SUPERVISOR_PHP_FPM_COMMAND="/usr/sbin/php-fpm83 -F"
ENV SUPERVISOR_CADDY_COMMAND="/usr/sbin/caddy run --config /etc/caddy/Caddyfile"
ENV SUPERVISOR_PHP_USER="erugo"

WORKDIR /var/www/html

RUN apk add --no-cache \
    curl su-exec sudo supervisor cronie ffmpeg tzdata libcap zip caddy \
    php83 php83-fpm php83-pdo_pgsql php83-pdo_sqlite php83-gd php83-curl \
    php83-pecl-mongodb php83-imap php83-pdo_mysql php83-mbstring php83-xml \
    php83-zip php83-bcmath php83-soap php83-intl php83-ldap php83-pecl-redis \
    php83-pecl-memcached php83-phar php83-openssl php83-dom php83-tokenizer \
    php83-fileinfo php83-sockets php83-session \
  && ln -sf /usr/bin/php83 /usr/bin/php \
  && php -r 'exit(version_compare(PHP_VERSION, $argv[1], ">=") ? 0 : 1);' "$PHP_MIN"

RUN mkdir -p /run/php /etc/caddy /var/log/supervisor \
  && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
  && setcap "cap_net_bind_service=+ep" /usr/bin/php83 \
  && addgroup -g 1000 erugo && adduser -D -u 1000 -G erugo erugo \
  && chown -R erugo:erugo /run/php

COPY --from=upstream /usr/local/bin/tusd /usr/local/bin/tusd
COPY --from=upstream /usr/local/bin/start-container /usr/local/bin/start-container
COPY --from=upstream /etc/caddy/Caddyfile /etc/caddy/Caddyfile
COPY --from=upstream /etc/php83/php-fpm.d/www.conf /etc/php83/php-fpm.d/www.conf
COPY --from=upstream /etc/php83/conf.d/99-erugo.ini /etc/php83/conf.d/99-erugo.ini
COPY --from=upstream /etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --from=upstream --chown=erugo:erugo /var/www/html /var/www/html

RUN echo "* * * * * cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1" | crontab -u erugo -

EXPOSE 80/tcp
ENTRYPOINT ["start-container"]

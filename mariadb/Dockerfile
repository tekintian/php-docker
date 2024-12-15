ARG ALPINE_VERSION="3.20"

FROM tekintian/alpine:$ALPINE_VERSION

ARG BUILD_DATE
ARG MARIADB_VERSION

LABEL \
    maintainer="tekintian <tekintian@gmail.com>" \
    build="$BUILD_DATE" \
    org.opencontainers.image.title="alpine-mariadb" \
    org.opencontainers.image.description="MariaDB Docker image running on Alpine Linux" \
    org.opencontainers.image.authors="tekintian <tekintian@gmail.com>" \
    org.opencontainers.image.vendor="tekintian" \
    org.opencontainers.image.version="v$MARIADB_VERSION" \
    org.opencontainers.image.url="https://hub.docker.com/r/tekintian/alpine-mariadb/" \
    org.opencontainers.image.source="https://gitlab.com/tekintian/alpine-mariadb" \
    org.opencontainers.image.created=$BUILD_DATE

# add scripts to /scripts
ADD files/*.sh /scripts/

RUN \
    echo "" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/main" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v$ALPINE_VERSION/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache mariadb mariadb-client mariadb-server-utils pwgen && \
    cp -a /etc/my.cnf.d/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf.bk && \
    mkdir /docker-entrypoint-initdb.d && \
    mkdir /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts && \
    rm -f /var/cache/apk/*

EXPOSE 3306

VOLUME ["/var/lib/mysql"]
VOLUME ["/etc/my.cnf.d"]

ENTRYPOINT ["/scripts/run-alpine-mariadb.sh"]

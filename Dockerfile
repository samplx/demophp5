#
#
FROM golang as supervisorgo
WORKDIR /go/src/github.com/1and1internet/supervisorgo
RUN git clone https://github.com/1and1internet/supervisorgo.git . \
    && go build -o release/supervisorgo \
    && echo "supervisorgo successfully built"

FROM php:5-apache
COPY files/ /
COPY --from=supervisorgo /go/src/github.com/1and1internet/supervisorgo/release/supervisorgo /usr/bin/supervisorgo

RUN \
    export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && update-alternatives --install /usr/bin/supervisord supervisord /usr/bin/supervisorgo 1 \
    && rm /etc/apt/apt.conf.d/docker-no-languages \
    && groupadd mysql \
    && useradd -g mysql mysql \
    && apt-get update \
    && apt-get install -y apt-utils debconf-utils libapt-inst2.0 \
    && apt-get upgrade -y \
    && debconf-set-selections -v /etc/debconf-preseed.txt \
    && apt-get install -y \
        apt-transport-https libcurl3-gnutls \
        gettext-base libc-l10n libgnutls-openssl27 locales ssmtp \
        curl libaio-dev libnuma-dev pwgen binutils \
        mysql-server mysql-client \
    && rm -rf /var/lib/mysql /etc/mysql* \
    && mkdir --mode=0777 /var/lib/mysql /var/run/mysqld /etc/mysql \
    && chmod 0777 /docker-entrypoint-initdb.d \
    && mkdir -p /var/log/mysql \
    && find /etc/mysql/ -type f -exec chmod 644 {} \; \
    && dpkg-reconfigure -f noninteractive tzdata \
    && dpkg-reconfigure -f noninteractive locales \
    && chmod -R 755 /init /hooks \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    SMTP_USER="" \
    SMTP_PASS="" \
    SMTP_DOMAIN="" \
    SMTP_RELAYHOST="" \
    MYSQL_ROOT_PASSWORD="secret42" \
    MYSQL_USER="demo" \
    MYSQL_PASSWORD="password" \
    MYSQL_DATABASE="demodb"
ENTRYPOINT ["/bin/bash", "/init/entrypoint"]
CMD ["/init/supervisord"]

EXPOSE 80 3306

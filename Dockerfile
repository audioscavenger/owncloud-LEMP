<<<<<<< HEAD
# Override ARG with docker build --build-arg TAG=<vresion> .
ARG TAG=latest
ARG INTERNAL_HTTP=8081

FROM audioscavenger/ubuntu-lemp:${TAG:-latest}

## Check latest version: https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule
ENV OWNCLOUD_VERSION=${TAG:-latest}
ENV USER_LDAP_VERSION="0.11.0" \
    OWNCLOUD_IN_ROOTPATH="0" \
    OWNCLOUD_SERVERNAME="127.0.0.1"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

LABEL maintainer="audioscavenger <dev@derewonko.com>" \
  org.label-schema.name="ownCloud Server LEMP" \
  org.label-schema.vendor="lesmoules" \
=======
FROM owncloud/php:latest

LABEL maintainer="ownCloud DevOps <devops@owncloud.com>" \
  org.label-schema.name="ownCloud Base" \
  org.label-schema.vendor="ownCloud GmbH" \
>>>>>>> owncloud/master
  org.label-schema.schema-version="1.0"

VOLUME ["/mnt/data"]

EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/owncloud", "server"]


WORKDIR /var/www/owncloud
RUN find /var/www/owncloud \( \! -user www-data -o \! -group root \) -print0 | xargs -r -0 chown www-data:root && \
    chmod g+w /var/www/owncloud

EXPOSE ${INTERNAL_HTTP}
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/owncloud", "server"]
=======
EXPOSE 8080

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/owncloud", "server"]

RUN apt-get update -y && \
  apt-get upgrade -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /var/www/owncloud /mnt/data/files /mnt/data/config /mnt/data/certs /mnt/data/sessions && \
  chown -R www-data:www-data /var/www/owncloud /mnt/data && \
  chgrp root /var/run /var/lock/apache2 /var/run/apache2 /etc/environment && \
  chmod g+w /var/run /var/lock/apache2 /var/run/apache2 /etc/environment && \
  chsh -s /bin/bash www-data

COPY rootfs /
WORKDIR /var/www/owncloud

RUN chgrp root /etc/apache2/sites-enabled/default.conf /etc/php/7.2/mods-available/owncloud.ini && \
  chmod g+w /etc/apache2/sites-enabled/default.conf /etc/php/7.2/mods-available/owncloud.ini
>>>>>>> owncloud/master

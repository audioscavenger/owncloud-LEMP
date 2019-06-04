# Override ARG with docker build --build-arg TAG=<vresion> .
ARG TAG=latest
ARG INTERNAL_HTTP=8081

FROM audioscavenger/ubuntu-lemp:${TAG:-latest}

LABEL maintainer="audioscavenger <dev@derewonko.com>" \
  org.label-schema.name="ownCloud Server LEMP" \
  org.label-schema.vendor="lesmoules" \
  org.label-schema.schema-version="1.0"

## Check latest version: https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule
ENV OWNCLOUD_VERSION=${TAG:-latest}
ENV USER_LDAP_VERSION="0.13.0" \
    OWNCLOUD_IN_ROOTPATH="0" \
    OWNCLOUD_SERVERNAME="127.0.0.1"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV TZ=America/New_York

VOLUME ["/mnt/data"]

RUN mkdir -p /var/www/html /var/www/owncloud /var/log/nginx /var/run/php \
&& mkdir -p /mnt/data/files /mnt/data/config /mnt/data/certs /mnt/data/sessions /mnt/data/ssl \
&& chown -R www-data:www-data /var/www /mnt/data /var/log/nginx /var/run/php \
&& chsh -s /bin/bash www-data

# ADD local compressed files will unzip them but cannot be automated by docker hub:
#ADD owncloud-*.tar.bz2 /var/www/
#ADD user_ldap.tar.gz /var/www/owncloud/apps/

# ADD downloaded compressed files will NOT unzip them:
ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2
ADD https://github.com/owncloud/user_ldap/releases/download/v${USER_LDAP_VERSION}/user_ldap.tar.gz /var/www/user_ldap.tar.gz

# this moved to /etc/owncloud.d/05-unzip.sh: exec on first run = smaller image
# RUN /bin/tar -xjf /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2 -C /var/www && /bin/rm /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2 && \
    # /bin/tar -xzf /var/www/user_ldap.tar.gz -C /var/www/owncloud/apps && /bin/rm /var/www/user_ldap.tar.gz

# https://stackoverflow.com/questions/30215830/dockerfile-copy-keep-subdirectory-structure
COPY rootfs/ /


# each CMD = one temporary container!
# Note: it looks like php cannot start without /run/php/ because the service doesn't create it every first time
RUN rm -f /var/log/*log* \
&& ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
&& ln -sf /etc/environment /etc/default/php-fpm7.2 \
&& ln -sf /etc/php/7.2/mods-available/owncloud.ini /etc/php/7.2/fpm/conf.d/99-owncloud.ini \
&& chgrp root /etc/environment /etc/php/7.2/mods-available/owncloud.ini \
&& chmod g+w /etc/environment /etc/php/7.2/mods-available/owncloud.ini /var/www/owncloud \
&& chmod 755 /etc/owncloud.d/* /etc/entrypoint.d/* /root/.bashrc \
&& chown root:root /usr/bin/cronjob /usr/bin/entrypoint /usr/bin/healthcheck /usr/bin/occ /usr/bin/owncloud /usr/bin/server \
&& chmod 755 /usr/bin/cronjob /usr/bin/entrypoint /usr/bin/healthcheck /usr/bin/occ /usr/bin/owncloud /usr/bin/server


WORKDIR /var/www/owncloud
# this is duplicate with /etc/owncloud.d/25-chown.sh
# RUN find /var/www/owncloud \( \! -user www-data -o \! -group root \) -print0 | xargs -r -0 chown www-data:root \
# && chmod g+w /var/www/owncloud

EXPOSE ${INTERNAL_HTTP:-8081}
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/owncloud", "server"]

FROM owncloud/base:bionic

## Check latest version: https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule
ENV OWNCLOUD_VERSION="latest" \
    USER_LDAP_VERSION="0.11.0" \
    OWNCLOUD_IN_ROOTPATH="0" \
    OWNCLOUD_SERVERNAME="127.0.0.1"

LABEL maintainer="audioscavenger <dev@derewonko.com>" \
  org.label-schema.name="ownCloud Server LEMP" \
  org.label-schema.vendor="ownCloud GmbH" \
  org.label-schema.schema-version="1.0"
LABEL com.github.audioscavenger.owncloud.version="$OWNCLOUD_VERSION" \
  com.github.audioscavenger.owncloud.license="AGPL-3.0" \
  com.github.audioscavenger.owncloud.url="https://github.com/audioscavenger/owncloud-lemp"

RUN DEBIAN_FRONTEND=noninteractive ;\
apt-get update && \
apt-get -y upgrade && \
apt-get -y purge \
vim \
apache2 \
apache2-bin \
apache2-data \
apache2-dbg \
apache2-dev \
apache2-doc \
apache2-ssl-dev \
apache2-suexec-custom \
apache2-suexec-pristine \
apache2-utils && \
apt -y autoremove && \
apt -y autoclean

RUN DEBIAN_FRONTEND=noninteractive ;\
apt-get -y install \
net-tools \
nvi \
sudo \
smbclient \
openssl \
nginx-extras \
php-apcu \
php-fpm \
geoip-database \
libgeoip1 && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ADD local compressed files will unzip them but cannot be automated by docker hub:
#ADD owncloud-*.tar.bz2 /var/www/
#ADD user_ldap.tar.gz /var/www/owncloud/apps/

# ADD downloaded compressed files will NOT unzip them:
ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2
ADD https://github.com/owncloud/user_ldap/releases/download/v${USER_LDAP_VERSION}/user_ldap.tar.gz /var/www/owncloud/apps/user_ldap.tar.gz
RUN /bin/tar -xjf /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2 -C /var/www && /bin/rm /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2 && \
    /bin/tar -xzf /var/www/owncloud/apps/user_ldap.tar.gz -C /var/www/owncloud/apps && /bin/rm /var/www/owncloud/apps/user_ldap.tar.gz

COPY rootfs /

# https://stackoverflow.com/questions/30215830/dockerfile-copy-keep-subdirectory-structure
COPY configs/ /

# Note: it looks like php cannot start without /run/php/ because the service doesn't create it every first time
RUN /bin/rm -f /etc/cron.daily/apache2 /var/log/*log* && \
    /bin/ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
    /bin/ln -sf /etc/php/7.2/mods-available/owncloud.ini /etc/php/7.2/fpm/conf.d/99-owncloud.ini && \
    /bin/ln -sf /usr/bin/server.nginx /usr/bin/server && \
    /bin/ln -sf /etc/environment /etc/default/php-fpm7.2 && \
    /bin/mkdir -p /run/php && /bin/chown www-data:www-data /run/php && \
    /bin/chmod 755 /etc/owncloud.d/* /etc/entrypoint.d/* /root/.bashrc /usr/bin/server.*

# each CMD = one temporary container!
# CMD ["/bin/rm", "/etc/cron.daily/apache2"]
# CMD ["/bin/ln", "-sf", "/usr/share/zoneinfo/America/New_York", "/etc/localtime"]
# CMD ["/bin/ln", "-sf", "/etc/php/7.2/mods-available/owncloud.ini", "/etc/php/7.2/fpm/conf.d/99-owncloud.ini"]
# CMD ["/bin/ln", "-sf", "/usr/bin/server.nginx", "/usr/bin/server"]
# CMD ["/bin/chmod", "755", "/etc/owncloud.d/*", "/etc/entrypoint.d/*"]
# CMD ["/bin/chmod", "755", "/root/.bashrc"]

WORKDIR /var/www/owncloud
RUN find /var/www/owncloud \( \! -user www-data -o \! -group root \) -print0 | xargs -r -0 chown www-data:root && \
    chmod g+w /var/www/owncloud

VOLUME ["/mnt/data"]
EXPOSE 8081
ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["/usr/bin/owncloud", "server"]

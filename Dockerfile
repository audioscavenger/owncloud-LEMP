FROM owncloud/base:bionic

## Check latest version: https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule
ENV OWNCLOUD_VERSION="10.0.10" \
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
apt -y autoclean && \
apt-get clean

RUN DEBIAN_FRONTEND=noninteractive ;\
apt-get -y install \
bzip2 \
cron \
net-tools \
nvi \
sudo \
wget \
smbclient \
openssl \
nginx-extras \
php-apcu \
php-apcu \
php-fpm \
geoip-database \
libgeoip1

# ADD downloaded compressed files will NOT unzip them:
# ADD https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2 /var/www/owncloud-${OWNCLOUD_VERSION}.tar.bz2
# ADD https://github.com/owncloud/user_ldap/releases/download/v${USER_LDAP_VERSION}/user_ldap.tar.gz /var/www/owncloud/apps/user_ldap.tar.gz
# ADD compressed files will unzip them:
ADD owncloud-*.tar.bz2 /var/www/
ADD user_ldap.tar.gz /var/www/owncloud/apps/

COPY rootfs /

# https://stackoverflow.com/questions/30215830/dockerfile-copy-keep-subdirectory-structure
COPY configs/ /

RUN /bin/rm -f /etc/cron.daily/apache2 && \
/bin/ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime && \
/bin/ln -sf /etc/php/7.2/mods-available/owncloud.ini /etc/php/7.2/fpm/conf.d/99-owncloud.ini && \
/bin/ln -sf /usr/bin/server.nginx /usr/bin/server && \
/bin/chmod 755 /etc/owncloud.d/* /etc/entrypoint.d/* /root/.bashrc /usr/bin/server.*

# each CMD = one temporary container
# CMD ["/bin/rm", "/etc/cron.daily/apache2"]
# CMD ["/bin/ln", "-sf", "/usr/share/zoneinfo/America/New_York", "/etc/localtime"]
# CMD ["/bin/ln", "-sf", "/etc/php/7.2/mods-available/owncloud.ini", "/etc/php/7.2/fpm/conf.d/99-owncloud.ini"]
# CMD ["/bin/ln", "-sf", "/usr/bin/server.nginx", "/usr/bin/server"]
# CMD ["/bin/chmod", "755", "/etc/owncloud.d/*", "/etc/entrypoint.d/*"]
# CMD ["/bin/chmod", "755", "/root/.bashrc"]

RUN find /var/www/owncloud \( \! -user www-data -o \! -group root \) -print0 | xargs -r -0 chown www-data:root && \
chmod g+w /var/www/owncloud

ENTRYPOINT ["/usr/bin/entrypoint","server"]

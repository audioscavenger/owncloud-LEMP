# ownCloud:LEMP Stack
Managed by [audioscavenger/owncloud-lemp](https://github.com/audioscavenger/owncloud-lemp)

Based on [audioscavenger/ubuntu-lemp](https://github.com/audioscavenger/ubuntu-lemp)

## Presentation
This is a **fork** from official [ownCloud/server](https://hub.docker.com/r/owncloud/server) image for the community edition, it was built from their base container but now is based from a *clean*, **lightweight** ubuntu latest base + nginx + php7.2-fpm. This ownCloud image is designed to work with a data volume in the host filesystem and with separate MariaDB **and** Redis containers.

It features Nginx + PHP-fpm instead of apache2 + PHP-cli. Current image size = 639MB instead of 1.17GB.

### Usage
The *only* way that makes sense it to use it as a **backend**, as only HTTP is enabled by default.

Using it as a frontend is possible with domain certificates but then how do you do to have more than one application listen to 80/443? This is not possible and requires either using ip aliasing on the host, or having different ports per container/application + a reverse proxy at the front, which defeats the purpose of enabling SSL in the container.

### Notes
* "LEMP" is a language abuse as MySQL is not included in this image.

# Features
* **Superfast**
  * Uses PHP7.2 with APCu and Zend OpCache for maximum performance:
    * memcache.local = APCu user cache ([see why](https://www.it-cooking.com/technology/productivity/redis-vs-apcu-2018/))
    * memcache.distributed = Redis
    * memcache.locking = Redis
  * Uses Mariadb MySQL container for better I/O against sqlite
  * Listen to 127.0.0.1 instead of localhost, no dns resolution

![APCu screenshot](https://www.it-cooking.com/wp-content/uploads/2019/01/APCu-docker-owncloud-lemp-oq10.png)
![OPcache screenshot](https://www.it-cooking.com/wp-content/uploads/2019/01/op-ocp-docker-owncloud-lemp-oq10.png)

* **Scalable**
  * Uses Redis container for horizontal scaling

* **Monitoring Enabled**
  * Comes with cutting edge tools to monitor cache and debug (can be disabled):
    * apcu.php (from PHP Group)
    * op-ocp.php (Zend OPcode cache monitor by _ck_)
    * phpinfo.php
    * environ.php (check local env is ok)

* **Cutting Edge**
  * Based on Ubuntu 18.04
  * Automatic check if latest ownCloud version
  * Automatic init of Redis and MySQL databases

* **Best Practices**
  * Every last configuration has a variable attached
  * Rebuild configuration files at startup
  * Easy filesystem management if you use docker volumes as shown
  * Brain-dean network management with linked containers as shown
  * CloudFlare redirect resolution for client logging


## Content
- BASE audioscavenger/ubuntu-lemp <-- ubuntu:18.04
- owncloud:latest (10.0.10)
- nginx-extras 1.14
- php7.2-fpm (128MB default)
- APCu (1MB shm size default)

## Dependencies

See dockerfile for more details

* docker image audioscavenger/ubuntu-lemp:latest
* [owncloud/user_ldap 0.13.0](https://github.com/owncloud/user_ldap/releases/)
* [ownCloud tarball latest](https://download.owncloud.org/community/owncloud-latest.tar.bz2) (10.2.0 as of 2019/05/20)

# How to use it
Just follow the official instructions found at [Github - owncloud-docker/server](https://github.com/owncloud-docker/server).

## As a Back-End
By default this container **must** be used as a backend. You need to proxify it:

DNS --> host_ip --> host-Web-Server:443 --> proxy_pass --> http://127.0.0.1:8001/ (8001 or whatever port you setup)

## As a Front-End
The nginx configuration files and init scripts are ready to accept SSL certificates, but I really don't see the point. It's just offered as a possibility.

DNS --> host_ip --> container:80/443

# Launch with plain docker
The use of docker volumes is highly recommended. It's so much easier than linking to actual host folders and you can always access the files anyway.

## Install Mariadb + Redis
```
docker volume create owncloud_redis

REDIS_NAME=redis
docker run -d --name ${REDIS_NAME} \
-e TZ=`ls -la /etc/localtime | cut -d/ -f7-9` \
-e REDIS_DATABASES=1 \
--volume owncloud_redis:/var/lib/redis \
webhippie/redis:latest

docker volume create owncloud_mysql
docker volume create owncloud_backup

MARIADB_NAME=mariadb
docker run -d --name ${MARIADB_NAME} \
-e TZ=`ls -la /etc/localtime | cut -d/ -f7-9` \
-e MARIADB_ROOT_PASSWORD=owncloud \
-e MARIADB_USERNAME=owncloud \
-e MARIADB_PASSWORD=owncloud \
-e MARIADB_DATABASE=owncloud \
--volume owncloud_mysql:/var/lib/mysql \
--volume owncloud_backup:/var/lib/backup \
webhippie/mariadb:latest
```

## Install owncloud-lemp
Default mode: **Production** = environ.php, phpinfo, apcu.php and op-ocp.php are *disabled*.

**Staging**: Enable access to environ.php, phpinfo, apcu.php and op-ocp.php by adding `-e NGINX_ENABLE_TEST_URL=true \`

**DEBUG**: enable debug with `-e DEBUG=true \`

### As a Back-End

```
docker volume create owncloud_files

OWNCLOUD_NAME=owncloud-lemp
OWNCLOUD_VERSION=latest
OWNCLOUD_DOMAIN=127.0.0.1
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
NGINX_PORT=8001     # use whatever docker exposed port you like here
OWNCLOUD_VOLUME=owncloud_files

docker run -d --name ${OWNCLOUD_NAME} \
--link ${MARIADB_NAME}:db \
--link ${REDIS_NAME}:redis \
-p ${NGINX_PORT}:8081 \
-e TZ=`ls -la /etc/localtime | cut -d/ -f7-9` \
-e OWNCLOUD_DOMAIN=${OWNCLOUD_DOMAIN} \
-e OWNCLOUD_DB_TYPE=mysql \
-e OWNCLOUD_DB_NAME=owncloud \
-e OWNCLOUD_DB_USERNAME=owncloud \
-e OWNCLOUD_DB_PASSWORD=owncloud \
-e OWNCLOUD_DB_HOST=db \
-e OWNCLOUD_ADMIN_USERNAME=${ADMIN_USERNAME} \
-e OWNCLOUD_ADMIN_PASSWORD=${ADMIN_PASSWORD} \
-e OWNCLOUD_REDIS_ENABLED=true \
-e OWNCLOUD_REDIS_HOST=${REDIS_NAME} \
--volume ${OWNCLOUD_VOLUME}:/mnt/data \
audioscavenger/owncloud-lemp:${OWNCLOUD_VERSION}
```

### As a Front-End
Again, not recommended unless the container is the only one application listening to 80/443 on your host.

#### Certificate files
* Place them under `<local-owncloud-volume>/_data/ssl/` (`/mnt/data/ssl/` in the container)
* Certificate name: `${NGINX_SERVER_NAME}.crt`
* Certificate key name: `${NGINX_SERVER_NAME}.key`

#### Container parameters
You will have to pass the domain name, server name, HTTP and HTTPS listen ports during container creation to activate HTTPS (yes it's automatic):

```
docker volume create owncloud_files

OWNCLOUD_NAME=owncloud-lemp
OWNCLOUD_VERSION=latest
OWNCLOUD_DOMAIN=domain.example.com
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin
NGINX_LISTEN=80
NGINX_LISTEN_SSL=443
OWNCLOUD_VOLUME=owncloud_files

docker run -d --name ${OWNCLOUD_NAME} \
--link ${MARIADB_NAME}:db \
--link ${REDIS_NAME}:redis \
-p 80:${NGINX_LISTEN} \
-p 443:${NGINX_LISTEN_SSL} \
-e TZ=`ls -la /etc/localtime | cut -d/ -f7-9` \
-e OWNCLOUD_DOMAIN=${OWNCLOUD_DOMAIN} \
-e NGINX_SERVER_NAME=${OWNCLOUD_DOMAIN}
-e OWNCLOUD_DB_TYPE=mysql \
-e OWNCLOUD_DB_NAME=owncloud \
-e OWNCLOUD_DB_USERNAME=owncloud \
-e OWNCLOUD_DB_PASSWORD=owncloud \
-e OWNCLOUD_DB_HOST=db \
-e OWNCLOUD_ADMIN_USERNAME=${ADMIN_USERNAME} \
-e OWNCLOUD_ADMIN_PASSWORD=${ADMIN_PASSWORD} \
-e OWNCLOUD_REDIS_ENABLED=true \
-e OWNCLOUD_REDIS_HOST=${REDIS_NAME} \
--volume ${OWNCLOUD_VOLUME}:/mnt/data \
audioscavenger/owncloud-lemp:${OWNCLOUD_VERSION}
```

*WARNING* This has not been tested yet but I garantee a 99% chance it works as expected.

## Follow logs

### Container logs
* Follow everything that's logging to stdout and stderr:
`docker logs -f ${OWNCLOUD_NAME}`

* Anything that's logging to /mnt/data/ can be found on the host in the volume path:
`/<installdir>/docker/volumes/owncloud_files/_data/`


### Owncloud logs
* By default, owncloud log to /mnt/data/files/owncloud.log
* By default, severity = 2 = WARN
* Change owncloud log severity at container creation with `-e OWNCLOUD_LOG_LEVEL=n`
  * 0: DEBUG
  * 1: INFO
  * 2: WARN (default)
  * 3: ERROR
  * 4: FATAL


### Nginx logs
* By default, nginx logs are *disabled*
  * Enable nginx logs at container creation with `-e NGINX_ENABLE_LOG=true`
* If enabled, by default nginx logs go to /dev/stdout + /dev/stderr 
  * Enable nginx logs to /mnt/data/ at container creation with `-e NGINX_DEFAULT_ACCESS_LOG=/mnt/data/access.log -e NGINX_DEFAULT_ERROR_LOG=/mnt/data/error.log`
  * Change nginx log severity at container creation with `-e NGINX_LOG_LEVEL=level`
    * info
    * notice
    * warn
    * error (default)
    * crit
    * alert
    * emerg

## Connect a terminal
`docker exec -it ${OWNCLOUD_NAME} bash`

## URLs available
The docker host exposed port = 8001 = example
* ownCloud server: http://localhost:8001
* URL below can be enabled by creating the container with `-e NGINX_ENABLE_TEST_URL=true \`
  * APCu stats: http://localhost:8001/apcu.php
  * OP cache status: http://localhost:8001/op-ocp.php
  * Environ variables: http://localhost:8001/environ.php
  * PHP info: http://localhost:8001/phpinfo.php

# Build
By default, LEMP_VERSION == OWNCLOUD_VERSION == latest

## build latest
```
git clone https://github.com/audioscavenger/owncloud-lemp
cd owncloud-lemp
docker build .
```


## build with Specific versions
* Example 1: build with custom tag using OWNCLOUD_VERSION _10.2.0_ instead of _latest_ (because _latest_ points to current stable: 10.0.10):
```
docker build -e OWNCLOUD_VERSION=10.2.0 -t owncloud-lemp:10.2.0-rc1 .
```

* Example 2: build with custom tag using a different version FROM ubuntu-lemp _0.14-7.3_ instead of _latest_:
```
docker build --build-arg LEMP_VERSION=0.14-7.3 -t owncloud-lemp:test-php7.3 .
```

## Build Environment Variables
```
ARG LEMP_VERSION=latest
ARG OWNCLOUD_VERSION=latest

ENV USER_LDAP_VERSION "0.13.0"
ENV OWNCLOUD_IN_ROOTPATH "0"
ENV OWNCLOUD_SERVERNAME "127.0.0.1"
ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
ENV TZ America/New_York
ENV INTERNAL_HTTP 8081
```


# Useful resources
* [Download ownCloud Client](https://owncloud.org/download/#owncloud-desktop-client-windows)
* [ownCloud Release Schedule](https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule)
* [ownCloud/server image](https://hub.docker.com/r/owncloud/server)
* [Github maintainer](https://github.com/audioscavenger/owncloud-lemp)

# Modifications from the official build
## Packages added:
* software-properties-common
* nvi
* nginx-extras
* php-apcu
* php7.2-fpm
* php7.2-opcache

## Files modified:
* /usr/bin/server
* /root/.bashrc
* /etc/bash.bashrc
* /etc/entrypoint.d/10-base.sh
* /etc/templates/owncloud.ini
* /etc/php/7.2/fpm/pool.d/www.conf
* /etc/nginx/sites-available/default
* /var/www/owncloud/.user.ini

## Files added:
* /etc/entrypoint.d/45-php.sh
* /etc/entrypoint.d/99-nginx.sh
* /etc/owncloud.d/46-php-fpm.sh
* /etc/owncloud.d/51-nginx.sh
* /etc/templates/default
* /etc/templates/nginx.conf
* /etc/templates/www.custom.conf
* /var/www/html/apcu.php
* /var/www/html/environ.php
* /var/www/html/op-ocp.php
* /var/www/html/phpinfo.php


# Notes

## Todo List
- [x] disable opcache revalidate
- [ ] optimize opcache size
- [x] with v0.13.0 they changed the naming format of the tarball to user_ldap-${USER_LDAP_VERSION}.tar.gz
- [x] configure frontend and backend
- [x] test bandwidth and CPU usage with different sized folders
- [x] max file size tested = 1GB
- [x] commits and tests with new containers
- [x] upload manually modified image
- [x] reverse engineer Dockerfile
- [x] rebuild from Dockerfile
- [x] upload image built with Dockerfile
- [x] remove jchaney folder
- [ ] find free alternative to geoip-database (https://lite.ip2location.com/ ?)
- [ ] update Vagrantfile and check what it actually is
- [ ] update docker-compose.yml
- [ ] integrate with drone CI + .drone.yml
- [ ] offer SSL frontend
- [ ] offer SSL autoconfig with letsencrypt for a dedicated container on port 80/443

## License
This project is distributed under [GNU Affero General Public License, Version 3][AGPLv3].

# Debug and Variables list
## Entrypoint & Startup
* ENTRYPOINT ["/usr/bin/entrypoint"]  - loads environment from /etc/entrypoint.d/*
* CMD ["/usr/bin/owncloud", "server"] - actual image startup

## Environment
All the variables set are found under `/etc/entrypoint.d/`and can be overridden when creating the container with `-e VARIABLE=value`.

Below is a list of what you can customize, showing default values:

```
DB_ENV_CRON_ENABLED=true
DB_ENV_MARIADB_DATABASE=owncloud
DB_ENV_MARIADB_PASSWORD=owncloud
DB_ENV_MARIADB_ROOT_PASSWORD=owncloud
DB_ENV_MARIADB_USERNAME=owncloud
DB_ENV_TERM=xterm
DB_ENV_TZ=New_York
LANG=C
TZ=America/New_York

NGINX_ENABLE_LOG=false
NGINX_LOG_LEVEL=error
NGINX_LOG_FORMAT=combined
NGINX_DEFAULT_ACCESS_LOG=/dev/stdout
NGINX_DEFAULT_ERROR_LOG=/dev/stderr
NGINX_ACCESS_LOG=off
NGINX_ERROR_LOG=off
NGINX_ENABLED_TEST_URL=#rewrite ^ /index.php;
NGINX_ENABLE_TEST_URL=false
NGINX_ENTRYPOINT_INITIALIZED=true
NGINX_KEEP_ALIVE_TIMEOUT=65
NGINX_LISTEN=8081
NGINX_LISTEN_SSL=
NGINX_PID_FILE=/var/run/nginx.pid
NGINX_ROOT=/var/www/owncloud
NGINX_ROOT_ACME_CHALLENGE=/var/www/html
NGINX_ROOT_TEST_URL=/var/www/html
NGINX_RUN_GROUP=www-data
NGINX_RUN_USER=www-data
NGINX_SERVER_NAME=_
NGINX_SERVER_SIGNATURE=Off
NGINX_WORKER_CONNECTIONS=1024

OWNCLOUD_ACCOUNTS_ENABLE_MEDIAL_SEARCH=
OWNCLOUD_ADMIN_PASSWORD=admin
OWNCLOUD_ADMIN_USERNAME=admin
OWNCLOUD_ALLOW_USER_TO_CHANGE_DISPLAY_NAME=
OWNCLOUD_APPSTORE_URL=
OWNCLOUD_APPS_DISABLE=
OWNCLOUD_APPS_ENABLE=
OWNCLOUD_APPS_INSTALL=
OWNCLOUD_APPS_UNINSTALL=
OWNCLOUD_BACKGROUND_MODE=cron
OWNCLOUD_BLACKLISTED_FILES=
OWNCLOUD_CACHE_CHUNK_GC_TTL=
OWNCLOUD_CACHE_PATH=
OWNCLOUD_CHECK_FOR_WORKING_WELLKNOWN_SETUP=
OWNCLOUD_CIPHER=
OWNCLOUD_COMMENTS_MANAGER_FACTORY=
OWNCLOUD_CORS_ALLOWED_DOMAINS=
OWNCLOUD_CROND_ENABLED=true
OWNCLOUD_CRON_LOG=
OWNCLOUD_CSRF_DISABLED=
OWNCLOUD_DAV_CHUNK_BASE_DIR=
OWNCLOUD_DAV_ENABLE_ASYNC=
OWNCLOUD_DB_FAIL=true
OWNCLOUD_DB_HOST=db
OWNCLOUD_DB_NAME=owncloud
OWNCLOUD_DB_PASSWORD=owncloud
OWNCLOUD_DB_PREFIX=oc_
OWNCLOUD_DB_TIMEOUT=180
OWNCLOUD_DB_TYPE=mysql
OWNCLOUD_DB_USERNAME=owncloud
OWNCLOUD_DEBUG=
OWNCLOUD_DEFAULT_APP=
OWNCLOUD_DEFAULT_LANGUAGE=en
OWNCLOUD_DOMAIN=127.0.0.1
OWNCLOUD_ENABLED_PREVIEW_PROVIDERS=
OWNCLOUD_ENABLE_AVATARS=
OWNCLOUD_ENABLE_CERTIFICATE_MANAGEMENT=
OWNCLOUD_ENABLE_PREVIEWS=
OWNCLOUD_ENTRYPOINT_INITIALIZED=true
OWNCLOUD_EXCLUDED_DIRECTORIES=
OWNCLOUD_FILELOCKING_ENABLED=true
OWNCLOUD_FILELOCKING_TTL=
OWNCLOUD_FILESYSTEM_CACHE_READONLY=
OWNCLOUD_FILESYSTEM_CHECK_CHANGES=
OWNCLOUD_FILES_EXTERNAL_ALLOW_NEW_LOCAL=
OWNCLOUD_FORWARDED_FOR_HEADERS=
OWNCLOUD_HASHING_COST=
OWNCLOUD_HAS_INTERNET_CONNECTION=
OWNCLOUD_HTACCESS_REWRITE_BASE=/
OWNCLOUD_INTEGRITY_EXCLUDED_FILES=
OWNCLOUD_INTEGRITY_IGNORE_MISSING_APP_SIGNATURE=
OWNCLOUD_KNOWLEDGEBASE_ENABLED=
OWNCLOUD_LICENSE_KEY=
OWNCLOUD_LOGIN_ALTERNATIVES=
OWNCLOUD_LOG_DATE_FORMAT=
OWNCLOUD_LOG_FILE=/mnt/data/files/owncloud.log
OWNCLOUD_LOG_LEVEL=2
OWNCLOUD_LOG_ROTATE_SIZE=
OWNCLOUD_LOG_TIMEZONE=
OWNCLOUD_LOST_PASSWORD_LINK=
OWNCLOUD_MAIL_DOMAIN=
OWNCLOUD_MAIL_FROM_ADDRESS=
OWNCLOUD_MAIL_SMTP_AUTH=
OWNCLOUD_MAIL_SMTP_AUTH_TYPE=
OWNCLOUD_MAIL_SMTP_DEBUG=
OWNCLOUD_MAIL_SMTP_HOST=
OWNCLOUD_MAIL_SMTP_MODE=
OWNCLOUD_MAIL_SMTP_NAME=
OWNCLOUD_MAIL_SMTP_PASSWORD=
OWNCLOUD_MAIL_SMTP_PORT=
OWNCLOUD_MAIL_SMTP_SECURE=
OWNCLOUD_MAIL_SMTP_TIMEOUT=
OWNCLOUD_MAINTENANCE=
OWNCLOUD_MARKETPLACE_CA=
OWNCLOUD_MARKETPLACE_KEY=
OWNCLOUD_MAX_EXECUTION_TIME=3600
OWNCLOUD_MAX_FILESIZE_ANIMATED_GIFS_PUBLIC_SHARING=
OWNCLOUD_MAX_INPUT_TIME=3600
OWNCLOUD_MAX_UPLOAD=20G
OWNCLOUD_MEMCACHED_ENABLED=false
OWNCLOUD_MEMCACHED_HOST=memcached
OWNCLOUD_MEMCACHED_OPTIONS=
OWNCLOUD_MEMCACHED_PORT=11211
OWNCLOUD_MEMCACHE_LOCAL=\OC\Memcache\APCu
OWNCLOUD_MEMCACHE_LOCKING=
OWNCLOUD_MINIMUM_SUPPORTED_DESKTOP_VERSION=
OWNCLOUD_MOUNT_FILE=
OWNCLOUD_MYSQL_UTF8MB4=
OWNCLOUD_OBJECTSTORE_AUTOCREATE=true
OWNCLOUD_OBJECTSTORE_BUCKET=owncloud
OWNCLOUD_OBJECTSTORE_CLASS=OCA\ObjectStore\S3
OWNCLOUD_OBJECTSTORE_ENABLED=false
OWNCLOUD_OBJECTSTORE_ENDPOINT=xxxxxxxxxxx
OWNCLOUD_OBJECTSTORE_KEY=
OWNCLOUD_OBJECTSTORE_PATHSTYLE=false
OWNCLOUD_OBJECTSTORE_REGION=xxxxxxxxxx
OWNCLOUD_OBJECTSTORE_SECRET=
OWNCLOUD_OBJECTSTORE_VERSION=2006-03-01
OWNCLOUD_OPERATION_MODE=
OWNCLOUD_OVERWRITE_CLI_URL=http://127.0.0.1/
OWNCLOUD_OVERWRITE_COND_ADDR=
OWNCLOUD_OVERWRITE_HOST=
OWNCLOUD_OVERWRITE_PROTOCOL=
OWNCLOUD_OVERWRITE_WEBROOT=
OWNCLOUD_PART_FILE_IN_STORAGE=
OWNCLOUD_POST_CRONJOB_PATH=/etc/post_cronjob.d
OWNCLOUD_POST_INSTALL_PATH=/etc/post_install.d
OWNCLOUD_POST_SERVER_PATH=/etc/post_server.d
OWNCLOUD_PREVIEW_LIBREOFFICE_PATH=
OWNCLOUD_PREVIEW_MAX_FILESIZE_IMAGE=
OWNCLOUD_PREVIEW_MAX_SCALE_FACTOR=
OWNCLOUD_PREVIEW_MAX_X=
OWNCLOUD_PREVIEW_MAX_Y=
OWNCLOUD_PREVIEW_OFFICE_CL_PARAMETERS=
OWNCLOUD_PRE_CRONJOB_PATH=/etc/pre_cronjob.d
OWNCLOUD_PRE_INSTALL_PATH=/etc/pre_install.d
OWNCLOUD_PRE_SERVER_PATH=/etc/pre_server.d
OWNCLOUD_PROTOCOL=http
OWNCLOUD_PROXY=
OWNCLOUD_PROXY_USERPWD=
OWNCLOUD_QUOTA_INCLUDE_EXTERNAL_STORAGE=
OWNCLOUD_REDIS_DB=
OWNCLOUD_REDIS_ENABLED=true
OWNCLOUD_REDIS_HOST=redis
OWNCLOUD_REDIS_PASSWORD=
OWNCLOUD_REDIS_PORT=6379
OWNCLOUD_REDIS_TIMEOUT=
OWNCLOUD_REMEMBER_LOGIN_COOKIE_LIFETIME=
OWNCLOUD_SECRET=
OWNCLOUD_SESSION_KEEPALIVE=
OWNCLOUD_SESSION_LIFETIME=
OWNCLOUD_SESSION_SAVE_HANDLER=files
OWNCLOUD_SESSION_SAVE_PATH=/mnt/data/sessions
OWNCLOUD_SHARE_FOLDER=
OWNCLOUD_SHARING_FEDERATION_ALLOW_HTTP_FALLBACK=
OWNCLOUD_SHARING_MANAGER_FACTORY=
OWNCLOUD_SHOW_SERVER_HOSTNAME=
OWNCLOUD_SINGLEUSER=
OWNCLOUD_SKELETON_DIRECTORY=
OWNCLOUD_SKIP_CHMOD=false
OWNCLOUD_SKIP_CHOWN=false
OWNCLOUD_SMB_LOGGING_ENABLE=
OWNCLOUD_SQLITE_JOURNAL_MODE=
OWNCLOUD_SUB_URL=/
OWNCLOUD_SYSTEMTAGS_MANAGER_FACTORY=
OWNCLOUD_TEMP_DIRECTORY=
OWNCLOUD_TOKEN_AUTH_ENFORCED=
OWNCLOUD_TRASHBIN_PURGE_LIMIT=
OWNCLOUD_TRASHBIN_RETENTION_OBLIGATION=
OWNCLOUD_TRUSTED_PROXIES=
OWNCLOUD_UPDATER_SERVER_URL=
OWNCLOUD_UPDATE_CHECKER=
OWNCLOUD_UPGRADE_AUTOMATIC_APP_UPDATES=
OWNCLOUD_USER_SEARCH_MIN_LENGTH=
OWNCLOUD_VERSIONS_RETENTION_OBLIGATION=
OWNCLOUD_VERSION_HIDE=
OWNCLOUD_VOLUME_APPS=/mnt/data/apps
OWNCLOUD_VOLUME_CONFIG=/mnt/data/config
OWNCLOUD_VOLUME_FILES=/mnt/data/files
OWNCLOUD_VOLUME_ROOT=/mnt/data
OWNCLOUD_VOLUME_SESSIONS=/mnt/data/sessions

PHP_ALLOWED_CLIENTS=127.0.0.1
PHP_APC_SHM_SIZE=1M
PHP_MEMORY_LIMIT=128M
PHP_PING=/ping
PHP_PM=dynamic
PHP_PM_MAX_CHILDREN=16
PHP_PM_MAX_REQUESTS=16384
PHP_PM_MAX_SPARE_SERVERS=4
PHP_PM_MIN_SPARE_SERVERS=1
PHP_PM_START_SERVERS=1
PHP_PONG=pong
PHP_STATUS_PATH=/phpstatus

REDIS_ENV_CRON_ENABLED=false
REDIS_ENV_REDIS_DATABASES=1
REDIS_ENV_TERM=xterm
REDIS_ENV_TZ=New_York
REDIS_PORT=tcp://11.2.3.4:6379
REDIS_PORT_6379_TCP=tcp://1.2.3.4:6379
REDIS_PORT_6379_TCP_ADDR=1.2.3.4
REDIS_PORT_6379_TCP_PORT=6379
REDIS_PORT_6379_TCP_PROTO=tcp
```

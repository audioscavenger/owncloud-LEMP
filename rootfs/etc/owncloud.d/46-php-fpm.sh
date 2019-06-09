#!/usr/bin/env bash
set -eo pipefail
[[ "${DEBUG}" == "true" ]] && set -x

if [[ -z "${OWNCLOUD_ENTRYPOINT_INITIALIZED}" ]]
then
  for FILE in $(find /etc/entrypoint.d -iname \*.sh | sort)
  do
    source ${FILE}
  done
fi

if [[ -d "${OWNCLOUD_PRE_SERVER_PATH}" ]]
then
  for FILE in $(find ${OWNCLOUD_PRE_SERVER_PATH} -iname *.sh | sort)
  do
    source ${FILE}
  done
fi

echo "Miscellaneous optimizations"
echo opcache.validate_timestamps=0 >>/etc/php/${PHP_VERSION_MAIN}/fpm/php.ini

echo "Creating php${PHP_VERSION_MAIN}-fpm environ..."
/usr/bin/env | /usr/bin/awk -F= '/OWNCLOUD/ {print "export "$1"=\""$2"\""}' >/etc/default/php-fpm${PHP_VERSION_MAIN} && /bin/chmod 755 /etc/default/php-fpm${PHP_VERSION_MAIN}

echo "Starting php${PHP_VERSION_MAIN}-fpm daemon..."
# /usr/sbin/php-fpm${PHP_VERSION_MAIN} --force-stderr --daemonize
# /usr/sbin/service php${PHP_VERSION_MAIN}-fpm stop
# /usr/sbin/php-fpm${PHP_VERSION_MAIN}
# Note: it is NOT possible to keep the environment when using service to start a daemon.
# System files would have to be modified which is not acceptable.
# Therefore, the trick is to link /etc/default/php-fpm${PHP_VERSION_MAIN} to /etc/environment
/usr/sbin/service php${PHP_VERSION_MAIN}-fpm restart

if [[ -d "${OWNCLOUD_POST_SERVER_PATH}" ]]
then
  for FILE in $(find ${OWNCLOUD_POST_SERVER_PATH} -iname *.sh | sort)
  do
    source ${FILE}
  done
fi

true

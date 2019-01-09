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

echo "Creating php7.2-fpm environ..."
/usr/bin/env | /usr/bin/awk -F= '/OWNCLOUD/ {print "export "$1"=\""$2"\""}' >/etc/default/php-fpm7.2 && /bin/chmod 755 /etc/default/php-fpm7.2

echo "Starting php7.2-fpm daemon..."
# /usr/sbin/php-fpm7.2 --force-stderr --daemonize
# /usr/sbin/service php7.2-fpm stop
# /usr/sbin/php-fpm7.2
# Note: it is NOT possible to keep the environment when using service to start a daemon.
# System files would have to be modified which is not acceptable.
# Therefore, the trick is to link /etc/default/php-fpm7.2 to /etc/environment
/usr/sbin/service php7.2-fpm restart

if [[ -d "${OWNCLOUD_POST_SERVER_PATH}" ]]
then
  for FILE in $(find ${OWNCLOUD_POST_SERVER_PATH} -iname *.sh | sort)
  do
    source ${FILE}
  done
fi

true

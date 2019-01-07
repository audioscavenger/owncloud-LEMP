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

echo "Starting php-fpm daemon..."
#/usr/sbin/php-fpm7.2 --force-stderr --daemonize
/usr/sbin/service php7.2-fpm stop
/usr/sbin/php-fpm7.2

if [[ -d "${OWNCLOUD_POST_SERVER_PATH}" ]]
then
  for FILE in $(find ${OWNCLOUD_POST_SERVER_PATH} -iname *.sh | sort)
  do
    source ${FILE}
  done
fi

true

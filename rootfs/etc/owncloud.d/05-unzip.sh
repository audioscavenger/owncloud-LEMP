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

if [ -f /var/www/owncloud-*.tar.bz2 ]
then
  ls /var/www/owncloud-*.tar.bz2
  echo "Unpacking /var/www/owncloud-*.tar.bz2..."
  tar -xjf /var/www/owncloud-*.tar.bz2 -C /var/www && rm /var/www/owncloud-*.tar.bz2
fi

if [ -f /var/www/user_ldap.tar.gz ]
then
  echo "Unpacking /var/www/user_ldap.tar.gz..."
  tar -xzf /var/www/user_ldap.tar.gz -C /var/www/owncloud/apps && rm /var/www/user_ldap.tar.gz
fi

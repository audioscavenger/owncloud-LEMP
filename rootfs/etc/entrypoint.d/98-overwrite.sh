#!/usr/bin/env bash

export HOME="${HOME:-/var/www/owncloud}"
export LANG="${LANG:-C}"

export NGINX_ERROR_LOG="${OWNCLOUD_ERRORLOG_LOCATION:-off}"
export NGINX_ACCESS_LOG="${OWNCLOUD_ACCESSLOG_LOCATION:-off}"
export NGINX_ROOT="${NGINX_ROOT:-/var/www/owncloud}"
export NGINX_LISTEN="${NGINX_LISTEN:-8081}"

# Write env to file for crond
env >| /etc/environment

true

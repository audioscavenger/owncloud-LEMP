#!/usr/bin/env bash

export HOME="${HOME:-/var/www/owncloud}"
export TZ="${TZ:-`ls -la /etc/localtime | cut -d/ -f7-9`}"
export LANG="${LANG:-C}"

# NGINX_ACCESS_LOG and NGINX_ERROR_LOG are used in the nginx.conf template
export NGINX_ACCESS_LOG="off"
export NGINX_ERROR_LOG="off"
export NGINX_ROOT="${NGINX_ROOT:-/var/www/owncloud}"
export NGINX_LISTEN="${NGINX_LISTEN:-8081}"

# Write env to file for crond
env >| /etc/environment

true

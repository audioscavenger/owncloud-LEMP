#!/usr/bin/env bash

declare -x PHP_ALLOWED_CLIENTS
[[ -z "${PHP_ALLOWED_CLIENTS}" ]] && PHP_ALLOWED_CLIENTS="127.0.0.1"

declare -x PHP_STATUS_PATH
[[ -z "${PHP_STATUS_PATH}" ]] && PHP_STATUS_PATH="/phpstatus"

declare -x PHP_PING
[[ -z "${PHP_PING}" ]] && PHP_PING="/ping"

declare -x PHP_PONG
[[ -z "${PHP_PONG}" ]] && PHP_PONG="pong"

declare -x PHP_PM
[[ -z "${PHP_PM}" ]] && PHP_PM="dynamic"

declare -x PHP_PM_MAX_CHILDREN
[[ -z "${PHP_PM_MAX_CHILDREN}" ]] && PHP_PM_MAX_CHILDREN="16"

declare -x PHP_PM_START_SERVERS
[[ -z "${PHP_PM_START_SERVERS}" ]] && PHP_PM_START_SERVERS="1"

declare -x PHP_PM_MIN_SPARE_SERVERS
[[ -z "${PHP_PM_MIN_SPARE_SERVERS}" ]] && PHP_PM_MIN_SPARE_SERVERS="1"

declare -x PHP_PM_MAX_SPARE_SERVERS
[[ -z "${PHP_PM_MAX_SPARE_SERVERS}" ]] && PHP_PM_MAX_SPARE_SERVERS="4"

declare -x PHP_PM_MAX_REQUESTS
[[ -z "${PHP_PM_MAX_REQUESTS}" ]] && PHP_PM_MAX_REQUESTS="16384"

declare -x PHP_MEMORY_LIMIT
[[ -z "${PHP_MEMORY_LIMIT}" ]] && PHP_MEMORY_LIMIT="128M"

declare -x PHP_APC_SHM_SIZE
[[ -z "${PHP_APC_SHM_SIZE}" ]] && PHP_APC_SHM_SIZE="1M"

true

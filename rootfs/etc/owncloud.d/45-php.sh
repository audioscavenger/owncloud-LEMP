#!/usr/bin/env bash

echo "Writing objectstore config..."
gomplate \
  -f /etc/templates/objectstore.php \
  -o ${OWNCLOUD_VOLUME_CONFIG}/objectstore.config.php

echo "Writing php config..."
gomplate \
  -f /etc/templates/owncloud.ini \
  -o /etc/php/${PHP_VERSION_MAIN}/mods-available/owncloud.ini

echo "Writing php www.custom.conf..."
gomplate \
  -f /etc/templates/www.custom.conf \
  -o /etc/php/${PHP_VERSION_MAIN}/fpm/pool.d/www.custom.conf

true

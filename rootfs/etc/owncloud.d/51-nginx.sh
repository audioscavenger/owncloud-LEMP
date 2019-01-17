#!/usr/bin/env bash

echo "Writing nginx config..."
gomplate \
  -f /etc/templates/nginx.conf \
  -o /etc/nginx/nginx.conf

echo "Writing nginx default site..."
gomplate \
  -f /etc/templates/default \
  -o /etc/nginx/sites-available/default

true

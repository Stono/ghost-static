#!/bin/bash
set -e
echo "options single-request" >> /etc/resolv.conf

cd $GHOST_HOME/current
url=http://$GHOST_DOMAIN npm start

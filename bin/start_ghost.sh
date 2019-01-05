#!/bin/bash
set -e
echo "options single-request" >> /etc/resolv.conf

cd $GHOST_HOME/current
url=http://127.0.0.1 npm start

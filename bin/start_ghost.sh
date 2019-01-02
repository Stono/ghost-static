#!/bin/bash
set -e
echo "options single-request" >> /etc/resolv.conf
cd $GHOST_HOME/current
npm start

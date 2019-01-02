#!/bin/bash
set -e

su -c 'cd $GHOST_HOME/current && npm start' www-data

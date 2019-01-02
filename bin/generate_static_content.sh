#!/bin/bash
cd /tmp
rm -rf static
mkdir -p static/content
cp -R $GHOST_HOME/current/content/images static/content/

gssg --url 'http://127.0.0.1:2368' --dest static
gsutil -m rsync -R static gs://karlstoney.com

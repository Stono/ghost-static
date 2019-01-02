#!/bin/bash
cd /tmp
rm -rf static
mkdir -p static/content
cp -R $GHOST_HOME/current/content/images static/content/

echo "Running gssg..."
gssg --domain 'http://karlstoney.com' --dest static --url 'https://karlstoney.com'
echo "Static content generated!  Uploading to gcs..."
gsutil -m rsync -R static gs://karlstoney.com

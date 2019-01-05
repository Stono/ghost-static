#!/bin/bash
cd /tmp
rm -rf static
mkdir -p static/content
cp -R $GHOST_HOME/current/content/images static/content/

echo "Running gssg..."
gssg --domain "http://$GHOST_DOMAIN" --dest static --url "https://$GHOST_DOMAIN"
echo "Static content generated!"
echo "Uploading to gcs..."
gsutil -m rsync -R static gs://$GHOST_DOMAIN

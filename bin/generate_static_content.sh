#!/bin/bash
cd /static
rm -rf *
mkdir content
cp -R $GHOST_HOME/current/content/images content/

echo "Running gssg..."
gssg --domain "http://127.0.0.1" --dest . --url "https://$GHOST_DOMAIN"
echo "Static content generated!"
echo "Uploading to gcs..."
gsutil -m rsync -R . gs://$GHOST_DOMAIN

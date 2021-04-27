#!/bin/bash
set -e 
cd /static
rm -rf *
mkdir content

echo "Running gssg..."
gssg --domain "http://127.0.0.1" --dest . --url "https://$GHOST_DOMAIN"

echo "Download all sizes of images"
cd /static/content/images
sizes=( "w600" "w1000" "w1600" "w2000" )

function getImage() {
  file=$1
  for size in "${sizes[@]}"; do
    targetFile="/static/content/images/size/$size/$file"
    path=$(dirname $targetFile)
    mkdir -p $path
    if [ ! -f $targetFile ]; then
      echo "Getting:  $targetFile"
      curl -f --silent -o $targetFile http://127.0.0.1/content/images/size/$size/$file
    else 
      echo "Skipping: $targetFile"
    fi
  done
}

echo "Downloading images that have already been sized"
cd /static/content/images 
for file in $(find size -type f -o -name "*.png"); do
  source=$(echo $file | sed 's,^[^/]*/,,' | sed 's,^[^/]*/,,')
  getImage $source
done

echo "Downloading images that have not already been sized"
for file in $(find . -path ./size -prune -type f -o -name "*.png"); do
  source=$(echo $file | sed 's,^[^/]*/,,')
  getImage $source
done

echo "Static content generated!"
echo "Uploading to gcs..."
cd /static 
gsutil -h "Cache-Control:no-cache,max-age=0" -m rsync -d -c -R . gs://$GHOST_DOMAIN

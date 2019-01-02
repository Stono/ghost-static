# Ghost static site in a Dockerfile
This is a dockerfile which allows you to build a site using the ghost blogging platform, and then generate it all as static content.  It also includes the utilities required to upload it to Google Cloud Storage.

It's pretty opinionated in that it:

  - Has disqus comments enabled
  - Uses date url slugs (eg https://karlstoney.com/2018/07/07/managing-your-costs-on-kubernetes), although you can change this by editing [data/settings/routes.yaml](data/settings/routes.yaml).
  - Expects your domain to be hosted on https://
  - In order to use the gstuil upload to a gcs bucket, you have gcloud authenticated on your host machine 
  
That's because it's for my blog at https://karlstoney.com, however you're free to use it - you'll just need to:

  - edit docker-compose.yml and replace the domain with your own
  - edit patches/disqus.patch and update your disqus id

## Starting ghost
Simply do a `docker-compose up`.  Your data will be persisted to the `/data/content/` volume mounts so you can start and stop the container whenever you need.

## Editing your content
Once ghost is running, go to `http://127.0.0.1` and use it just like you would anywhere else, modify your content and so on.

## Generating your static content
When you're happy with your content, you want to crawl the site and generate a static version so we can store it in a bucket.  I've added one helper script in [bin/generate_static_content.sh](bin/generate_static_content.sh) which will:

  - Use [ghost-static-site-generator](https://github.com/Fried-Chicken/ghost-static-site-generator) to generate the static content
  - Use gsutil to upload your content to a bucket (make sure the bucket exists for your domain)

In order to run it, make sure ghost is running with `docker-compose up` and then in another window do `docker-compose exec app /usr/local/bin/generate_static_content.sh`.

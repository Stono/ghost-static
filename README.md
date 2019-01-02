# Ghost static site in a Dockerfile
This is a dockerfile which allows you to build a site using the ghost blogging platform, and then generate it all as static content.  It also includes the utilities required to upload it to Google Cloud Storage.

It's pretty opinionated as it's for my blog at https://karlstoney.com, but you're free to use it.  You just need to:

  - edit docker-compose.yml and replace the domains with your own
  - edit patches/disqus.patch and update your disqus id

## Starting ghost
Simply do a `docker-compose up`.  Your data will be persisted to the `/data/content/` volume mounts so you can start and stop the container whenever you need.

## Editing your content
Once ghost is running, go to `http://127.0.0.1` and use it just like you would anywhere else, modify your content and so on.

## Generating your static content
I've added one helper script in [bin/generate_static_content.sh](bin/generate_static_content.sh) which will:

  - Use [ghost-static-site-generator](https://github.com/Fried-Chicken/ghost-static-site-generator) to generate the static content
  - Use gsutil to upload your content to a bucket (make sure the bucket exists for your domain)

In order to run it, make sure ghost is running with `docker-compose up` and then in another window do `docker-compose exec app /usr/local/bin/generate_static_content.sh`.

## Hosting it
As I mentioned above, I have a Google Cloud Storage bucket which all the static content goes into.  That's configured as a "website" for "karlstoney.com", I then use Cloudflare free to front this as a CDN.  And voilla, blog hosting for pennies per month.

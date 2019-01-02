# Ghost (0.11.7)
This is a generic ghost blog container, that I use over on my site at [karlstoney.com](https://karlstoney.com).

## Disqus
Included in this is a patch to add disqus comments to your posts.

## State
Your `config.js`, `data` and `images` directories are mounted to `/data` (check the examples below).  So they will persist container updates

## Getting Started
The easiest way is with a compose file, like this:

```
version: '2'

services:
  ghost:
    image: stono/ghost:latest
    restart: always
    environment:
      GHOST_URL: https://karlstoney.com
      DISQUS_ID: karlstoney
    volumes:
      - ./data:/data
    ports:
      - 2368:2368
```

And from there, simply do a `docker-compose up -d

## Free SSL?
Why not check out my other container, [docker-nginx-letsencrypt](https://github.com/Stono/docker-nginx-letsencrypt), which will generate you a free SSL certificate from LetsEncrypt too?

The compose file would look like this:

```
version: '2'
services:
  ghost:
    image: stono/ghost:latest
    restart: always
    environment:
      GHOST_URL: https://karlstoney.com
      DISQUS_ID: karlstoney
    volumes:
      - ./data:/data

  nginx:
    image: stono/docker-nginx-letsencrypt:latest
    restart: always
    environment:
      - HOST_KARLSTONEY=karlstoney.com,ghost:2368,default_server
      - HOST_WWWKARLSTONEY=www.karlstoney.com,karlstoney.com,redirect
      - LETSENCRYPT_EMAIL=your-email@your-domain.com
      - LETSENCRYPT=true
    volumes:
      - ./letsencrypt:/etc/letsencrypt
    ports:
      - 443:443
      - 80:80
```

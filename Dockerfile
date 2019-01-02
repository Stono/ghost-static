FROM centos:7
MAINTAINER Karl Stoney <me@karlstoney.com>

# Get dependencies
RUN yum -y -q install which curl wget gettext patch gcc-c++ make git-core bzip2 unzip && \
    yum -y -q clean all

# Get nodejs repos
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -

# Install nodejs, max currently supported is 6.9.0
RUN yum -y -q install nodejs-8.* && \
    yum -y -q clean all

# Setup www-data user
RUN groupadd www-data && \
    useradd -r -g www-data www-data

RUN mkdir -p /var/www && \
    mkdir -p /home/www-data && \
    chown -R www-data:www-data /var/www && \
    chown -R www-data:www-data /home/www-data

EXPOSE 2368

# Configuration
ENV GHOST_HOME /var/www/ghost

# Install Gcloud utilities
ENV CLOUDSDK_INSTALL_DIR /usr/lib64/google-cloud-sdk
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
COPY gcloud.repo /etc/yum.repos.d/
RUN mkdir -p /etc/gcloud/keys
ARG GCLOUD_VERSION

# Install packages
RUN yum -y -q update && \
    yum -y -q install google-cloud-sdk-$GCLOUD_VERSION && \
    yum -y -q clean all

# Disable google cloud auto update... we should be pushing a new agent container
RUN gcloud config set --installation component_manager/disable_update_check true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set core/disable_usage_reporting true

CMD ["/usr/local/bin/start_ghost.sh"]

# Install Ghost
WORKDIR $GHOST_HOME
RUN npm install -g ghost-cli@latest
RUN chown -R www-data:www-data $GHOST_HOME
ARG GHOST_VERSION
RUN su -c 'ghost install local --no-setup --db sqlite3 --v$GHOST_VERSION' www-data

# Add static content generator
ARG SITEMAP_GENERATOR_VERSION
RUN npm install -g https://github.com/Stono/ghost-static-site-generator
#RUN npm install -g ghost-static-site-generator@$SITEMAP_GENERATOR_VERSION

# Patch ghost
RUN mkdir -p /usr/local/etc/ghost/patches
COPY patches/ /usr/local/etc/ghost/patches/
COPY bin/* /usr/local/bin/

RUN /usr/local/bin/apply_patches.sh
COPY data/config.json /var/www/ghost/current/core/server/config/env/config.production.json

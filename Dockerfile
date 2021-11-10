FROM centos:8
MAINTAINER Karl Stoney <me@karlstoney.com>

# Get dependencies
RUN yum -y -q install which curl wget gettext patch gcc-c++ make git-core bzip2 unzip gcc python3-devel python3-setuptools redhat-rpm-config && \
    yum -y -q clean all

# Install crcmod
RUN easy_install-3 -U pip && \
    pip install -U crcmod

# Get nodejs repos
ARG NODEJS_VERSION
RUN curl --silent --location https://rpm.nodesource.com/setup_$NODEJS_VERSION.x | bash -

RUN yum -y -q install nodejs-$NODEJS_VERSION.* && \
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
ARG GCLOUD_VERSION
ARG ARCH
ENV CLOUDSDK_INSTALL_DIR /usr/lib64/google-cloud-sdk
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN mkdir -p /etc/gcloud/keys
RUN curl -s -f -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-$GCLOUD_VERSION.0.0-linux-${ARCH}.tar.gz && \
    tar xzf google-cloud-sdk-*.tar.gz && \
    mv google-cloud-sdk ${CLOUDSDK_INSTALL_DIR} && \
    rm google-cloud-sdk-*.tar.gz && \
    cd /usr/local/bin && \
    ln -sf /usr/lib64/google-cloud-sdk/bin/gcloud . && \
    ln -sf /usr/lib64/google-cloud-sdk/bin/gsutil .

# Disable google cloud auto update... we should be pushing a new agent container
RUN gcloud config set --installation component_manager/disable_update_check true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set core/disable_usage_reporting true

CMD ["/usr/local/bin/start_ghost.sh"]

# Install Ghost
WORKDIR $GHOST_HOME
ARG GHOST_CLI_VERSION
RUN npm install -g ghost-cli@$GHOST_CLI_VERSION
RUN chown -R www-data:www-data $GHOST_HOME
ARG GHOST_VERSION
RUN su -c 'ghost install local --no-setup --db sqlite3 --v$GHOST_VERSION' www-data

# Alias python
RUN cd /usr/local/bin && \
    ln -sf /usr/bin/python3 python
RUN su -c 'npm install sqlite3 --save' www-data

# Add static content generator
ARG SITEMAP_GENERATOR_VERSION
RUN npm install -g ghost-static-site-generator@$SITEMAP_GENERATOR_VERSION
RUN mkdir /static 

# Patch ghost
RUN mkdir -p /usr/local/etc/ghost/patches
COPY patches/ /usr/local/etc/ghost/patches/
COPY bin/ /usr/local/bin/

RUN /usr/local/bin/apply_patches.sh
COPY data/config.json /var/www/ghost/current/config.production.json

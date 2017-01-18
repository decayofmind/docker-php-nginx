FROM centos:7

# https://getcomposer.org/doc/03-cli.md#composer-no-interaction
ENV COMPOSER_NO_INTERACTION 1
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PATH /root/.composer/vendor/bin:$PATH

# Specify package versions
ENV PHP_VERSION 7.0.14
ENV COMPOSER_VERSION 1.2.4
ENV GULP_VERSION 3.9.1
ENV NGINX_VERSION 1.10.2
ENV NODE_VERSION 7.2.1
ENV S6_VERSION 1.18.1.5

# List of required packages
RUN yum install -y epel-release && \
    yum localinstall -y https://mirror.webtatic.com/yum/el7/webtatic-release.rpm && \
    yum localinstall -y https://rpm.nodesource.com/pub_7.x/el/7/x86_64/nodesource-release-el7-1.noarch.rpm && \
    yum update -y && \
    yum install -y \
        bats \
        git \
        patch \
        file \
        wget \
        nginx-${NGINX_VERSION} \
        nodejs-${NODE_VERSION} \
        php70w-${PHP_VERSION} \
        php70w-fpm \
        php70w-gd \
        php70w-intl \
        php70w-mbstring \
        php70w-mcrypt \
        php70w-opcache \
        php70w-pecl-redis \
        php70w-pecl-xdebug \
        php70w-pgsql \
        php70w-xml && \
    yum clean all

# Install Front-end tools
RUN npm install --silent -g "gulp@~${GULP_VERSION}" && \
    rm -rf /root/.npm && \
    npm cache clear

# Install s6
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / --exclude="./bin" --exclude="./sbin" && \
    tar xzf /tmp/s6-overlay-amd64.tar.gz -C /usr ./bin ./sbin

# Prepare dummy certs
RUN mkdir -p /etc/nginx/ssl && \
    openssl genrsa -out /etc/nginx/ssl/dummy.key 2048 && \
    openssl req -new -key /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.csr -subj "/C=CZ/L=Prague/O=ACME/CN=docker" && \
    openssl x509 -req -days 3650 -in /etc/nginx/ssl/dummy.csr -signkey /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.crt

# Install Composer with tools
RUN sed -i 's:^zend_extension=/usr/lib64/php/modules/xdebug.so$:;zend_extension=/usr/lib64/php/modules/xdebug.so:g' /etc/php.d/xdebug.ini && \
    wget -qO /usr/local/bin/composer https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && chmod +x /usr/local/bin/composer && \
    # Install Composer plugin - it should be removed later (see https://github.com/composer/composer/pull/3951)
    composer global require hirak/prestissimo --quiet --no-progress && \
    # Install PHP tools used in CI
    composer global require 'phpunit/phpunit=~5.6.1' --quiet --no-progress && \
    composer global require 'jakub-onderka/php-parallel-lint=~0.9.2' --quiet --no-progress && \
    composer global require 'jakub-onderka/php-console-highlighter=~0.3.2' --quiet --no-progress && \
    # Cleanup
    composer clear-cache --quiet

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

COPY dockerfs /

ENV ASSETS_CACHE 1
ENV PHP_OPCACHE 1
ENV PHP_XDEBUG 0
ENV TIMEZONE Europe/Prague
ENV VIRTUAL_HOST localhost

EXPOSE 80 443

ENTRYPOINT ["/init"]

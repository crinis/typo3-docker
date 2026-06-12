FROM docker.io/library/php:8.4-apache-bookworm

RUN savedAptMark="$(apt-mark showmanual)" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libtool \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libavif-dev \
        libxml2-dev \
        libicu-dev \
        libyaml-dev \
        libzip-dev \
    && \
    rm -rf /var/lib/apt/lists/* && \
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
    pecl install apcu yaml && \
    docker-php-ext-configure gd \
        --enable-gd \
        --with-freetype \
        --with-jpeg\
        --with-webp \
        --with-avif \
    && \
    docker-php-ext-configure intl --enable-intl && \
    docker-php-ext-install gd mysqli opcache zip intl pdo pdo_mysql exif && \
    docker-php-ext-enable apcu yaml && \
    apt-mark auto '.*' > /dev/null && \
    apt-mark manual $savedAptMark && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        imagemagick \
        ghostscript \
        nano \
        libyaml-0-2 \
        cron \
        unzip \
        wget \
        unzip \
        libzip4 \
        libavif15 \
        jq \
        gosu \
        locales \
    && \
    rm -rf /var/lib/apt/lists/* && \
    # Setup common locales.
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "nl_NL.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "pt_PT.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "sv_SE.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "fi_FI.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "nb_NO.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "da_DK.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

RUN a2enmod rewrite expires headers

COPY php/ /usr/local/etc/php/conf.d/
COPY entrypoint.sh /usr/local/bin/typo3-php-entrypoint

# Adjust Apache configuration. Set document root to /var/www/html/public as this is the default in modern TYPO3 installations
# and allows having non-public files in the /var/www/html directory. Also, change the port to 8080. This will be changed back to 80
# by the entrypoint script if the container is started as root.
RUN sed -i 's/\/var\/www\/html/\/var\/www\/html\/public/g' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf && \
    sed -i 's/80/8080/g' /etc/apache2/sites-enabled/000-default.conf && \
    chmod 0755 /usr/local/bin/typo3-php-entrypoint && \
    chmod 0644 /usr/local/etc/php/conf.d/opcache-recommended.ini /usr/local/etc/php/conf.d/typo3.ini && \
    chmod 2770 /var/www/html

# Install supercronic.
ARG SUPERCRONIC_VERSION=0.2.33
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        SUPERCRONIC_ARCHITECTURE="amd64"; \
        SUPERCRONIC_SHA1SUM="71b0d58cc53f6bd72cf2f293e09e294b79c666d8"; \
    elif [ "$ARCH" = "arm64" ]; then \
        SUPERCRONIC_ARCHITECTURE="arm64"; \
        SUPERCRONIC_SHA1SUM="e0f0c06ebc5627e43b25475711e694450489ab00"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${SUPERCRONIC_ARCHITECTURE}" && \
    curl -fsSLO "${SUPERCRONIC_URL}" && \
    echo "${SUPERCRONIC_SHA1SUM}  supercronic-linux-${SUPERCRONIC_ARCHITECTURE}" | sha1sum -c - && \
    chmod 755 "supercronic-linux-${SUPERCRONIC_ARCHITECTURE}" && \
    mv "supercronic-linux-${SUPERCRONIC_ARCHITECTURE}" /usr/local/bin/supercronic

# Install composer.
ARG COMPOSER_VERSION=2.8.5
RUN COMPOSER_URL="https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar" && \
    curl -fsSLO "${COMPOSER_URL}" && \
    echo "716049bb9bd889e0702e96bdfcb0214082f1bbfd composer.phar" | sha1sum -c - && \
    chmod 755 composer.phar && \
    mv composer.phar /usr/local/bin/composer

ENV SET_OWNER="true"

# Expose port 8080 for non-root usage.
EXPOSE 8080

ENTRYPOINT ["typo3-php-entrypoint"]
CMD ["apache2-foreground"]

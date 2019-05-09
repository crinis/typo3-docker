ARG PHP_IMAGE_TAG=0.1.1-php7.2-apache
FROM crinis/typo3-php:${PHP_IMAGE_TAG}

ARG TYPO3_VERSION=8.7.25
ENV TYPO3_VERSION="${TYPO3_VERSION}"

RUN wget -qO- get.typo3.org/$TYPO3_VERSION | tar xvz -C /usr/src/ && \
    mkdir -p /docker/config

COPY config/htaccess /docker/config/htaccess
COPY config/AdditionalConfiguration.php /docker/config/AdditionalConfiguration.php
COPY config/local-configuration-overrides.yml /docker/config/local-configuration-overrides.yml
COPY OverrideLocalConfiguration.php /docker/OverrideLocalConfiguration.php
COPY docker-typo3-entrypoint.sh /docker/docker-typo3-entrypoint.sh
COPY wait-for-it.sh /docker/wait-for-it.sh

ARG CRONTAB_DIRECTORY="/var/spool/cron/crontabs"
RUN chmod +x /docker/docker-typo3-entrypoint.sh /docker/wait-for-it.sh && \ 
    echo "*/15 * * * * /usr/local/bin/php /var/www/html/typo3/sysext/core/bin/typo3 scheduler:run" > $CRONTAB_DIRECTORY/www-data

ARG TYPO3_CONSOLE_VERSION=5.6.0
ARG START_CMD=apache2-foreground
ENV TYPO3_CONSOLE_VERSION="${TYPO3_CONSOLE_VERSION}" \
    TYPO3_CONTEXT="Production" \
    MODIFY_LOCAL_CONFIGURATION="true" \
    CLEANUP_TYPO_SRC="true"

ENTRYPOINT ["/docker/docker-typo3-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

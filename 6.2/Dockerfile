ARG PHP_IMAGE_TAG=0.1.1-php5.6-apache
FROM crinis/typo3-php:${PHP_IMAGE_TAG}

ARG TYPO3_VERSION=6.2.31
ENV TYPO3_VERSION="${TYPO3_VERSION}"

RUN wget -qO- get.typo3.org/$TYPO3_VERSION | tar xvz -C /usr/src/ && \
    mkdir -p /docker/config

COPY docker-typo3-entrypoint.sh /docker/docker-typo3-entrypoint.sh
COPY config/htaccess /docker/config/htaccess
COPY config/AdditionalConfiguration.php /docker/config/AdditionalConfiguration.php

ARG CRONTAB_DIRECTORY="/var/spool/cron/crontabs"
RUN chmod +x /docker/docker-typo3-entrypoint.sh && \ 
    echo "*/15 * * * * /usr/local/bin/php /var/www/html/typo3/cli_dispatch.phpsh scheduler" > $CRONTAB_DIRECTORY/www-data

ARG START_CMD=apache2-foreground
ENV TYPO3_CONTEXT="Production" \
    CLEANUP_TYPO_SRC="true"

ENTRYPOINT ["/docker/docker-typo3-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

ARG BASE_IMAGE_TAG=5.6-apache
FROM crinis/typo3-php:${BASE_IMAGE_TAG}

ARG TYPO3_VERSION
ENV TYPO3_VERSION=$TYPO3_VERSION

RUN wget -qO- get.typo3.org/$TYPO3_VERSION | tar xvz -C /usr/src/ && \
    mkdir -p /docker/config

COPY config/AdditionalConfiguration.php /docker/config/AdditionalConfiguration.php
COPY docker-typo3-entrypoint.sh /docker/docker-typo3-entrypoint.sh

RUN chmod +x /docker/docker-typo3-entrypoint.sh && \ 
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/typo3/cli_dispatch.phpsh scheduler" > /var/spool/cron/crontabs/www-data && \
    chmod 600 /var/spool/cron/crontabs/www-data

ENV TYPO3_CONTEXT="Production" \
    SETUP_TYPO3_SRC=true \
    SETUP_TYPO3=true \
    MODIFY_LOCAL_CONFIGURATION=true \
    TYPO3_SITE_NAME="TYPO3 CMS"

ENTRYPOINT ["/docker/docker-typo3-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

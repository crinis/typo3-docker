ARG BASE_IMAGE_TAG=7.1-apache
FROM crinis/typo3-php:${BASE_IMAGE_TAG}

ARG TYPO3_VERSION
ARG TYPO3_CONSOLE_VERSION="4.9.6"
ENV TYPO3_VERSION=$TYPO3_VERSION \
    TYPO3_CONSOLE_VERSION=$TYPO3_CONSOLE_VERSION

RUN wget -qO- "get.typo3.org/${TYPO3_VERSION}" | tar xvz -C /usr/src/ && \
    mkdir -p /docker/config

RUN wget "https://extensions.typo3.org/extension/download/typo3_console/${TYPO3_CONSOLE_VERSION}/zip/" -O typo3_console.zip && \
    unzip typo3_console.zip -d /usr/src/typo3_console/ && \
    rm typo3_console.zip && \
    chmod +x /usr/src/typo3_console/Scripts/typo3cms

COPY config/AdditionalConfiguration.php /docker/config/AdditionalConfiguration.php
COPY docker-typo3-entrypoint.sh /docker/docker-typo3-entrypoint.sh
COPY wait-for-it.sh /docker/wait-for-it.sh

RUN chmod +x /docker/docker-typo3-entrypoint.sh /docker/wait-for-it.sh && \ 
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/typo3/cli_dispatch.phpsh scheduler" > /var/spool/cron/crontabs/www-data && \
    chmod 600 /var/spool/cron/crontabs/www-data

ENV TYPO3_CONTEXT="Production" \
    SETUP_TYPO3_SRC=true \
    SETUP_TYPO3=true \
    MODIFY_LOCAL_CONFIGURATION=true \
    TYPO3_SITE_NAME="TYPO3 CMS" \
    TYPO3_SITE_SETUP_TYPE="site"

ENTRYPOINT ["/docker/docker-typo3-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

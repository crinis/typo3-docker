ARG BASE_IMAGE_TAG=8.4-apache
FROM docker.io/crinis/typo3-php:${BASE_IMAGE_TAG}

RUN mkdir /typo3

COPY additional.php /typo3/additional.php
COPY entrypoint.sh /usr/local/bin/typo3-entrypoint
COPY wait-for-it.sh /usr/local/bin/wait-for-it

RUN chmod 0755 /usr/local/bin/typo3-entrypoint /usr/local/bin/wait-for-it && \ 
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/vendor/bin/typo3 scheduler:run" > /var/spool/cron/crontabs/www-data && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/vendor/bin/typo3 scheduler:run" > /typo3/crontab && \
    chmod 0664 /typo3/crontab /typo3/additional.php

ENV TYPO3_CONTEXT="Production" \
    MODIFY_CONFIGURATION="true" \
    SETUP_TYPO3="true" \
    SETUP_EXTENSIONS="false" \
    TYPO3_PROJECT_NAME="New TYPO3 Project" \
    TYPO3_SETUP_CREATE_SITE="" \
    TYPO3_DB_DRIVER="mysqli" \
    TYPO3_CONSOLE_VERSION="8.2.2" \
    COMPOSER_UPDATE="false" \
    COMPOSER_NO_DEV="true" \
    FIX_FILE_PERMISSIONS="true"

ENTRYPOINT ["typo3-entrypoint"]
CMD ["apache2-foreground"]

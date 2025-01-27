ARG PHP_IMAGE_TAG=8.4-apache
FROM docker.io/crinis/typo3-php:${PHP_IMAGE_TAG}

RUN mkdir /typo3

ARG TYPO3_VERSION
ARG TYPO3_SHA1
ENV TYPO3_VERSION="${TYPO3_VERSION}" \
    TYPO3_SHA1="${TYPO3_SHA1}"

# Download and extract TYPO3.
RUN curl -fsSL "https://get.typo3.org/${TYPO3_VERSION}" -o "typo3_src-${TYPO3_VERSION}.tar.gz" && \
    echo "${TYPO3_SHA1} typo3_src-${TYPO3_VERSION}.tar.gz" | sha1sum -c - && \
    tar -xzf "typo3_src-${TYPO3_VERSION}.tar.gz" -C /typo3 && \
    rm "typo3_src-${TYPO3_VERSION}.tar.gz"

# Download and extract TYPO3 Console.
ENV TYPO3_CONSOLE_VERSION="8.2.2"
RUN curl -fsSL "https://extensions.typo3.org/extension/download/typo3_console/${TYPO3_CONSOLE_VERSION}/zip/" -o "typo3_console_${TYPO3_CONSOLE_VERSION}.zip" && \
    echo "bc85b9eb7f8dbb4d48aab3d2b2360db5f7dee71f typo3_console_${TYPO3_CONSOLE_VERSION}.zip" | sha1sum -c - && \
    unzip "typo3_console_${TYPO3_CONSOLE_VERSION}.zip" -d /typo3/typo3_console && \
    rm "typo3_console_${TYPO3_CONSOLE_VERSION}.zip" && \
    # We have to set it to unprotected so we can cleanup properly after use.
    sed -i '/"protected": true,/d' /typo3/typo3_console/composer.json

COPY additional.php /typo3/additional.php
COPY entrypoint.sh /usr/local/bin/typo3-entrypoint
COPY wait-for-it.sh /usr/local/bin/wait-for-it

# Setup default cronjob for TYPO3 scheduler and set permissions for files inside /typo3.
RUN chmod 0755 /usr/local/bin/typo3-entrypoint /usr/local/bin/wait-for-it && \ 
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/public/typo3/sysext/core/bin/typo3 scheduler:run" > /var/spool/cron/crontabs/www-data && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/public/typo3/sysext/core/bin/typo3 scheduler:run" > /typo3/crontab && \
    chmod 0664 /typo3/crontab /typo3/additional.php

ENV TYPO3_CONTEXT="Production" \
    MODIFY_CONFIGURATION="true" \
    MANAGE_SRC="true" \
    SETUP_TYPO3="true" \
    SETUP_EXTENSIONS="false" \
    TYPO3_PROJECT_NAME="New TYPO3 Project" \
    TYPO3_SETUP_CREATE_SITE="" \
    TYPO3_DB_DRIVER="mysqli" \
    FIX_FILE_PERMISSIONS="true"

ENTRYPOINT ["typo3-entrypoint"]
CMD ["apache2-foreground"]

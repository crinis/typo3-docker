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

COPY additional.php /typo3/additional.php
COPY entrypoint.sh /usr/local/bin/typo3-entrypoint
COPY wait-for-it.sh /usr/local/bin/wait-for-it

# Setup default cronjob for TYPO3 scheduler and set permissions for files inside /typo3.
RUN chmod 0755 /usr/local/bin/typo3-entrypoint /usr/local/bin/wait-for-it && \
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/public/typo3/sysext/core/bin/typo3 scheduler:run" > /var/spool/cron/crontabs/www-data && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \
    echo "*/5 * * * * /usr/local/bin/php /var/www/html/public/typo3/sysext/core/bin/typo3 scheduler:run" > /typo3/crontab && \
    chmod 0644 /typo3/crontab /typo3/additional.php && \
    # Allow running with an arbitrary user ID that is a member of the root group,
    # e.g. on OpenShift, where /var/www/html may not be a mounted volume.
    chgrp 0 /var/www/html && \
    chmod g+rwxs /var/www/html

ENV TYPO3_CONTEXT="Production" \
    MODIFY_CONFIGURATION="true" \
    MANAGE_SRC="true" \
    SETUP_TYPO3="true" \
    SETUP_EXTENSIONS="false" \
    TYPO3_PROJECT_NAME="New TYPO3 Project" \
    TYPO3_SETUP_CREATE_SITE="" \
    TYPO3_DB_DRIVER="pdoMysql" \
    FIX_FILE_PERMISSIONS="true"

ENTRYPOINT ["typo3-entrypoint"]
CMD ["apache2-foreground"]

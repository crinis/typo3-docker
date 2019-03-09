#!/usr/bin/env bash
#
# Performs certain startup tasks including installing TYPO3 source, setting up the TYPO3 database, copying important files, changing LocalConfiguration.php settings

set -euo pipefail

if [ ! -d /var/www/html ]; then
    mkdir -p /var/www/html
fi

if [ ! -f /var/www/html/.htaccess ]; then
    cp /docker/config/htaccess /var/www/html/.htaccess
fi

if [ ! -d /var/www/html/typo3conf ]; then
    mkdir /var/www/html/typo3conf
fi

if [ ! -d /var/www/html/typo3_src-$TYPO3_VERSION ] && [ ! -d /usr/src/typo3_src-$TYPO3_VERSION ]; then
    wget -qO- get.typo3.org/$TYPO3_VERSION | tar xvz -C /var/www/html
fi

if [ -d /var/www/html/typo3_src-$TYPO3_VERSION ] && [ "$(readlink /var/www/html/typo3_src)" != "typo3_src-${TYPO3_VERSION}" ]; then 
    ln -sfn typo3_src-$TYPO3_VERSION /var/www/html/typo3_src
elif [ -d /usr/src/typo3_src-$TYPO3_VERSION ] && [ "$(readlink /var/www/html/typo3_src)" != "/usr/src/typo3_src-${TYPO3_VERSION}" ]; then
    ln -sfn /usr/src/typo3_src-$TYPO3_VERSION /var/www/html/typo3_src
fi

if [ ! -f /var/www/html/index.php ]; then
    ln -s typo3_src/index.php /var/www/html/index.php
fi

if [ ! -d /var/www/html/typo3 ]; then
    ln -s typo3_src/typo3 /var/www/html/typo3
fi

if [ "$CLEANUP_TYPO_SRC" == "true" ]; then
    find /var/www/html -maxdepth 1 -name "typo3_src-*" -not -name "typo3_src-${TYPO3_VERSION}" -prune -exec rm -rf {} \;
fi

if [ ! -f /var/www/html/typo3conf/AdditionalConfiguration.php ]; then
    cp /docker/config/AdditionalConfiguration.php /var/www/html/typo3conf/AdditionalConfiguration.php
fi

chown -R www-data:www-data /var/www/html

exec "$@"

#!/usr/bin/env bash
#
# Performs certain startup tasks including installing TYPO3 source, setting up the TYPO3 database, copying important files, changing LocalConfiguration.php settings

set -euo pipefail

if [ ! -d /var/www/html/ ]; then
    mkdir -p /var/www/html/
fi

if [ $SETUP_TYPO3_SRC == true ] && [ -d "/usr/src/typo3_src-${TYPO3_VERSION}/" ] && [ "$(readlink /var/www/html/typo3_src)" != "/usr/src/typo3_src-${TYPO3_VERSION}" ]; then

    ln -sfn "/usr/src/typo3_src-${TYPO3_VERSION}/" /var/www/html/typo3_src

    if [ ! -f /var/www/html/index.php ]; then
        ln -s typo3_src/index.php /var/www/html/index.php
    fi

    if [ ! -d /var/www/html/typo3 ]; then
        ln -s typo3_src/typo3/ /var/www/html/typo3
    fi
fi

if [ $SETUP_TYPO3 == true ] && [ ! -f /var/www/html/typo3conf/LocalConfiguration.php ]; then

    if [ ! -f /var/www/html/.htaccess ]; then
        cp /var/www/html/typo3_src/_.htaccess /var/www/html/.htaccess
    fi

    if [ ! -d /var/www/html/typo3conf/ ]; then
        mkdir -p /var/www/html/typo3conf/
    fi

    touch /var/www/html/typo3conf/ENABLE_INSTALL_TOOL

    if [ ! -f /var/www/html/typo3conf/AdditionalConfiguration.php ]; then
        cp /docker/config/AdditionalConfiguration.php /var/www/html/typo3conf/AdditionalConfiguration.php
    fi
fi

chown -R www-data:www-data /var/www/html/

exec "$@"

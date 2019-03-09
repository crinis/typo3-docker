#!/usr/bin/env bash
#
# Performs certain startup tasks including installing TYPO3 source, setting up the TYPO3 database, copying important files, changing LocalConfiguration.php settings

set -euo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env "XYZ_DB_PASSWORD" "example"
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker"s secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [ ! -d /var/www/html ]; then
    mkdir -p /var/www/html
fi

if [ ! -f /var/www/html/.htaccess ]; then
    cp /docker/config/htaccess /var/www/html/.htaccess
fi

if [ ! -d /var/www/html/typo3conf ]; then
    mkdir /var/www/html/typo3conf
fi

if [ ! -d /var/www/html/typo3conf/ext/typo3_console ] && [ ! -f /var/www/html/typo3cms ]; then

    mkdir -p /var/www/html/typo3conf/ext/typo3_console
    wget https://extensions.typo3.org/extension/download/typo3_console/$TYPO3_CONSOLE_VERSION/zip/ -O typo3_console.zip
    unzip typo3_console.zip -d /var/www/html/typo3conf/ext/typo3_console/
    rm typo3_console.zip
fi

if [ ! -f /var/www/html/typo3cms ]; then

    chmod +x /var/www/html/typo3conf/ext/typo3_console/typo3cms
    ln -s /var/www/html/typo3conf/ext/typo3_console/typo3cms /var/www/html/typo3cms
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

file_env "TYPO3_DB_HOST"
file_env "TYPO3_DB_PORT" "3306"

if [ -z "$TYPO3_DB_HOST" ]; then
    echo >&2 "error: there is no database host specified "
    echo >&2 "  You need to specify TYPO3_DB_HOST for the setup process to connect to the database"
    exit 1
fi

file_env "TYPO3_DB_NAME"

if [ -z "$TYPO3_DB_NAME" ]; then
    echo >&2 "error: there is no name of an existing database specified "
    echo >&2 "  You need to specify TYPO3_DB_NAME"
    exit 1
fi

file_env "TYPO3_SITE_NAME" "TYPO3 CMS"

if [ ! -f /var/www/html/typo3conf/LocalConfiguration.php ]; then

    /docker/wait-for-it.sh "${TYPO3_DB_HOST}:${TYPO3_DB_PORT}" -- echo "Database is ready"

    file_env "TYPO3_ADMIN_USERNAME" "admin"
    file_env "TYPO3_ADMIN_PASSWORD"

    if [ -z "$TYPO3_ADMIN_PASSWORD" ]; then
        echo >&2 "error: there is no admin password specified "
        echo >&2 "  You need to specify TYPO3_ADMIN_PASSWORD for the setup process to work"
        exit 1
    fi

    eval "/var/www/html/typo3cms install:setup --no-interaction \
        --database-user-name='${TYPO3_DB_USERNAME}' \
        --database-user-password='${TYPO3_DB_PASSWORD}' \
        --database-host-name='${TYPO3_DB_HOST}' \
        --database-port='${TYPO3_DB_PORT}' \
        --database-name='${TYPO3_DB_NAME}' \
        --admin-user-name='${TYPO3_ADMIN_USERNAME}' \
        --admin-password='${TYPO3_ADMIN_PASSWORD}' \
        --site-name='${TYPO3_SITE_NAME}' \
        --use-existing-database \
        --site-setup-type='site'"
fi

if [ "$MODIFY_LOCAL_CONFIGURATION" == "true" ] && [ -f /var/www/html/typo3conf/LocalConfiguration.php ] ; then

    if [ ! -z ${TYPO3_DB_HOST+x} ]; then
         
        eval "/var/www/html/typo3cms configuration:set DB/Connections/Default/host '${TYPO3_DB_HOST}'"
    fi

    if [ ! -z ${TYPO3_DB_PORT+x} ]; then
        
        eval "/var/www/html/typo3cms configuration:set DB/Connections/Default/port '${TYPO3_DB_PORT}'"
    fi

    if [ ! -z ${TYPO3_DB_NAME+x} ]; then

        eval "/var/www/html/typo3cms configuration:set DB/Connections/Default/dbname '${TYPO3_DB_NAME}'"
    fi

    if [ ! -z ${TYPO3_DB_USERNAME+x} ]; then
        
        eval "/var/www/html/typo3cms configuration:set DB/Connections/Default/user '${TYPO3_DB_USERNAME}'"
    fi

    if [ ! -z ${TYPO3_DB_PASSWORD+x} ]; then
        
        eval "/var/www/html/typo3cms configuration:set DB/Connections/Default/password '${TYPO3_DB_PASSWORD}'"
    fi

    php -f /docker/OverrideLocalConfiguration.php
fi

if [ ! -f /var/www/html/typo3conf/AdditionalConfiguration.php ]; then
    cp /docker/config/AdditionalConfiguration.php /var/www/html/typo3conf/AdditionalConfiguration.php
fi

chown -R www-data:www-data /var/www/html

secretEnvs=(
    TYPO3_DB_HOST
    TYPO3_DB_PORT
    TYPO3_DB_NAME
    TYPO3_DB_USERNAME
    TYPO3_DB_PASSWORD
    TYPO3_ADMIN_USERNAME
    TYPO3_ADMIN_PASSWORD
)

for e in "${secretEnvs[@]}"; do
    unset "$e"
done

exec "$@"

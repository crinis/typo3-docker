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

if [ ! -d /var/www/html/ ]; then
    mkdir -p /var/www/html/
fi

if [ ! -d /var/www/html/typo3conf/ext ]; then
    mkdir -p /var/www/html/typo3conf/ext/
fi

if [ ! -d /var/www/html/typo3conf/ext/typo3_console ] && [ ! -f /var/www/html/typo3cms ]; then
    cp -r /usr/src/typo3_console/ /var/www/html/typo3conf/ext/typo3_console/
    ln -s /var/www/html/typo3conf/ext/typo3_console/typo3cms /var/www/html/typo3cms

    export REMOVE_TYPO3_CONSOLE=true
fi

if [ $SETUP_TYPO3_SRC == true ] && [ -d "/usr/src/typo3_src-${TYPO3_VERSION}/" ] && [ "$(readlink /var/www/html/typo3_src)" != "/usr/src/typo3_src-${TYPO3_VERSION}/" ]; then

    ln -sfn "/usr/src/typo3_src-${TYPO3_VERSION}/" /var/www/html/typo3_src

    if [ ! -f /var/www/html/index.php ]; then
        ln -s typo3_src/index.php /var/www/html/index.php
    fi

    if [ ! -d /var/www/html/typo3 ]; then
        ln -s typo3_src/typo3/ /var/www/html/typo3
    fi

    export FLUSH_CACHES=true
fi

file_env "TYPO3_DB_HOST"
file_env "TYPO3_DB_PORT" 3306
file_env "TYPO3_DB_NAME"
file_env "TYPO3_ADMIN_USERNAME" "admin"
file_env "TYPO3_ADMIN_PASSWORD"

if [ $SETUP_TYPO3 == true ] && [ ! -f /var/www/html/typo3conf/LocalConfiguration.php ]; then

    if [ -z ${TYPO3_DB_HOST+x} ]; then
        echo >&2 "error: there is no database host specified "
        echo >&2 "  You need to specify TYPO3_DB_HOST for the setup process to connect to the database"
        exit 1
    fi

    if [ -z ${TYPO3_DB_NAME+x} ]; then
        echo >&2 "error: there is no name of an existing database specified "
        echo >&2 "  You need to specify TYPO3_DB_NAME"
        exit 1
    fi

    if [ -z ${TYPO3_ADMIN_PASSWORD+x} ]; then
        echo >&2 "error: there is no admin password specified "
        echo >&2 "  You need to specify TYPO3_ADMIN_PASSWORD for the setup process to work"
        exit 1
    fi

    /docker/wait-for-it.sh "${TYPO3_DB_HOST}:${TYPO3_DB_PORT}" -t 120 -- echo "Database is ready"

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
        --site-setup-type='${TYPO3_SITE_SETUP_TYPE}' \
        --web-server-config='apache'"

    if [ ! -f /var/www/html/typo3conf/AdditionalConfiguration.php ]; then
        cp /docker/config/AdditionalConfiguration.php /var/www/html/typo3conf/AdditionalConfiguration.php
    fi
fi

if [ $MODIFY_LOCAL_CONFIGURATION == true ] && [ -f /var/www/html/typo3conf/LocalConfiguration.php ] ; then

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

    if [ ! -z ${TYPO3_SITE_NAME+x} ]; then
        eval "/var/www/html/typo3cms configuration:set SYS/sitename '${TYPO3_SITE_NAME}'"
    fi
fi

chown -R www-data:www-data /var/www/html/

if [ ! -z ${FLUSH_CACHES+x} ] && [ $FLUSH_CACHES == true ] && [ ! -z ${TYPO3_DB_HOST+x} ] && [ ! -z ${TYPO3_DB_PORT+x} ] ; then
    /docker/wait-for-it.sh "${TYPO3_DB_HOST}:${TYPO3_DB_PORT}" -t 120 -- echo "Database is ready"
    /var/www/html/typo3cms cache:flush || true
fi

if [ ! -z ${REMOVE_TYPO3_CONSOLE+x} ] && [ $REMOVE_TYPO3_CONSOLE == true ] ; then
    rm /var/www/html/typo3cms
    rm -r /var/www/html/typo3conf/ext/typo3_console/
fi

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

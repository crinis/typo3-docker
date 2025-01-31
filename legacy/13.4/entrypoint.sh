#!/bin/bash
#
# Performs various tasks during startup of the container.

set -euo pipefail

# Function to run commands as www-data if running as root.
#
# usage: run_as_www_data "command"
run_as_www_data() {
    if [ "$(id -u)" -eq 0 ]; then
        gosu www-data "${@}"
    else
        "${@}"
    fi
}

# Function to check if an extension is installed.
#
# usage: is_extension_installed "extension-key"
#    ie: is_extension_installed "typo3_console"
is_extension_installed() {
    run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 extension:list | grep -q "${1}"
}

# Function to set environment variables from files.
#
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

# Change owner of /var/www/html to www-data:www-data if running as root.
# This can be necessary when the volume is mounted from a host directory.
# If a user mounts multiple volumes inside /var/www/html he will have to take care of the permissions himself.
if [ "$(id -u)" -eq 0 ] && [ "$(stat -c %U /var/www/html)" == "root" ]; then
    echo "Changing owner of /var/www/html to www-data:www-data."
    chown www-data:www-data /var/www/html
fi

# Create public directory if it does not exist.
if [ ! -d /var/www/html/public ]; then
    run_as_www_data mkdir /var/www/html/public
fi

# Setup TYPO3 symlinks if $MANAGE_SRC is set to true.
if [ "${MANAGE_SRC}" == "true" ]; then
        if [ "$(readlink /var/www/html/public/typo3_src)" != "/typo3/typo3_src-${TYPO3_VERSION}" ]; then
            echo "Linking /var/www/html/public/typo3_src to updated sources at /typo3/typo3_src-${TYPO3_VERSION}."
            run_as_www_data ln -sfn "/typo3/typo3_src-${TYPO3_VERSION}" /var/www/html/public/typo3_src
        fi

        if [ ! -f /var/www/html/public/index.php ]; then
            run_as_www_data ln -s typo3_src/index.php /var/www/html/public/index.php
        fi

        if [ ! -d /var/www/html/public/typo3 ]; then
            run_as_www_data ln -s typo3_src/typo3/ /var/www/html/public/typo3
        fi

        FLUSH_CACHES="true"

    else
        echo "Skipping setting up TYPO3 symlinks as MANAGE_SRC is not set to \"true\"."
fi

# Secret environment variables that can be set via files.
file_env "TYPO3_DB_HOST"
file_env "TYPO3_DB_PORT" 3306
file_env "TYPO3_DBNAME"
file_env "TYPO3_DB_USERNAME"
file_env "TYPO3_DB_PASSWORD" ""
file_env "TYPO3_SETUP_ADMIN_EMAIL"
file_env "TYPO3_SETUP_ADMIN_USERNAME"
file_env "TYPO3_SETUP_ADMIN_PASSWORD"

# Setup TYPO3 via CLI if $SETUP_TYPO3 is set to true and settings.php does not exist.
if [ "${SETUP_TYPO3}" == "true" ]; then
    if [ -f /var/www/html/public/typo3conf/system/settings.php ]; then
        echo "Skipping TYPO3 setup as settings.php already exists."
    else
        required_vars=(
            TYPO3_DB_HOST
            TYPO3_DB_PORT
            TYPO3_DB_USERNAME
            TYPO3_DBNAME
            TYPO3_SETUP_ADMIN_EMAIL
            TYPO3_SETUP_ADMIN_USERNAME
            TYPO3_SETUP_ADMIN_PASSWORD
            TYPO3_DB_DRIVER
            TYPO3_PROJECT_NAME
        )

        for var in "${required_vars[@]}"; do
            if [ -z "${!var}" ]; then
                echo >&2 "error: $var is not specified"
                echo >&2 "  You need to specify $var for the setup process to work"
                exit 1
            fi
        done

        run_as_www_data wait-for-it "${TYPO3_DB_HOST}:${TYPO3_DB_PORT}" -t 120 -- echo "Database is ready" || {
            echo "Database is not ready after waiting for 120 seconds."
            exit 1
        }

        echo "Setting up TYPO3..."

        eval "run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 setup \
            --driver='${TYPO3_DB_DRIVER}' \
            --host='${TYPO3_DB_HOST}' \
            --port='${TYPO3_DB_PORT}' \
            --username='${TYPO3_DB_USERNAME}' \
            --password='${TYPO3_DB_PASSWORD}' \
            --dbname='${TYPO3_DBNAME}' \
            --admin-email='${TYPO3_SETUP_ADMIN_EMAIL}' \
            --admin-username='${TYPO3_SETUP_ADMIN_USERNAME}' \
            --admin-user-password='${TYPO3_SETUP_ADMIN_PASSWORD}' \
            --project-name='${TYPO3_PROJECT_NAME}' \
            --create-site='${TYPO3_SETUP_CREATE_SITE}' \
            --server-type='apache'"

        if [ ! -f /var/www/html/public/typo3conf/system/additional.php ]; then
            echo "Copying additional.php to /var/www/html/public/typo3conf/system."
            run_as_www_data cp /typo3/additional.php /var/www/html/public/typo3conf/system/additional.php
        fi

        if ! is_extension_installed scheduler; then
            echo "Activating scheduler extension."
            run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 extension:activate scheduler
        fi
    fi
fi

# Modify TYPO3 configuration with values of some environment variables if $MODIFY_CONFIGURATION is set to true and settings.php exists.
if [ "${MODIFY_CONFIGURATION}" == "true" ] && [ -f /var/www/html/public/typo3conf/system/settings.php ] ; then

    if ! is_extension_installed "typo3_console" ; then
        if [ ! -d /var/www/html/public/typo3conf/ext/typo3_console ]; then
            echo "Copying shipped typo3_console extension."
            run_as_www_data cp -r /typo3/typo3_console /var/www/html/public/typo3conf/ext/typo3_console
            REMOVE_TYPO3_CONSOLE="true"
        fi

        run_as_www_data wait-for-it "${TYPO3_DB_HOST}:${TYPO3_DB_PORT}" -t 120 -- echo "Database is ready" || {
            echo "Database is not ready after waiting for 120 seconds."
            exit 1
        }

        echo "Activating typo3_console extension."
        run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 extension:activate typo3_console
        DEACTIVATE_TYPO3_CONSOLE="true"
    fi

    declare -A configMap=(
        ["SYS/fileCreateMask"]="0660"
        ["SYS/folderCreateMask"]="2770"
        ["DB/Connections/Default/host"]="${TYPO3_DB_HOST}"
        ["DB/Connections/Default/port"]="${TYPO3_DB_PORT}"
        ["DB/Connections/Default/dbname"]="${TYPO3_DBNAME}"
        ["DB/Connections/Default/user"]="${TYPO3_DB_USERNAME}"
        ["DB/Connections/Default/password"]="${TYPO3_DB_PASSWORD}"
    )

    for key in "${!configMap[@]}"; do
        if [ -n "${configMap[$key]}" ]; then
            echo "Setting configuration key $key."
            eval "run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 configuration:set $key '${configMap[$key]}'"
        fi
    done

    if [ "${DEACTIVATE_TYPO3_CONSOLE:-false}" == "true" ]; then
        echo "Deactivating typo3_console extension."
        run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 extension:deactivate typo3_console
    fi

    if [ "${REMOVE_TYPO3_CONSOLE:-false}" == "true" ] ; then
        echo "Removing typo3_console extension."
        rm -rf /var/www/html/public/typo3conf/ext/typo3_console
    fi
fi

if [ "${FLUSH_CACHES:-false}" == "true" ] || [ "${SETUP_EXTENSIONS}" == "true" ]; then
    if [ -n "${TYPO3_DB_HOST}" ] && [ -n "${TYPO3_DB_PORT}" ]; then
        run_as_www_data wait-for-it "${TYPO3_DB_HOST}:${TYPO3_DB_PORT}" -t 120 -- echo "Database is ready" || {
            echo "Database is not ready after waiting for 120 seconds."
        }

        if [ "${FLUSH_CACHES:-false}" == "true" ]; then
            echo "Flushing caches."
            run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 cache:flush || {
                echo "Failed to flush caches. Continue..."
            }
        fi

        if [ "${SETUP_EXTENSIONS}" == "true" ]; then
            echo "Setting up extensions."
            run_as_www_data /var/www/html/public/typo3/sysext/core/bin/typo3 extension:setup || {
                echo "Failed to set up extensions. Continue..."
            }
        fi
    else
        echo "TYPO3_DB_HOST and TYPO3_DB_PORT must be set to flush caches or set up extensions."
    fi
fi

if [ "${FIX_FILE_PERMISSIONS}" == "true" ]; then
    echo "Fixing file permissions."
    find /var/www/html -type d -exec chmod 2770 {} \;
    find /var/www/html -type f -exec chmod 0660 {} \;
fi

# Unset secret environment variables.
secretEnvs=(
    TYPO3_DB_HOST
    TYPO3_DB_PORT
    TYPO3_DBNAME
    TYPO3_DB_USERNAME
    TYPO3_DB_PASSWORD
    TYPO3_SETUP_ADMIN_EMAIL
    TYPO3_SETUP_ADMIN_USERNAME
    TYPO3_SETUP_ADMIN_PASSWORD
)

for e in "${secretEnvs[@]}"; do
    unset "$e"
done

exec /usr/local/bin/typo3-php-entrypoint "${@}"

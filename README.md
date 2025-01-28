# TYPO3 Container Images

[Container Images](https://hub.docker.com/r/crinis/typo3) for recent TYPO3 LTS versions

## Project state

The Container images in this project are not yet production ready. For stability reasons I recommend forking and building the images yourself or [pulling the image by digest](https://docs.docker.com/reference/cli/docker/image/pull/#pull-an-image-from-docker-hub).

## Image types

There are two different types of images in this repository. The default ones are used to manage [Composer](https://getcomposer.org/) based TYPO3 projects. 

The ones under the [legacy](legacy) directory are used for non-composer based projects.

I recommend using Composer for new TYPO3 projects. All images are available on [Docker Hub](https://hub.docker.com/r/crinis/typo3) and are build for AMD64 and ARM64 architectures.

## Rootless support

The images are designed so that they can be run as any non-root user. In that case port "8080" is used. If you run them as root Apache will switch to the "www-data" user and accept connections on port "80". 

For instructions on how to run the TYPO3 scheduler rootless see the [Cronjobs](#cronjobs) section or [podman-compose.yaml](podman-compose.yaml) file.

## Prerequisities

In order to run this container you'll need [Docker](https://docs.docker.com/get-started/), [Podman](https://podman.io/getting-started/installation) or a similar container runtime.

## Quickstart

There is a [docker-compose.yaml](docker-compose.yaml) file for a rootful setup and a [podman-compose.yaml](podman-compose.yaml) file for a rootless setup in each version directory.

Create a directory for your project and navigate into it. Move the "docker-compose.yaml" or "podman-compose.yaml" file into the directory and run:

```bash
docker-compose up -f docker-compose.yaml
```

or

```bash
podman-compose --in-pod false -f podman-compose.yaml up
```

## Usage of Composer based images

These images make assumptions about the structure of your project that is based on the one created by running `composer create-project typo3/cms-base-distribution`. If you have a different structure you might have to adjust the image or your project.

If there is no "composer.json" file in the root of your project it will create a new project with the TYPO3 base distribution. Public files are served from the "/var/www/html/public/" directory.

## Usage of legacy images

These images are based on the official TYPO3 Docker images. They are not recommended for new projects. If you have an existing project that is not based on Composer you can use these images. Public files are served from the "/var/www/html/public/" directory.

## Environment Variables

- `TYPO3_CONTEXT` - Defines the TYPO3 context, can be "Production" or "Development". Defaults to "Production".
- `TYPO3_PROJECT_NAME` - The name of the TYPO3 project. Defaults to "New TYPO3 Project".
- `TYPO3_DB_DRIVER` - The database driver to use, typically "mysqli". Defaults to "mysqli".
- `TYPO3_DB_HOST` - (**Required**) The hostname of the TYPO3 database.
- `TYPO3_DB_PORT` - The port number of the TYPO3 database. Defaults to 3306.
- `TYPO3_DBNAME` - (**Required**) The name of the TYPO3 database.
- `TYPO3_DB_USERNAME` - (**Required**) The username for the TYPO3 database.
- `TYPO3_DB_PASSWORD` - (**Required**) The password for the TYPO3 database.
- `TYPO3_SETUP_ADMIN_EMAIL` - (**Required**) The email address of the TYPO3 admin user.
- `TYPO3_SETUP_ADMIN_USERNAME` - (**Required**) The username of the TYPO3 admin user.
- `TYPO3_SETUP_ADMIN_PASSWORD` - (**Required**) The password of the TYPO3 admin user.
- `TYPO3_SETUP_CREATE_SITE` - Option to create a site during setup.
- `COMPOSER_UPDATE` - If set to "true", it runs `composer update` and updates your Composer dependencies. Only used in Composer based images. Defaults to "false".
- `COMPOSER_NO_DEV` - If set to "true", skips installing development dependencies. Only used in "composer" images. Defaults to "false".
- `MODIFY_CONFIGURATION` - If set to "true", modifies TYPO3 configuration based on environment variables. Defaults to "true".
- `SETUP_TYPO3` - If set to "true", sets up TYPO3 via CLI if settings.php does not exist. Defaults to "true".
- `SETUP_EXTENSIONS` - If set to "true", sets up TYPO3 extensions. This applies e.g. database schema changes and data imports. Defaults to "false".
- `FIX_FILE_PERMISSIONS` - If set to "true", sets file and directory permissions to sensible values. Defaults to "true".
- `SET_OWNER` - If set to "true" and the container is run as "root" recursively sets owner of files in "/var/www/html/" to "www-data". Defaults to "true".
- `MANAGE_SRC` - If set to "true", the container sets up symbolic links for the TYPO3 source files shipped with the image. TYPO3 sources are only shipped with "legacy" images. Defaults to "true".

## Secrets

Secrets can be mounted into the container as files and referenced by environment variables. If set they override the approriate environment variables above.

```
docker run -e TYPO3_SETUP_ADMIN_PASSWORD_FILE=/run/secrets/typo3-admin-password ... -d crinis/typo3:tag
```

- `TYPO3_DB_HOST_FILE` - The hostname of the TYPO3 database.
- `TYPO3_DB_PORT_FILE` - The port number of the TYPO3 database.
- `TYPO3_DBNAME_FILE` - The name of the TYPO3 database.
- `TYPO3_DB_USERNAME_FILE` - The username for the TYPO3 database.
- `TYPO3_DB_PASSWORD_FILE` - The password for the TYPO3 database.
- `TYPO3_SETUP_ADMIN_EMAIL_FILE` - The email address of the TYPO3 admin user.
- `TYPO3_SETUP_ADMIN_USERNAME_FILE` - The username of the TYPO3 admin user.
- `TYPO3_SETUP_ADMIN_PASSWORD_FILE` - The password of the TYPO3 admin user.

## Volumes

- "/var/www/html/" - Contains the TYPO3 installation

For legacy images it is sufficient to mount the "/var/www/html/public/" directory.

If you prefer you can also mount subdirectories as own volumes. This might make sense if you want to use a different storage backend for some files.

## Image Tags

Tags can be specified in various formats. I recommend being as specific as possible to avoid unexpected updates.

To be absolutely certain use the digest of the image or build the image yourself. Make sure to set the latest patch version number of the TYPO3 version you want to use.

Example: `docker pull crinis/typo3:13.4-php8.4-apache`.

### TYPO3 12

- `12-php8.4-apache`
- `12.4-php8.4-apache`
- `12`
- `12.4`
- `legacy-12-php8.4-apache`
- `legacy-12.4-php8.4-apache`
- `legacy-12.4.26-php8.4-apache`
- `legacy-12`
- `legacy-12.4`
- `legacy-12.4.26` - Use current patch version

### TYPO3 13

- `13-php8.4-apache`
- `13.4-php8.4-apache`
- `13`
- `13.4`
- `latest`
- `legacy-13-php8.4-apache`
- `legacy-13.4-php8.4-apache`
- `legacy-13.4.4-php8.4-apache`
- `legacy-13`
- `legacy-13.4`
- `legacy-13.4.4` - Use current patch version
- `legacy-latest`

## Cronjobs

For seperation of concerns a second container with the same image can be used to run cronjobs.

On rootful setups a default "/var/spool/cron/crontabs/www-data" file with the TYPO3 scheduler cronjob is created and runs every five minues. You just need to set the entrypoint to `/usr/sbin/cron -f` as shown in the [docker-compose.yaml](docker-compose.yaml) file.

On rootless setups we can't use the native cron daemon. Instead [Supercronic](https://github.com/aptible/supercronic) is used. A default "crontab" file is created in "/typo3/crontab" and runs every five minutes. You just need to set the entrypoint to `/usr/local/bin/supercronic /typo3/crontab` as shown in the [podman-compose.yaml](podman-compose.yaml) file.

## Authors

- [Crinis](https://github.com/crinis)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details. The image contains software that use different licenses.

## Acknowledgments

- This image installs and uses [TYPO3 Console](https://github.com/TYPO3-Console/TYPO3-Console) for simple setup and configuration.

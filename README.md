# TYPO3 Docker Images

[Docker Images](https://hub.docker.com/r/crinis/typo3) for most TYPO3 LTS versions

## Project state

The Docker images in this project are not yet production ready and might be modified without backwards compatibility at any time. Make sure to set your deployment image to use specific version tags.

## Getting Started

These instructions will cover usage information for the docker container 

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Quickstart

If you use [Docker Compose](https://docs.docker.com/compose/) there is an example [docker-compose.yml](9.5/docker-compose.yml) file in each version specific directory of the repository.

Create a Docker network
```shell
docker network create typo3-db
```

Start a MySQL container

```shell
docker run -d --volume typo3-mysql:/var/lib/mysql/ --network typo3-db \
    --env MYSQL_DATABASE=typo3 --env MYSQL_USER=typo3 --env MYSQL_PASSWORD=ShouldBeAStrongPassword --env MYSQL_ROOT_PASSWORD=ShouldBeAStrongPassword \
    --name typo3-mysql mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

Start the TYPO3 container that is based on the official PHP Docker Image. There is also a FPM version of the image available.

```shell
docker run -d -p 80:80 --volume typo3:/var/www/html/ --network typo3-db \
    --env TYPO3_DB_HOST=typo3-mysql --env TYPO3_DB_NAME=typo3 --env TYPO3_DB_USERNAME=typo3 --env TYPO3_DB_PASSWORD=ShouldBeAStrongPassword \
    --env TYPO3_ADMIN_PASSWORD=ShouldBeAStrongPassword \
    --name typo3 crinis/typo3:9.5-php7.2-apache
```

Connect to your Docker host on port 80 and login on /typo3 using the default username "admin" and your password.

#### Environment Variables

* `TYPO3_ADMIN_USERNAME` - Initial admin username when installing TYPO3 (defaults to "admin")
* `TYPO3_ADMIN_PASSWORD` - Initial admin and Install Tool password when installing TYPO3
* `TYPO3_DB_HOST` - Database host
* `TYPO3_DB_PORT` - Database port (defaults to "3306")
* `TYPO3_DB_NAME` - Database name
* `TYPO3_DB_USERNAME` - Database username
* `TYPO3_DB_PASSWORD` - Database password
* `TYPO3_SITE_NAME` - Only used during installation (defaults to "TYPO3 CMS")
* `TYPO3_VERSION` - The exact TYPO3 version for example "9.5.5". Replaces the shipped version of TYPO3 that is part of the image
* `TYPO3_CONSOLE_VERSION` - The exact version of the [TYPO3 Console](https://github.com/TYPO3-Console/TYPO3-Console) extension that is added automatically
* `TYPO3_CONTEXT` - Could be "Production" or "Development" and is used by TYPO3 to determine if it runs in production or development mode (defaults to "Production")
* `MODIFY_LOCAL_CONFIGURATION` - Set to "false" to disable modifications to your LocalConfiguration.php (defaults to "true")
* `CLEANUP_TYPO_SRC` - Set to "false" to disable automatic cleanup of unused TYPO3 sources (defaults to "true")

#### Secrets

Secrets can be mounted into the container as files and referenced by environment variables. If set they override the approriate environment variables above.
```
docker run -e TYPO3_ADMIN_PASSWORD_FILE=/run/secrets/typo3-admin-password ... -d crinis/typo3:tag
```

* `TYPO3_ADMIN_USERNAME_FILE`
* `TYPO3_ADMIN_PASSWORD_FILE`
* `TYPO3_DB_HOST_FILE`
* `TYPO3_DB_PORT_FILE`
* `TYPO3_DB_NAME_FILE`
* `TYPO3_DB_USERNAME_FILE`
* `TYPO3_DB_PASSWORD_FILE`

#### Volumes

* `/var/www/html/` - Contains the TYPO3 installation

#### Useful File Locations

* `/docker/AdditionalConfiguration.php` - This file gets copied to /var/www/html/typo3conf/ if no file with that name exist already during container start
* `/docker/local-configuration-overrides.yml` - Contains additional overrides in YAML format that get written to LocalConfiguration.php during container start
* `/docker/htaccess` - Gets copied to /var/www/html/ if no file with that name exists already during container start
* `/etc/supervisor/supervisord.conf` - Supervisor configuration file to manage php-fpm or apache and cron processes 

#### Docker Image Tags

I recommend to use the [Docker image tags](https://hub.docker.com/r/crinis/typo3/tags) starting with the [Git tags](https://github.com/crinis/typo3-docker/tags) of this repository as images containing older TYPO3 Versions might be changed and not be compatible. You should also specify the PHP Version explicitly. A tag used in production should look like this: `0.1.1-typo3_9.5-php7.2-apache`.

##### Apache

* `0.1.1-typo3_6.2-php5.6-apache, 6.2-php5.6-apache, 6.2`
* `0.1.1-typo3_7.6-php7.1-apache, 7.6-php7.1-apache, 7.6`
* `0.1.1-typo3_8.7-php7.2-apache, 8.7-php7.2-apache, 8.7`
* `0.1.1-typo3_9.5-php7.2-apache, 9.5-php7.2-apache, 9.5`

##### PHP FPM

PHP FPM versions of the images are available and can be used with any webserver you like. All of them are based on Alpine.
* `0.1.1-typo3_6.2-php5.6-fpm-alpine, 6.2-php5.6-fpm-alpine`
* `0.1.1-typo3_7.6-php7.1-fpm-alpine, 7.6-php7.1-fpm-alpine`
* `0.1.1-typo3_8.7-php7.2-fpm-alpine, 8.7-php7.2-fpm-alpine`
* `0.1.1-typo3_9.5-php7.2-fpm-alpine, 9.5-php7.2-fpm-alpine`

## Running on Kubernetes

I will shortly release a Helm Chart for easy deployment on Kubernetes.

## Limitations

### TYPO3 6.2 setup

Images for TYPO3 6.2 do not support automatic setup and configuration of TYPO3. You have to go through installation steps manually and make modifications in LocalConfiguration.php.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/crinis/typo3-docker/tags). 

## Authors

* *Felix Spittel* - *Initial work* - [Crinis](https://github.com/crinis)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details. The image contains software that use different licenses.

## Acknowledgments

* This image installs and uses [TYPO3 Console](https://github.com/TYPO3-Console/TYPO3-Console) for easy setup and configuration. Thanks for that awesome CLI.

# TYPO3 Docker Images

[Docker Images](https://hub.docker.com/r/crinis/typo3) for most TYPO3 LTS versions

## Project state

The Docker images in this project are not yet production ready and might be modified without backwards compatibility at any time. Make sure to set your deployment image to use specific version tags.

## Getting Started

These instructions cover usage information for the Docker image.

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

Start the TYPO3 container that is based on the official PHP Docker Image.

```shell
docker run -d -p 80:80 --volume typo3:/var/www/html/ --network typo3-db \
    --env TYPO3_DB_HOST=typo3-mysql --env TYPO3_DB_NAME=typo3 --env TYPO3_DB_USERNAME=typo3 --env TYPO3_DB_PASSWORD=ShouldBeAStrongPassword \
    --env TYPO3_ADMIN_PASSWORD=ShouldBeAStrongPassword \
    --name typo3 crinis/typo3:9.5-php7.2-apache
```

Connect to your Docker host on port 80 and login on /typo3 using the default username "admin" and your password.

#### Environment Variables

* `TYPO3_ADMIN_USERNAME` - Initial admin username when installing TYPO3. (defaults to "admin")
* `TYPO3_ADMIN_PASSWORD` - Initial admin and Install Tool password when installing TYPO3.
* `TYPO3_DB_HOST` - Database host.
* `TYPO3_DB_PORT` - Database port. (defaults to "3306")
* `TYPO3_DB_NAME` - Database name.
* `TYPO3_DB_USERNAME` - Database username.
* `TYPO3_DB_PASSWORD` - Database password.
* `TYPO3_SITE_NAME` - Sets the sites title. (defaults to "TYPO3 CMS")
* `TYPO3_CONTEXT` - Could be "Production" or "Development" and is used by TYPO3 to determine if it runs in production or development mode. (defaults to "Production")
* `MODIFY_LOCAL_CONFIGURATION` - Set to "false" to disable modifications to your LocalConfiguration.php. (defaults to "true")
* `SETUP_TYPO3_SRC` - Setup symlinks for TYPO3 source that is shipped with the image. (defaults to "true")
* `SETUP_TYPO3` - Attempts to setup TYPO3 ands adds a basic .htaccess file and cache configuration. (defaults to "true")

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

* `/docker/AdditionalConfiguration.php` - This file gets copied to /var/www/html/typo3conf/ if no file with that name exist already during TYPO3 setup.
* `/docker/htaccess` - Gets copied to /var/www/html/ if no file with that name exists already during TYPO3 setup. Only in TYPO3 7.6 and 6.2.
* `/etc/supervisor/supervisord.conf` - Supervisor configuration file to manage apache and cron processes.

#### Docker Image Tags

I recommend to use the image tags containing the exact TYPO3 version number including patch version like so: crinis/typo3:9.5.18-php7.4-apache. Images specified like that have to be updated manually by changing the tag. It is also possible to specify only the TYPO3 minor version like "crinis/typo3:9.5-php7.2-apache". This image will be regularly rebuild including the latest TYPO3 patch version and base image, but might contain non backwards compatible changes which can lead to application failures.

##### Apache

* `6.2.x-php5.6-apache, 6.2-php5.6-apache, 6.2.x, 6.2`
* `7.6.x-php7.1-apache, 7.6-php7.1-apache, 7.6.x, 7.6`
* `8.7.x-php7.2-apache, 8.7-php7.2-apache, 8.7.x, 8.7`
* `9.5.x-php7.2-apache, 9.5-php7.2-apache, 9.5.x-php7.3-apache, 9.5-php7.3-apache, 9.5.x-php7.4-apache, 9.5-php7.4-apache, 9.5.x, 9.5`
* `10.4.x-php7.4-apache, 10.4-php7.4-apache, 10.4.x, 10.4, latest`

## Running on Kubernetes

An experimental Helm Chart is available [here](https://github.com/crinis/typo3-helm-chart). There is no documentation yet so read the values.yaml file for variables.

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

* This image installs and uses [TYPO3 Console](https://github.com/TYPO3-Console/TYPO3-Console) for simple setup and configuration.

# PHP Images for use with TYPO3

PHP Docker images configured for TYPO3. They are meant as base images for my [TYPO3 Images](https://github.com/crinis/typo3-docker), but can also be used for e.g. local development.

## Environment Variables

`SET_OWNER` - If set to "true" and the container is run as "root" recursively sets owner of files in "/var/www/html/" to "www-data". Defaults to "true".

## Rootless Use

When run rootless the containers accept connections on port 8080 and include [Supercronic](https://github.com/aptible/supercronic) to allow rootless usage.
See the [podman-compose.yml](podman-compose.yml) file for an example on how to use the images.

## Cronjobs

For seperation of concerns a second container with the same image can be used to run cronjobs.

On rootful setups you can setup a crontab file in "/var/spool/cron/crontabs/www-data". You just need to set the entrypoint to `/usr/sbin/cron -f`.

On rootless setups we can't use the native cron daemon. Instead [Supercronic](https://github.com/aptible/supercronic) is used. You can setup "crontab" file in "/typo3/crontab". You just need to set the entrypoint to `/usr/local/bin/supercronic /typo3/crontab`.

## Authors

[Crinis](https://github.com/crinis)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details. The image contains software that use different licenses.

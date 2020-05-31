#!/usr/bin/env bash
#
# Builds TYPO3 Docker images locally

set -e

docker build -t crinis/typo3:10.4-php7.4-apache --build-arg TYPO3_VERSION="10.4.3" .

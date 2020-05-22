#!/usr/bin/env bash
#
# Builds TYPO3 Docker images locally

set -e

docker build -t crinis/typo3:7.6-php7.1-apache --build-arg TYPO3_VERSION="7.6.32" .

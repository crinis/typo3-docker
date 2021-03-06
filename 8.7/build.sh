#!/usr/bin/env bash
#
# Builds TYPO3 Docker images locally

set -e

docker build -t crinis/typo3:8.7-php7.2-apache --build-arg TYPO3_VERSION="8.7.32" .

#!/usr/bin/env bash
#
# Builds TYPO3 Docker images locally

set -e

docker build -t crinis/typo3:11.5-php8.1-apache --build-arg TYPO3_VERSION="11.5.15" .

#!/usr/bin/env bash
#
# Builds TYPO3 Docker images locally

set -e

docker build -t crinis/typo3:6.2-php5.6-apache --build-arg TYPO3_VERSION="6.2.31" .

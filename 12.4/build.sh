#!/bin/bash
#
# Build TYPO3 container image locally.

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <docker|podman>"
    exit 1
fi

TOOL=$1

if [ "$TOOL" != "docker" ] && [ "$TOOL" != "podman" ]; then
    echo "Invalid argument: $TOOL. Use 'docker' or 'podman'."
    exit 1
fi

$TOOL build -t docker.io/crinis/typo3:12.4 -t docker.io/crinis/typo3:latest .

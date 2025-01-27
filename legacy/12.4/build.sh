#!/bin/bash
#
# Build TYPO3 container image locally.

set -e

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <docker|podman> [build-arg1=value1] [build-arg2=value2] ..."
    exit 1
fi

TOOL=$1
shift

if [ "$TOOL" != "docker" ] && [ "$TOOL" != "podman" ]; then
    echo "Invalid argument: $TOOL. Use 'docker' or 'podman'."
    exit 1
fi

BUILD_ARGS=""
for ARG in "$@"; do
    BUILD_ARGS+="--build-arg $ARG "
done

$TOOL build $BUILD_ARGS -t docker.io/crinis/typo3:legacy-12.4 -t docker.io/crinis/typo3:legacy .

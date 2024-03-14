#!/bin/bash

# Default values for variables
DEFAULT_PLATFORM="linux/amd64"
DEFAULT_WORKSPACE="hb_ws"
DEFAULT_USER="hb"
DEFAULT_IMAGE="macnack/hb_deploy:humble"

# Use command-line arguments if provided, otherwise use defaults
PLATFORM="${1:-$DEFAULT_PLATFORM}"
WORKSPACE="${2:-$DEFAULT_WORKSPACE}"
USER="${3:-$DEFAULT_USER}"
IMAGE="${4:-$DEFAULT_IMAGE}"

# Build command using the variables
docker build --network=host --platform "${PLATFORM}" \
    --build-arg WORKSPACE="${WORKSPACE}" \
    --build-arg USER="${USER}" \
    -t "${IMAGE}" .
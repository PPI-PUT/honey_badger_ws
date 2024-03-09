#!/bin/bash

# Default values for variables
DEFAULT_PLATFORM="linux/amd64/v4"
DEFAULT_WORKSPACE="hb_ws"
DEFAULT_IMAGE="macnack/hb_deploy:humble"

# Use command-line arguments if provided, otherwise use defaults
PLATFORM="${1:-$DEFAULT_PLATFORM}"
WORKSPACE="${2:-$DEFAULT_WORKSPACE}"
IMAGE="${3:-$DEFAULT_IMAGE}"

# Build command using the variables
DOCKER_BUILDKIT=1 docker build --network=host --platform "${PLATFORM}" \
    --build-arg WORKSPACE="${WORKSPACE}" \
    -t "${IMAGE}" .
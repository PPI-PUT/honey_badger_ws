#!/bin/bash

# Copyright (c) 2024 Maciej Krupka. All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.

# DISCLAIMER:
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
# OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
# OF SUCH DAMAGE.
set -e
L_FORCE_FLAG=0
L_TARGET_USER="hb"
L_ROBOT_ID="1"
L_WORKSPACE="hb_ws"
L_DOCKER_IMAGE="macnack/hb_deploy:humble"
L_DOCKER_CONTAINER_NAME="hb_deploy"
L_TIME_FLAG=1
# USAGE:
# ./deploy.sh [-f|--force] [TARGET_USER] [WORKSPACE] [ROBOT_ID] [DOCKER_IMAGE] [DOCKER_CONTAINER_NAME]
# or just
# ./deploy.sh [-f|--force]

# OPTIONS:
# -f, --force     Force deployment even if the target already has the same Docker image
# TARGET_USER     The user on the target machine. Default: "macnack"
#                 (for the author's setup but hb or hborin is expected for the rebot deploy)
# ROBOT_ID        The robot ID. Default: "1"
# WORKSPACE       The workspace directory on the target machine. Default: "hb_ws"
# DOCKER_IMAGE    The Docker image to deploy. Default: "macnack/hb_deploy:humble"
# DOCKER_CONTAINER_NAME The name of the Docker container. Default: "hb_deploy"

# TODO:
# - chose TARGET_USER ping host AND GET TARGET_host ROBOT_ID, ROS_DOMAIN_ID

# DESCRIPTION:
# This script is used to deploy a Docker image to a remote machine. It will build the Docker image
# and then copy it to the target machine. It will also copy the run.sh script to the target machine
# and execute it. The run.sh script will run the Docker container with the image that was copied.

FORCE_FLAG="${1:-$L_FORCE_FLAG}"
TARGET_USER="${2:-$L_TARGET_USER}"
ROBOT_ID="${3:-$L_ROBOT_ID}"
WORKSPACE="${4:-$L_WORKSPACE}"
DOCKER_IMAGE="${5:-$L_DOCKER_IMAGE}"
DOCKER_CONTAINER_NAME="${6:-$L_DOCKER_CONTAINER_NAME}"
TIME_FLAG="${7:-$L_TIME_FLAG}"
# Parse optional flags
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--force) FORCE_FLAG=1 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

TARGET_HOST="" # DON CHANGE THIS LINE - it will be set based on the TARGET_USER and ROBOT_ID

if [ "${TARGET_USER}" == "hb" ]; then
    TARGET_HOST="${TARGET_USER}40-${ROBOT_ID}.lan"
    PLATFORM="linux/amd64"
fi
if [ "${TARGET_USER}" == "hborin" ]; then
    TARGET_HOST="${TARGET_USER}-${ROBOT_ID}.lan"
    PLATFORM="linux/arm64"
fi
if [ -z "${TARGET_HOST}" ]; then
    echo "Unknown TARGET_USER. Exiting."
    echo "TARGET_USER: ${TARGET_USER}"
    exit 1
fi

TARGET_PATH="/home/${TARGET_USER}/${WORKSPACE}"
TARGET_DOCKER_PATH="${TARGET_PATH}/.devcontainer"
DOCKER_TAR="${DOCKER_IMAGE/\//_}"
DOCKER_TAR="${DOCKER_TAR%:*}.tar"

echo "Checking connectivity to ${TARGET_HOST}..."
ping -c 3 "${TARGET_HOST}" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "No ping response from ${TARGET_HOST}. The host might be down or the ROBOT ID is wrong. Exiting."
    exit 1
fi

# if the time flag is set to update the time on the target machine
if [ $TIME_FLAG -eq 1 ]; then
    echo "Update time, send via host to the target machine"
    CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
    TIME_ZONE=$(timedatectl | grep "Time zone" | awk '{print $3}')
    CMD="sudo date -s '${CURRENT_TIME}' && sudo timedatectl set-timezone ${TIME_ZONE}"
    ssh -t ${TARGET_USER}@${TARGET_HOST} "${CMD}" && echo "Time synchronized successfully."
fi
echo "[1/8] Running build script..."
./build.sh "${PLATFORM}" "${WORKSPACE}" "${TARGET_USER}" "${DOCKER_IMAGE}" || { echo "Failed to build Docker image. Exiting."; exit 1; }

LOCAL_IMAGE_ID=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | grep "${DOCKER_IMAGE}" | awk '{print $2}')
REMOTE_IMAGE_ID=$(ssh "${TARGET_USER}@${TARGET_HOST}" "docker images --format \"{{.Repository}}:{{.Tag}} {{.ID}}\"" | grep "${DOCKER_IMAGE}" | awk '{print $2}')

if [[ "$LOCAL_IMAGE_ID" == "$REMOTE_IMAGE_ID" && $FORCE_FLAG -eq 0 ]]; then
    echo "The target already has the same Docker image as the host. Use -f or --force to override."
    exit 0
    elif [[ "$LOCAL_IMAGE_ID" == "$REMOTE_IMAGE_ID" && $FORCE_FLAG -eq 1 ]]; then
    echo "Force flag detected. Proceeding with deployment despite image match..."
fi

echo "[2/8] Saving the image to a tar file: ${DOCKER_TAR}"
if ! docker save -o "${DOCKER_TAR}" "${DOCKER_IMAGE}"; then
    echo "Failed to save the Docker image to a tar file. Exiting."
    exit 1
fi

echo "[3/8] Ensuring TARGET_DOCKER_PATH exists on the target machine: ${TARGET_DOCKER_PATH}"
CMD_MKDIR="mkdir -p ${TARGET_DOCKER_PATH}"
ssh "${TARGET_USER}@${TARGET_HOST}" "${CMD_MKDIR}" || { echo "Failed to ensure TARGET_PATH exists. Exiting."; exit 1; }

echo "[4/8] Copying the tar file to the target machine: ${TARGET_DOCKER_PATH}/${DOCKER_TAR}"
scp "${DOCKER_TAR}" "${TARGET_USER}@${TARGET_HOST}:${TARGET_DOCKER_PATH}" || { echo "Failed to copy tar file. Exiting."; exit 1; }

echo "[5/8] Load docker image on target machine"
CMD="docker load --input ${TARGET_DOCKER_PATH}/${DOCKER_TAR}"
ssh "${TARGET_USER}@${TARGET_HOST}" "${CMD}" || { echo "Failed to load docker image. Exiting."; exit 1; }

echo "[6/8] Removing the tar file from the host machine: ${DOCKER_TAR}"
rm "${DOCKER_TAR}" || { echo "Failed to remove tar file. Exiting."; exit 1; }

echo "[7/8] Checking and transferring run.sh script to the target machine using rsync"

let ROS_DOMAIN_ID=${ROBOT_ID}+69

# Create run.sh script
cat <<EOF >run.sh
#!/bin/bash
docker run -it --network host --privileged \
    --name ${DOCKER_CONTAINER_NAME} \
    --env RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    --env ROS_DOMAIN_ID=${ROS_DOMAIN_ID} \
    --volume /dev/:/dev/ \
    ${DOCKER_IMAGE} bash
EOF
cat <<EOF >test.sh
#!/bin/bash
docker run --rm --network host --privileged \
    --name ${DOCKER_CONTAINER_NAME}_test \
    --env RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
    --env ROS_DOMAIN_ID=${ROS_DOMAIN_ID} \
    ${DOCKER_IMAGE} bash
EOF
# Create enter.sh script
cat <<EOF >enter.sh
#!/bin/bash
docker exec -it ${DOCKER_CONTAINER_NAME} bash
EOF

# Use rsync to transfer run.sh and enter.sh to the target machine only if changes are detected
rsync -avz --progress run.sh "${TARGET_USER}@${TARGET_HOST}:${TARGET_PATH}/run.sh" || { echo "Failed to transfer run.sh script. Exiting."; exit 1; }
rsync -avz --progress enter.sh "${TARGET_USER}@${TARGET_HOST}:${TARGET_PATH}/enter.sh" || { echo "Failed to transfer enter.sh script. Exiting."; exit 1; }
rsync -avz --progress test.sh "${TARGET_USER}@${TARGET_HOST}:${TARGET_PATH}/test.sh" || { echo "Failed to transfer test.sh script. Exiting."; exit 1; }
ssh "${TARGET_USER}@${TARGET_HOST}" "chmod +x ${TARGET_PATH}/run.sh && chmod +x ${TARGET_PATH}/enter.sh" || { echo "Failed to chmod +x .sh script. Exiting."; exit 1; }

echo "[8/8] Executing test.sh on the target machine bash ${TARGET_PATH}/test.sh"
ssh "${TARGET_USER}@${TARGET_HOST}" "bash ${TARGET_PATH}/test.sh" || { echo "Failed to execute run.sh on target machine. Exiting."; exit 1; }
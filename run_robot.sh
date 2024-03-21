#!/bin/bash

# Variables
TARGET_HOST="hb"
WORKSPACE="hb_ws"


LPC_ADRESS="10.0.0.10"
LPC_USER="hb"
APC_ADRESS="10.0.0.11"
APC_USER="hborin"
WORKSPACE_PATH="/home/${TARGET_HOST}/${WORKSPACE}"
CMD="cd ${WORKSPACE_PATH}; bash ./run.sh; exec \$SHELL"

echo "${CMD}"
if [ "$TARGET_HOST" == "$LPC_USER" ]; then
    ssh -t $LPC_USER@$LPC_ADRESS $CMD
elif [ "$TARGET_HOST" == "$APC_USER" ]; then
    ssh -t $APC_USER@$APC_ADRESS $CMD
else
    echo "Error: TARGET_HOST does not match any user."
    exit 1
fi
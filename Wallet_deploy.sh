#!/bin/bash

# Disclaimer
##################################################################################################################
# You running this script/function means you will not blame the author(s),
# if this breaks your stuff. This script/function is provided AS IS without warranty of any kind. 
# Author(s) disclaim all implied warranties including, without limitation, 
# any implied warranties of merchantability or of fitness for a particular purpose. 
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall author(s) be held liable for any damages whatsoever 
# (including, without limitation, damages for loss of business profits, business interruption, 
# loss of business information, or other pecuniary loss) arising out of the use of or inability 
# to use the script or documentation. Neither this script/function, 
# nor any part of it other than those parts that are explicitly copied from others, 
# may be republished without author(s) express written permission. 
# Author(s) retain the right to alter this disclaimer at any time.
##################################################################################################################

source "$HOME/net.ton.dev/scripts/env.sh"

WALL_NAME=$1
MSIG_JSON=${WALL_NAME:-"msig"}
WALL_FILE=${WALL_NAME:-$HOSTNAME}

echo "MSIG_JSON: $MSIG_JSON"

OWN_PUB_KEY=0x`cat ${KEYS_DIR}/${MSIG_JSON}.keys.json | jq ".public" | tr -d '"'`
WALL_ADDR=`cat ${KEYS_DIR}/${WALL_FILE}.addr`

echo
echo "Deploy wallet $WALL_ADDR"
echo "Public key = ${OWN_PUB_KEY}"
echo


read -p "Is this a right wallet (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        tonos-cli deploy \
        ${CONFIGS_DIR}/SafeMultisigWallet.tvc \
        "{\"owners\":[\"$OWN_PUB_KEY\"],\"reqConfirms\":1}" \
        --abi ${CONFIGS_DIR}/SafeMultisigWallet.abi.json \
        --sign ${KEYS_DIR}/${MSIG_JSON}.keys.json \
        --wc -1 

    ;;
    * )
        echo "Cancelled."
    ;;
esac

exit 0

#!/bin/bash

# Disclaimer
##################################################################################################################
# You running this script/function means you will not blame the author(s).
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
#############################################################
# This script DOESNOT REPLACMENT of vavidator_msig.sh !!!   #
# USE validator_msig.sh FIRST!!                             #
# DON'T SEND ALL AMOUNT YOU HAVE! LEAVE AT LEAST 10 TOKENS! #
#############################################################

set -o pipefail

if [ "$DEBUG" = "yes" ]; then
    set -x
fi

echo "INFO: $(basename "$0") BEGIN $(date +%s) / $(date)"

SCRIPT_DIR=$HOME/net.ton.dev/scripts
cd $SCRIPT_DIR
source "${SCRIPT_DIR}/env.sh"

STAKE="$1"

if [ -z "${STAKE}" ]; then
    echo "ERROR: STAKE (in tokens) is not specified"
    echo "Usage: $(basename "$0") <STAKE>"
    exit 1
fi

MAX_FACTOR=${MAX_FACTOR:-3}
TONOS_CLI_SEND_ATTEMPTS="1"
MSIG_ADDR=$(cat "${KEYS_DIR}/${VALIDATOR_NAME}.addr")
[[ -z $MSIG_ADDR ]] && exit 1
echo "INFO: MSIG_ADDR = ${MSIG_ADDR}"
ELECTIONS_WORK_DIR="${KEYS_DIR}/elections"
[[ -z $ELECTIONS_WORK_DIR ]] && exit 1
validator_query_boc=$(base64 "${ELECTIONS_WORK_DIR}/validator-query.boc" | tr -d "\n")
[[ -z $validator_query_boc ]] && exit 1
elector_addr=$(cat "${ELECTIONS_WORK_DIR}/elector-addr-base64")
[[ -z $elector_addr ]] && exit 1
NANOSTAKE=$("${UTILS_DIR}/tonos-cli" convert tokens "$STAKE" | tail -1)
[[ -z $NANOSTAKE ]] && exit 1
echo "INFO: NANOSTAKE = $NANOSTAKE nanotokens"

for i in $(seq ${TONOS_CLI_SEND_ATTEMPTS}); do
    echo "INFO: tonos-cli submitTransaction attempt #${i}..."
    set -x
    if ! "${UTILS_DIR}/tonos-cli" call "${MSIG_ADDR}" submitTransaction \
        "{\"dest\":\"${elector_addr}\",\"value\":\"${NANOSTAKE}\",\"bounce\":true,\"allBalance\":false,\"payload\":\"${validator_query_boc}\"}" \
        --abi "${CONFIGS_DIR}/SafeMultisigWallet.abi.json" \
        --sign "${KEYS_DIR}/msig.keys.json"; then
        echo "INFO: tonos-cli submitTransaction attempt #${i}... FAIL"
    else
        echo "INFO: tonos-cli submitTransaction attempt #${i}... PASS"
        break
    fi
    set +x
done
    
date +"INFO: %F %T prepared for elections"
echo "INFO: $(basename "$0") END $(date +%s) / $(date)"


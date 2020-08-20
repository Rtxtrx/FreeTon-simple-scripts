#!/bin/bash -eE

# (C) Sergey Tyurin  2020-08-18 17:00:00

# Disclaimer
##################################################################################################################
# You running this script/function means you will not blame the author(s)
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

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

ELECTIONS_WORK_DIR="${KEYS_DIR}/elections"
[[ ! -d ${ELECTIONS_WORK_DIR} ]] && mkdir -p ${ELECTIONS_WORK_DIR}
chmod +x ${ELECTIONS_WORK_DIR}

SCs_DIR="$NET_TON_DEV_SRC_TOP_DIR/ton-labs-contracts/solidity/depool"

# tonos-cli deploy DePoolProxy.tvc '{"depool":"<DePoolAddress>"}' --abi DePoolProxy.abi.json --sign proxy0.json --wc -1

Depool_addr=`cat ${KEYS_DIR}/depool.addr`

echo "Depool_addr: $Depool_addr"

tonos-cli deploy ${SCs_DIR}/DePoolProxy.tvc "{\"depool\":\"$Depool_addr\"}" --abi ${SCs_DIR}/DePoolProxy.abi.json --sign ${KEYS_DIR}/proxy0.json --wc -1 | tee ${ELECTIONS_WORK_DIR}/proxy0-deploy.log
tonos-cli deploy ${SCs_DIR}/DePoolProxy.tvc "{\"depool\":\"$Depool_addr\"}" --abi ${SCs_DIR}/DePoolProxy.abi.json --sign ${KEYS_DIR}/proxy1.json --wc -1 | tee ${ELECTIONS_WORK_DIR}/proxy1-deploy.log


exit 0

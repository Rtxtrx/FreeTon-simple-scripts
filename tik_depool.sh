#!/bin/bash -eE

# (C) Sergey Tyurin  2020-08-19 17:00:00

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

Depool_addr=`cat ${KEYS_DIR}/depool.addr`
Helper_addr=`cat ${KEYS_DIR}/helper.addr`
Proxy0_addr=`cat ${KEYS_DIR}/proxy0.addr`
Proxy1_addr=`cat ${KEYS_DIR}/proxy1.addr`
Validator_addr=`cat ${KEYS_DIR}/${HOSTNAME}.addr`
Tik_addr=`cat ${KEYS_DIR}/Tik.addr`
Work_Chain=`echo "${Tik_addr}" | cut -d ':' -f 1`

SCs_DIR="$NET_TON_DEV_SRC_TOP_DIR/ton-labs-contracts/solidity/depool"

# tonos-cli call <адрес_мультисига> sendTransaction '{"dest":"<адрес_депула>","value":1000000000,"bounce":true,"flags":3,"payload":"te6ccgEBAQEABgAACCiAmCM="}' --abi SafeMultisigWallet.abi.json --sign msig.keys.json
#                                                                                        1000000000 = 1 token
tonos-cli call "$Tik_addr" sendTransaction "{\"dest\":\"$Depool_addr\",\"value\":1000000000,\"bounce\":true,\"flags\":3,\"payload\":\"te6ccgEBAQEABgAACCiAmCM=\"}" \
    --abi ${CONFIGS_DIR}/SafeMultisigWallet.abi.json \
    --sign ${KEYS_DIR}/Tik.keys.json

exit 0

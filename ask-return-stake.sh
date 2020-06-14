#!/bin/bash

# set -x

set -o pipefail

echo "======================================================================================="
echo "INFO: $(basename "$0") BEGIN $(date +%s) / $(date +'%Y-%m-%d %H:%M:%S')"

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

#==================================================
#########################
REQUESTOR_NAME=$1
#########################

VAL_HOST_NAME=`hostname -s`
if [[ -z ${REQUESTOR_NAME} ]];then
    MSIG_ADDR=`cat "${KEYS_DIR}/${HOSTNAME}.addr"`
    SIGN_FILE="${KEYS_DIR}/msig.keys.json"
else
    MSIG_ADDR=`cat "${REQUESTOR_NAME}.addr"`
    SIGN_FILE="./${REQUESTOR_NAME}.keys.json"
    ELECTIONS_WORK_DIR="./elections"
fi

echo "INFO: MSIG_ADDR = ${MSIG_ADDR}"
mkdir -p "${ELECTIONS_WORK_DIR}"
#==================================================

TONOS_CLI_SEND_ATTEMPTS="100"
# Get elector address
"${TON_BUILD_DIR}/lite-client/lite-client" \
    -p "${KEYS_DIR}/liteserver.pub" \
    -a 127.0.0.1:3031 \
    -rc "getconfig 1" -rc "quit" \
    &>"${ELECTIONS_WORK_DIR}/elector-addr"

# Get elector state, addr-base64, make run
awk -v TON_BUILD_DIR="${TON_BUILD_DIR}" -v KEYS_DIR="${KEYS_DIR}" -v ELECTIONS_WORK_DIR="${ELECTIONS_WORK_DIR}" '{
    if (substr($1, length($1)-13) == "ConfigParam(1)") {
        printf TON_BUILD_DIR "/lite-client/lite-client ";
        printf "-p " KEYS_DIR "/liteserver.pub -a 127.0.0.1:3031 ";
        printf "-rc \"runmethod -1:" substr($4, 15, 64) " ";
        print  "active_election_id\" -rc \"quit\" &> " ELECTIONS_WORK_DIR "/elector-state"
        printf "echo -1:" substr($4, 15, 64) " > " ELECTIONS_WORK_DIR "/elector-addr-base64"
    }
}' "${ELECTIONS_WORK_DIR}/elector-addr" >"${ELECTIONS_WORK_DIR}/elector-run"

# get elector state
bash "${ELECTIONS_WORK_DIR}/elector-run"

awk '{
    if ($1 == "result:") {
        print $3
    }   
}' "${ELECTIONS_WORK_DIR}/elector-state" >"${ELECTIONS_WORK_DIR}/election-id"

election_id=`cat "${ELECTIONS_WORK_DIR}/election-id"`
elector_addr=`cat "${ELECTIONS_WORK_DIR}/elector-addr-base64"`

# Get returned stake amount
"${TON_BUILD_DIR}/lite-client/lite-client" \
    -p "${KEYS_DIR}/liteserver.pub" -a 127.0.0.1:3031 \
    -rc "runmethod ${elector_addr} compute_returned_stake 0x$(echo "${MSIG_ADDR}" | cut -d ':' -f 2)" \
    -rc "quit" &> "${ELECTIONS_WORK_DIR}/recover-state"

awk '{
    if ($1 == "result:") {
        print $3
    }
}' "${ELECTIONS_WORK_DIR}/recover-state" >"${ELECTIONS_WORK_DIR}/recover-amount"
    
recover_amount=`cat "${ELECTIONS_WORK_DIR}/recover-amount"`
echo "Recover amount: ${recover_amount}"
# Ask to return stake amount   
if [ "$recover_amount" != "0" ]; then
    "${TON_BUILD_DIR}/crypto/fift" -I "${TON_SRC_DIR}/crypto/fift/lib:${TON_SRC_DIR}/crypto/smartcont" -s recover-stake.fif "${ELECTIONS_WORK_DIR}/recover-query.boc"
        
    recover_query_boc=`base64 --wrap=0 "${ELECTIONS_WORK_DIR}/recover-query.boc"`
        
    for i in `seq ${TONOS_CLI_SEND_ATTEMPTS}`; do
        echo "INFO: tonos-cli submitTransaction attempt #${i}..."
        if ! "${UTILS_DIR}/tonos-cli" call "${MSIG_ADDR}" submitTransaction \
            "{\"dest\":\"${elector_addr}\",\"value\":\"1000000000\",\"bounce\":true,\"allBalance\":false,\"payload\":\"${recover_query_boc}\"}" \
            --abi "${CONFIGS_DIR}/SafeMultisigWallet.abi.json" \
            --sign "${SIGN_FILE}"; then
            echo "INFO: tonos-cli submitTransaction attempt #${i}... FAIL"
        else
            echo "INFO: tonos-cli submitTransaction attempt #${i}... PASS"
            break
        fi
    done

    date +"INFO: %F %T Recover of $recover_amount GR requested"
fi
 
if [ "$election_id" == "0" ]; then
    date +"INFO: %F %T No current elections"

    echo "INFO: $(basename "$0") END $(date +%s) / $(date +'%Y-%m-%d %H:%M:%S')"
    exit
fi

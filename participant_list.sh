#!/bin/bash

# (C) Sergey Tyurin  2020-08-01 08:00:00

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

set -o pipefail

hex2dec() {
    OS_SYSTEM=`uname`
    ival="${1^^}"
    ob=${2:-10}
    ib=${3:-16}
    if [[ "$OS_SYSTEM" == "Linux" ]];then
        export BC_LINE_LENGTH=0
        # set obase first before ibase -- or weird things happen.
        printf "obase=%d; ibase=%d; %s\n" $ob $ib $ival | bc
    else
        dc -e "${ib}i ${ival} p" | tr -d "\\" | tr -d '\n'
    fi
}

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"
OS_SYSTEM=`uname`
if [[ "$OS_SYSTEM" == "Linux" ]];then
    CALL_BC="bc"
else
    CALL_BC="bc -l"
fi
ELECTIONS_WORK_DIR="${KEYS_DIR}/elections"
CALL_LC="${TON_BUILD_DIR}/lite-client/lite-client -p ${KEYS_DIR}/liteserver.pub -a 127.0.0.1:3031 -t 5"

# =======================================================================================================
elector_addr=`cat ${ELECTIONS_WORK_DIR}/elector-addr-base64`
ADNL_KEY="$1"
Curr_ADNL_Key=`cat ${ELECTIONS_WORK_DIR}/${VALIDATOR_NAME}-election-adnl-key | grep "created new key" | awk '{print $4}'`
ADNL_KEY=${ADNL_KEY:=$Curr_ADNL_Key}

trap 'echo LC TIMEOUT EXIT' EXIT
election_id=`$CALL_LC -rc "runmethod $elector_addr active_election_id" -rc "quit" 2>/dev/null | grep "result:" | awk '{print $3}' `
trap - EXIT

if [ "$election_id" == "0" ]; then
    VALS_DEF="NEXT"
    echo
    date +"INFO: %F %T No current elections"
    VALS_LIST=`$CALL_LC -rc "getconfig 36" -rc "quit" 2>/dev/null`
    if [[ ! -z $(echo "$VALS_LIST" | grep "ConfigParam(36)" | grep "null") ]];then
        VALS_LIST=`$CALL_LC -rc "getconfig 34" -rc "quit" 2>/dev/null`
        VALS_DEF="CURRENT"
    fi
    FOUND_PUB_KEY=`echo "$VALS_LIST" | grep -i "$Curr_ADNL_Key" | awk -F ":" '{print $3}'| awk '{print $1}' | tr -d 'x' | tr -d ')'`
    if [[ -z $FOUND_PUB_KEY ]];then
        echo "###-ERROR: Your ADNL Key NOT FOUND in current or next validators list!!!"
        echo
        exit 1
    fi

    VAL_WEIGHT=`echo "$VALS_LIST" | grep -i "$Curr_ADNL_Key" | awk -F ":" '{print $4}'| awk '{print $1}'`
    echo
    echo "INFO: Found you in $VALS_DEF validators with weight $(echo "scale=3; ${VAL_WEIGHT} / 10000000000000000" | $CALL_BC)%"
    echo "INFO: Your public key: $FOUND_PUB_KEY"
    echo "INFO: Your   ADNL key: $ADNL_KEY"
    echo
    exit 0
fi
echo "INFO: Current Elections ID: $election_id"
MSIG_ADDR=`cat "${KEYS_DIR}/${VALIDATOR_NAME}.addr"`
val_acc_addr=`echo "${MSIG_ADDR}" | cut -d ':' -f 2`
dec_val_acc_addr=$(hex2dec "$val_acc_addr")
echo "INFO: MSIG_ADDR = ${MSIG_ADDR} / $dec_val_acc_addr"

dec_val_adnl=$(hex2dec "$ADNL_KEY")
echo "INFO: DECIMAL ADNL = ${dec_val_adnl}"

# public key : [ stake, max_factor, wallet (addr), adnl (adnl_addr) ]
trap 'echo LC TIMEOUT EXIT' EXIT
LC_OUTPUT=$($CALL_LC -rc "runmethodfull $elector_addr participant_list_extended" -rc "quit" 2>/dev/null)
trap - EXIT

ADDR_FOUND=`echo "${LC_OUTPUT}" | tr "]]" "\n" | grep "$dec_val_acc_addr" | tr -d "[" | awk '{print $5}'`
if [[ -z $ADDR_FOUND ]];then
    echo "###-ERROR: Can't find in participant list account: ${MSIG_ADDR} / $dec_val_acc_addr"
    exit 1
fi

Your_Stake=`echo "${LC_OUTPUT}" | tr "]]" "\n" | grep "$dec_val_adnl" | tr -d "[" | awk '{print $2 / 1000000000}'`
Your_ADNL=`echo "${LC_OUTPUT}" | tr "]]" "\n" | grep "$dec_val_adnl" | tr -d "[" | awk '{print $5}'`
echo "---INFO: Your stake: $Your_Stake with ADNL: $Curr_ADNL_Key"

exit 0


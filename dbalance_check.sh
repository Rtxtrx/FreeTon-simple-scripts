#!/bin/bash -eE

# (C) Sergey Tyurin  2020-08-19 19:00:00

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

set -o pipefail
# set -u
# set -x

function not_found(){
    if [[ -z $ACC_STATUS ]];then
    echo
    echo "Account not found!"
    echo
    fi
}

trap not_found EXIT

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

Tik_addr=`cat ${KEYS_DIR}/Tik.addr`
Depool_addr=`cat ${KEYS_DIR}/depool.addr`
Helper_addr=`cat ${KEYS_DIR}/helper.addr`
Proxy0_addr=`cat ${KEYS_DIR}/proxy0.addr`
Proxy1_addr=`cat ${KEYS_DIR}/proxy1.addr`
Validator_addr=`cat ${KEYS_DIR}/${HOSTNAME}.addr`

CALL_LT="${TON_BUILD_DIR}/lite-client/lite-client -p ${KEYS_DIR}/liteserver.pub -a 127.0.0.1:3031"

Tik_INFO=`$CALL_LT -rc "getaccount ${Tik_addr}" -t "3" -rc "quit" 2>/dev/null `
Depool_INFO=`$CALL_LT -rc "getaccount ${Depool_addr}" -t "3" -rc "quit" 2>/dev/null `
Helper_INFO=`$CALL_LT -rc "getaccount ${Helper_addr}" -t "3" -rc "quit" 2>/dev/null `
Proxy0_INFO=`$CALL_LT -rc "getaccount ${Proxy0_addr}" -t "3" -rc "quit" 2>/dev/null `
Proxy1_INFO=`$CALL_LT -rc "getaccount ${Proxy1_addr}" -t "3" -rc "quit" 2>/dev/null `
Validator_INFO=`$CALL_LT -rc "getaccount ${Validator_addr}" -t "3" -rc "quit" 2>/dev/null `

#ACC_STATUS=`echo "$ACCOUNT_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`
Tik_AMOUNT=`echo "$Tik_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
Tik_LAST_TR_TIME=`echo "$Tik_INFO" | grep "last_paid" | gawk -F ":" '{print strftime("%Y-%m-%d %H:%M:%S", $5)}'`
Tik_Status=`echo "$Tik_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`

Depool_AMOUNT=`echo "$Depool_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
Depool_LAST_TR_TIME=`echo "$Depool_INFO" | grep "last_paid" | gawk -F ":" '{print strftime("%Y-%m-%d %H:%M:%S", $5)}'`
Depool_Status=`echo "$Depool_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`

Helper_AMOUNT=`echo "$Helper_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
Helper_LAST_TR_TIME=`echo "$Helper_INFO" | grep "last_paid" | gawk -F ":" '{print strftime("%Y-%m-%d %H:%M:%S", $5)}'`
Helper_Status=`echo "$Helper_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`

Proxy0_AMOUNT=`echo "$Proxy0_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
Proxy0_LAST_TR_TIME=`echo "$Proxy0_INFO" | grep "last_paid" | gawk -F ":" '{print strftime("%Y-%m-%d %H:%M:%S", $5)}'`
Proxy0_Status=`echo "$Proxy0_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`

Proxy1_AMOUNT=`echo "$Proxy1_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
Proxy1_LAST_TR_TIME=`echo "$Proxy1_INFO" | grep "last_paid" | gawk -F ":" '{print strftime("%Y-%m-%d %H:%M:%S", $5)}'`
Proxy1_Status=`echo "$Proxy1_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`

Validator_AMOUNT=`echo "$Validator_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
Validator_LAST_TR_TIME=`echo "$Validator_INFO" | grep "last_paid" | gawk -F ":" '{print strftime("%Y-%m-%d %H:%M:%S", $5)}'`
Validator_Status=`echo "$Validator_INFO" | grep "state:" | awk -F "(" '{ print $2 }'`


echo
echo "Time Now: $(date  +'%Y-%m-%d %H:%M:%S')"
echo
echo "Tik_addr: $Tik_addr"
echo "Has Status: $Tik_Status,  balance : $((Tik_AMOUNT/1000000000)) tokens | Last op: $Helper_LAST_TR_TIME"
echo
echo "Depool: $Depool_addr"
echo "Has Status: $Depool_Status,  balance : $((Depool_AMOUNT/1000000000)) tokens | Last op: $Depool_LAST_TR_TIME"
echo
echo "Helper_addr: $Helper_addr"
echo "Has Status: $Helper_Status,  balance : $((Helper_AMOUNT/1000000000)) tokens | Last op: $Helper_LAST_TR_TIME"
echo
echo "Proxy0_addr: $Proxy0_addr"
echo "Has Status: $Proxy0_Status,  balance : $((Proxy0_AMOUNT/1000000000)) tokens | Last op: $Proxy0_LAST_TR_TIME"
echo
echo "Proxy1_addr: $Proxy1_addr"
echo "Has Status: $Proxy1_Status,  balance : $((Proxy1_AMOUNT/1000000000)) tokens | Last op: $Proxy1_LAST_TR_TIME"
echo
echo "Validator_addr: $Validator_addr"
echo "Has Status: $Validator_Status,  balance : $((Validator_AMOUNT/1000000000)) tokens | Last op: $Validator_LAST_TR_TIME"
echo
# "${SCRIPT_DIR}/Send_msg_toTelBot.sh" "$HOSTNAME Server" "Current balance: $((AMOUNT/1000000000))" 2>&1 > /dev/null
echo "=================================================================================================="


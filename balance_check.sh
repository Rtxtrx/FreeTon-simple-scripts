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

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

MY_ACCOUNT=`cat ${KEYS_DIR}/${HOSTNAME}.addr`

ACCOUNT=$1
ACCOUNT=${ACCOUNT:=$MY_ACCOUNT}

BALANCE_INFO=`${UTILS_DIR}/tonos-cli account $ACCOUNT || echo "ERROR get balance" && exit 0`
ACC_STATUS=`echo "$BALANCE_INFO" | grep acc_type | awk '{ print $2 }'`
AMOUNT=`echo "$BALANCE_INFO" | grep balance | awk '{ print $2 }'`
LAST_TR_TIME=`echo "$BALANCE_INFO" | grep last_paid | awk '{ print strftime("%Y-%m-%d %H:%M:%S", $2)}'`

echo
echo "Account: $ACCOUNT"
echo "Status: $ACC_STATUS"
echo "Has balance : $((AMOUNT/1000000000)) tokens"
echo "Last operation time: $LAST_TR_TIME"
echo "=================================================================================================="

exit 0

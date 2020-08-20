#!/bin/bash

# (C) Sergey Tyurin  2020-08-18 19:00:00

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

# tonos-cli deploy <MultisigWallet.tvc> '{"owners":["0x...", ...],"reqConfirms":N}' --abi <MultisigWallet.abi.json> --sign <deploy_seed_or_keyfile> --wc <workchain_id>

SCRIPT_DIR=`cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P`
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

KEY_FILES_DIR="$HOME/DMSKeys"

CALL_LC="${TON_BUILD_DIR}/lite-client/lite-client -p ${KEYS_DIR}/liteserver.pub -a 127.0.0.1:3031 -t 5"

WALL_ADDR=`cat $KEY_FILES_DIR/${HOSTNAME}.addr`
if [[ -z $WALL_ADDR ]];then
    echo
    echo "###-ERROR: Cannot find wallet address in file $KEY_FILES_DIR/${HOSTNAME}.addr"
    echo
    exit 1
fi
echo "Wallet for deploy : $WALL_ADDR"

#=================================================
# Check wallet balance
ACCOUNT_INFO=`$CALL_LC -rc "getaccount ${WALL_ADDR}" -t "3" -rc "quit" 2>/dev/null `
AMOUNT=`echo "$ACCOUNT_INFO" |grep "account balance" | tr -d "ng"|awk '{print $4}'`
ACTUAL_BALANCE=$((AMOUNT / 1000000000))
if [[ $ACTUAL_BALANCE -lt 3 ]];then
    echo "###-ERROR: You haven't enough tokens to deploy wallet. Current balance: $ACTUAL_BALANCE. You need 3 at least. Exit."
    exit 1
fi
#=================================================
# Check numbers of custodians

MSIGs_List=`ls $KEY_FILES_DIR/msig* | tr "\n" " "`
Cust_QTY=`echo $MSIGs_List | awk '{print NF}'`
if [[ $Cust_QTY -lt 3 ]];then
    echo
    echo "###-ERROR: You have to have at least 3 custodians. Found $Cust_QTY only."
    echo
    exit 1
fi
echo "Number of custodians keypairs: $Cust_QTY"

#=================================================
# Read all pubkeys and make a string
Custodians_PubKeys=""
for (( i=1; i<=$Cust_QTY; i++))
do
    PubKey="0x$(cat $KEY_FILES_DIR/msig${i}.keys.json | jq '.public'| tr -d '\"')"
    Custodians_PubKeys+="\"${PubKey}\","
done

Custodians_PubKeys=${Custodians_PubKeys::-1}
echo "Current Custodians_PubKeys: '$Custodians_PubKeys'"

#=================================================
# Deploy wallet

${UTILS_DIR}/tonos-cli deploy \
${CONFIGS_DIR}/SafeMultisigWallet.tvc \
"{\"owners\":[$Custodians_PubKeys],\"reqConfirms\":$Cust_QTY}" \
--abi ${CONFIGS_DIR}/SafeMultisigWallet.abi.json \
--sign $KEY_FILES_DIR/msig1.keys.json \
--wc 0 | tee $KEY_FILES_DIR/deploy_wallet.log

exit 0

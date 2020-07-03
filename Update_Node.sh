#!/bin/bash

# (C) Sergey Tyurin 2020

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

# !!! CHANGE THESE TWO NUMBERS AND CHECK IT TWICE !!!
TON_REV="53ec0dc518f83ebbc07da29f9fb13e6b2b9b3e52"
TONLABS_REV="87de62941411850229b561811d53978da830dab7"

# ==========================================================
echo
echo "### - This script will install new node software! - ###"
echo "### - Tonlabs revision: $TONLABS_REV - ##"
echo "### - TON revision: $TON_REV - ##"
echo "### - CHECK THESE ONES MORE !!! - ##"
read -p "### Are you ABSOLUTELY SHURE to UPGRADE AND RESTART NODE?  (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo "Let's go..."
    ;;
    * )
        echo "Thanks you for attention! Cancelled."
        exit 1
    ;;
esac

WRK_NODE_DIR=$HOME/net.ton.dev
NEW_NODE_DIR=$HOME/upd.node
BKP_OLD_NODE_DIR=$HOME/old.net.ton.dev
# ===============================
# Fetch & build new node
cd $HOME
rm -rf $NEW_NODE_DIR
git clone https://github.com/tonlabs/net.ton.dev $NEW_NODE_DIR
cd $NEW_NODE_DIR
git checkout $TONLABS_REV || echo "### - ERROR: Wrong commit number." || exit 1
cd $NEW_NODE_DIR/scripts

"$NEW_NODE_DIR/scripts/build.sh" || echo "### - ERROR: Build failed." || exit 1

# ===============================
# Check build and commit nums
cd $NEW_NODE_DIR
CURR_TONLABS_REV=`git rev-parse HEAD`
[[ ! "$TONLABS_REV" == "$CURR_TONLABS_REV" ]] && echo "### - Error: Wrong TONLABS(rep: net.ton.dev) revision $CURR_TONLABS_REV! It must to be $TONLABS_REV" && exit 1

cd $NEW_NODE_DIR/ton
CURR_TON_REV=`git rev-parse HEAD`
[[ ! "$TON_REV" == "$CURR_TON_REV" ]] && echo "### - Error: Wrong TON revision $CURR_TON_REV! It must to be $TON_REV" && exit 1
[[ ! -d $NEW_NODE_DIR ]] && echo "## - Error: Can't find updated node dir: '~/upd.node'" && exit 1
[[ ! -x $NEW_NODE_DIR/ton/build/validator-engine/validator-engine ]]  && echo "Can't find builded 'validator-engine'. New node doesnot build?" && exit 1
# ===============================

cd $HOME
mkdir -p $HOME/bin
cp -f $NEW_NODE_DIR/ton/build/lite-client/lite-client $HOME/bin
cp -f $NEW_NODE_DIR/ton/build/utils/tonos-cli $HOME/bin
cp -f $NEW_NODE_DIR/ton/build/validator-engine/validator-engine $HOME/bin
cp -f $NEW_NODE_DIR/ton/build/validator-engine-console/validator-engine-console $HOME/bin

cp -f $HOME/net.ton.dev/scripts/tonlabs-cli.conf.json $NEW_NODE_DIR/scripts/


VAL_PID=`ps -ax | grep "validator\-engine" | awk '{print $1}'`
echo "Engine PID: $VAL_PID"

read -p "### LAST CHANCE! Ready to UPGRADE AND RESTART NODE?  (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo "Killing..."
    ;;
    * )
        echo "Cancelled."
        exit 1
    ;;
esac

kill $VAL_PID

while true
do
    VAL_PID=`ps -ax | grep "validator\-engine" | awk '{print $1}'`
    #echo "### - Node steel works! Engine PID: $VAL_PID"
    if [[ -z $VAL_PID ]]; then
        echo "### Dead!"
	break
    fi
    printf "."
done

# ===========================================
mv -f $WRK_NODE_DIR $BKP_OLD_NODE_DIR
mv -f $NEW_NODE_DIR $WRK_NODE_DIR
echo "INFO: Moved!"
# ===========================================

mkdir -p $HOME/bin
mkdir -p $HOME/logs
cp -f $WRK_NODE_DIR/ton/build/lite-client/lite-client $HOME/bin
cp -f $WRK_NODE_DIR/ton/build/utils/tonos-cli $HOME/bin
cp -f $WRK_NODE_DIR/ton/build/validator-engine/validator-engine $HOME/bin
cp -f $WRK_NODE_DIR/ton/build/validator-engine-console/validator-engine-console $HOME/bin
cp -ur $BKP_OLD_NODE_DIR/scripts/* $WRK_NODE_DIR/scripts

SCRIPT_DIR=$WRK_NODE_DIR/scripts
cd $SCRIPT_DIR
source "${SCRIPT_DIR}/env.sh"

mv -f ${TON_WORK_DIR}/node.log $HOME/logs/

echo "INFO: start NEW node..."

"$HOME/bin/validator-engine" -C "${TON_WORK_DIR}/etc/ton-global.config.json" --db "${TON_WORK_DIR}/db" > "${TON_WORK_DIR}/node.log" 2>&1 &
sleep 2s

VAL_PID=`ps -ax | grep "validator\-engine" | awk '{print $1}'`
echo "Engine PID: $VAL_PID"

echo "INFO: log file = ${TON_WORK_DIR}/node.log"

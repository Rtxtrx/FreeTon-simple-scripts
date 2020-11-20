#!/bin/bash

# !!! `jq` must be installed !!!

GAME_NUM=0
GAM_WEEK=2

POS_AFTER_YOU=10

# ==== put your address here ===
G_ADDR="-1:xxxxxxxxxxxxxxxxxx"

# =====================================
function calc_diff(){
    # 1) var with acc list
    # 2) acc # in list
    CURR_INFO=`echo $1 | jq ".validators[$2]"`
    TBLK=`echo $CURR_INFO | jq ".totalBlocks"  | cut -f1 -d"."`
    SGND=`echo $CURR_INFO | jq ".avSignatures" | cut -f1 -d"."`
    DIFF=$(($TBLK - $SGND))
    echo  "$DIFF"
}
# =====================================

GAME_INFO=`curl -sS -H "Accept: application/json" "https://us-central1-gram-scan.cloudfunctions.net/getContestLeaders?week=${GAM_WEEK}&net=game${GAME_NUM}" | tee game${GAME_NUM}.json`
END_POS=`echo $GAME_INFO|jq ".validators | length"`

# ----- 1st position info -------
G_CURR_1ST=`echo $GAME_INFO | jq ".validators[0]"`
G_TBLK_1ST=`echo $G_CURR_1ST | jq ".totalBlocks"| cut -f1 -d"."`
G_SGND_1ST=`echo $G_CURR_1ST | jq ".avSignatures"| cut -f1 -d"."`
G_LOST_1ST=$(($G_TBLK_1ST - $G_SGND_1ST))
CURR_TD_NOW=`date  +'%Y-%m-%d %H:%M:%S'`
# ------------------------------

G_POS=0
PREV_DIFF=0
while true
do
    MY_G_INFO=`echo $GAME_INFO | jq ".validators[$G_POS]"`
    CURR_ADDR=`echo $MY_G_INFO | jq ".accountId" | tr -d '"'`
    if [[ "$CURR_ADDR" == "null" ]];then
	echo "Acc not found. Sorry."
	break
    fi
    #------------------------------------------
    G_LOST_AB=`calc_diff "$GAME_INFO" "$G_POS"`
    if [[ ! $G_POS == 0 ]]; then
	PREV_DIFF=`calc_diff "$GAME_INFO" "$(($G_POS - 1))"`
    else
	PREV_DIFF=G_LOST_AB
    fi
    printf "g0s - %s - " "$CURR_TD_NOW"
    printf "Pos: %2d  " "$(($G_POS + 1))"
    printf "Lost: %5d  Diff: %4d " "$G_LOST_AB" "$(($G_LOST_AB - $G_LOST_1ST))"
    printf "Above: %3d " "$(($G_LOST_AB - $PREV_DIFF))"
    echo "Addr: ${CURR_ADDR: -4}"
    #------------------------------------------
    if [[ "$CURR_ADDR" == "$G_ADDR" ]]; then
#	echo "$CURR_TD_NOW - G Pos: $(($G_POS + 1))  Lost: $G_LOST_AB .. 1st: $G_LOST_1ST Diff: $(($G_LOST_AB - $G_LOST_1ST))" 
        echo "----------------------------------------------------------------------------------- Me: $(($G_POS + 1))"
	END_POS=$(($G_POS + $POS_AFTER_YOU))
    fi
    [[ $G_POS -gt $END_POS ]] && break
    G_POS=$(($G_POS + 1))
done
echo "=========================================================================================="
exit 0

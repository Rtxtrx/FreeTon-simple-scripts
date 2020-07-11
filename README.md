# FreeTon simple scripts

## 1. ask-return-stake.sh

Do not use this script regullary. It is for emergensy purposes only.

You have to run this script from $HOME/net.ton.dev/script folder!
Check twice that you have right net info in tonlabs-cli.conf.json file in that folder!
You can run this script for other address insted of default in $HOME/ton-keys folder. For that place files <name>.addr and renamed msig.keys.json to <name>.keys.json to script folder and run the script as 

`ask-return-stake.sh <name> `

## 2. Update_Node.sh

Be carefully! Check, change and check again these lines in the script before run it!
### !!! CHANGE THESE TWO NUMBERS AND CHECK IT TWICE !!!

TON_REV="a1fd9e05dc6e6c77cb55d54249e8970c3cff7d1e"

TONLABS_REV="27646a6de9adcb08cb82cb5fd0295ee7695a1a0c"

## 3. resend_stake.sh

This script DOES NOT REPLACMENT of vavidator_msig.sh !!!   
USE validator_msig.sh FIRST!!It is for emergensy purposes only. If default script fiails.
Be carefull. Each try will cost you 1(One) token!

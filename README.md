# FreeTon-simple-scripts

1. ask-return-stake.sh

Do not use this script regullary. It is for emergensy purposes only.

You have to run this script from $HOME/net.ton.dev/script folder!
Check twice that you have right net info in tonlabs-cli.conf.json file in that folder!
You can run this script for other address insted of default in $HOME/ton-keys folder. For that place files <name>.addr and renamed msig.keys.json to <name>.keys.json to script folder and run the script as 

`ask-return-stake.sh <name> `

2. Update_Node.sh

Be carefully! Check, change and check again these lines in the script before run it!
# !!! CHANGE THESE TWO NUMBERS AND CHECK IT TWICE !!!

TON_REV="9186d482981d2a784bcbd3322cf0c09ea8184991"

TONLABS_REV="27784c987b8282af2791ba6efc7a5ecfe544cdb2"

3. resend_stake.sh

It is for emergensy purposes only. If default script fiails.

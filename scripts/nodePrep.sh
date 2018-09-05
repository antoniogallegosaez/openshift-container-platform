#!/bin/bash
echo $(date) " - Starting Infra / Node Prep Script"

USERNAME_ORG=$1
PASSWORD_ACT_KEY="$2"
POOL_ID=$3

# Remove RHUI

rm -f /etc/yum.repos.d/rh-cloud.repo
sleep 10

# Register Host with Cloud Access Subscription
echo $(date) " - Register host with Cloud Access Subscription"

subscription-manager register --username="$USERNAME_ORG" --password="$PASSWORD_ACT_KEY" || subscription-manager register --activationkey="$PASSWORD_ACT_KEY" --org="$USERNAME_ORG"

if [ $? -eq 0 ]
then
    echo "Subscribed successfully"
elif [ $? -eq 64 ]
then
    echo "This system is already registered."
else
    echo "Incorrect Username / Password or Organization ID / Activation Key specified"
    exit 3
fi

subscription-manager attach --pool=$POOL_ID > attach.log
if [ $? -eq 0 ]
then
    echo "Pool attached successfully"
else
    evaluate=$( cut -f 2-5 -d ' ' attach.log )
    if [[ $evaluate == "unit has already had" ]]
    then
        echo "Pool $POOL_ID was already attached and was not attached again."
    else
        echo "Incorrect Pool ID or no entitlements available"
        exit 4
    fi
fi

echo $(date) " - Script Complete"


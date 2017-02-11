#!/bin/bash

read -p "Password for root user: " ROOT_PASSWORD

read -p "Do you want to use custom network? (y/n) " yn
case $yn in
    [Yy]* )
            read -p "Custom network name : " CUSTOMNETWORKNAME
	    LOCALNETWORK_IP=$(docker network inspect \
		${CUSTOMNETWORKNAME} | grep Subnet | sed 's/\"//g' | cut -d: -f2 | cut -d/ -f1)
	    MASK_LEN=$(docker network inspect \
                ${CUSTOMNETWORKNAME} | grep Subnet | sed 's/\"//g' | cut -d/ -f2 | cut -d, -f1)
	    if [ ! -z $CUSTOMNETWORKNAME ]; then CUSTOMNETWORKNAME=--net=${CUSTOMNETWORKNAME}; fi
            ;;
        * ) CUSTOMNETWORKNAME=
            ;;
esac

if [ -z LOCALNETWORK_IP ]; then
    read -p "Local network IP address for Postfix: " LOCALNETWORK_IP
fi
if [ -z MASK_LEN ]; then
    read -p "Local network Mask length Postfix: " MASK_LEN
fi
 
read -p "Other network to accept mail from (ip-address/masklen):" OTHERNETWORK

read -p "Relay host (ip-address or host-name): " RELAYHOST
read -p "Username for Relayhost: " RELAYUSER
read -p "Password for ${RELAYUSER}:" RELAYUSERPASSWORD

read -p "Fixed ip-address for postfix server: " FIXED_IP_ADDRESS
if [ -z $FIXED_IP_ADDRESS ]; then
    FIXED_IP_ADDRESS=
else
    FIXED_IP_ADDRESS=--ip=${FIXED_IP_ADDRESS}
fi

#docker rm postfix
docker run \
	-h postfix \
	-e LOCALNETWORK="${LOCALNETWORK_IP}/${MASK_LEN}" \
	-e OTHERNETWORK="${OTHERNETWORK}" \
	-e ROOT_PASSWORD="${ROOT_PASSWORD}" \
	-e RELAYHOST="${RELAYHOST}" \
	-e RELAYUSER="${RELAYUSER}" \
	-e RELAYUSERPASSWORD="${RELAYUSERPASSWORD}" \
	--name postfix \
	-h postfix \
	${CUSTOMNETWORKNAME} \
	${FIXED_IP_ADDRESS} \
	-p 25:25 \
	-d tgiesela/postfix:v0.1



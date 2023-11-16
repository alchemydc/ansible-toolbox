#!/bin/bash

KEYNAME=$1
PRIVATEKEY=$2

# show usage instructions if no params passed
if [ -z "$KEYNAME" ] || [ -z "$PRIVATEKEY" ]; then
    echo "Usage: $0 <keyname> <privatekey>"
    exit 1
fi

echo "Importing ecdsa operator key: $KEYNAME"
eigenlayer operator keys import --key-type ecdsa $KEYNAME $PRIVATEKEY

echo "Importing bls operator key: $KEYNAME"
eigenlayer operator keys import --key-type bls $KEYNAME $PRIVATEKEY


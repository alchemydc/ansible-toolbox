#!/bin/bash

KEYNAME=$1

# show usage instructions if no params passed
if [ -z "$KEYNAME" ]; then
    echo "Usage: $0 <keyname>"
    exit 1
fi

echo "Creating ecdsa operator key: $KEYNAME"
eigenlayer operator keys create --key-type ecdsa $KEYNAME

echo "Creating bls operator key: $KEYNAME"
eigenlayer operator keys create --key-type bls $KEYNAME


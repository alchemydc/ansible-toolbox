#!/bin/bash

echo "Registering operator"
echo "Note, this will fail unless there is some ETH in the operator account on the network you're registering to"
eigenlayer operator register ~/.eigenlayer/operator-config.yml

echo "Checking status of operator"
eigenlayer operator status ~/.eigenlayer/operator-config.yml

echo "To update the operator config, run:"
echo "eigenlayer operator update ~/.eigenlayer/operator-config.yml"

echo "See the updated docs for help:"
echo "https://docs.eigenlayer.xyz/operator-guides/operator-installation"




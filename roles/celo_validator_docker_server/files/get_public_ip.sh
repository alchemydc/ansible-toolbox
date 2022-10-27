#!/bin/bash
set -ex

echo "PUBLIC_IP=$(curl -s 'http://icanhazip.com')"

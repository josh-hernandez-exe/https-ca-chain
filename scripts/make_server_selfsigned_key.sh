#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Self Signed Server Key"
echo "#######################"

# This makes it easy to make multiple client certs
server_index="bad"
server_private_key="server/private/server$server_index-key.pem"
server_cert="server/certs/server$server_index-key.cert.pem"
server_chain="server/certs/server$server_index-chain.cert.pem"

## Create Key for self signed cert
openssl genrsa -out $server_private_key

## Create Certificate
openssl req \
    -config intermediate/openssl.cnf \
    -key $server_private_key \
    -new -x509 -days 7300 -sha256 -extensions usr_cert \
    -out $server_cert

cp $server_cert $server_chain
cd $previous_dir

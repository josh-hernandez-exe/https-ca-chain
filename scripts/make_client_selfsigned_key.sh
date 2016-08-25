#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Self Signed Client Key"
echo "#######################"

# This makes it easy to make multiple client certs

cd $project_root

client_index="bad"

client_name="client$client_index-key"
client_private_key="client/private/$client_name.pem"
client_cert="client/certs/$client_name.cert.pem"
client_chain="client/certs/$client_name.chain.cert.pem"


## Create Key for self signed cert
openssl genrsa -out $client_private_key

## Create Certificate
openssl req \
    -config intermediate/openssl.cnf \
    -key $client_private_key \
    -new -x509 -days 7300 -sha256 -extensions usr_cert \
    -out $client_cert

cp $client_cert $client_chain
cd $previous_dir

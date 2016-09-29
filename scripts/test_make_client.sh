#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root

# This makes it easy to make multiple client certs
client_index=""
if [[ $1 -ne "" ]];then
    client_index=$1
fi

source scripts/load_vars.sh

echo "#######################"
echo "Create Client $client_index Key"
echo "#######################"

echo "[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
prompt                 = no
x509_extensions        = v3_ca

[ req_distinguished_name ]
C                      = US
ST                     = MA
L                      = Boston
O                      = Example Co
OU                     = techops
CN                     = $client_common_name
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password

[ v3_ca ]
authorityInfoAccess = @issuer_info
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ issuer_info ]
OCSP;URI.0 = http://ocsp.example.com/
caIssuers;URI.0 = http://example.com/ca.cert
" > $client_config

openssl genrsa -out $client_key 4096
# chmod 400 $client_key

openssl req -new \
    -config $client_config \
    -key $client_key \
    -out $client_csr

openssl x509 -req \
    -extfile $client_config \
    -days 999 \
    -passin "pass:password" \
    -in $client_csr \
    -CA $intermediate_cert_chain \
    -CAkey $intermediate_key \
    -CAcreateserial \
    -out $client_cert

# chmod 444 $client_cert

cat $client_cert $intermediate_cert_chain > $client_chain

echo "Client Key Creation Complete"
cd $previous_dir

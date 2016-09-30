#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root

echo "#######################"
echo "Create Self Signed Server Key"
echo "#######################"

server_index="bad"
if [[ $1 -ne "" ]];then
	server_index=$1
fi

source scripts/catch_errors.sh
source scripts/load_vars.sh

echo "[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
output_password        = password
prompt                 = no
x509_extensions        = v3_ca

[ req_distinguished_name ]
C                      = XX
ST                     = YY
L                      = Somecity
O                      = Example Co
OU                     = Example Team
CN                     = localhost
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password

[ v3_ca ]
authorityInfoAccess = @issuer_info

[ issuer_info ]
OCSP;URI.0 = http://ocsp.example.com/
caIssuers;URI.0 = http://example.com/ca.cert
" > $server_config


# Create Key and Certificate

catch openssl req -new -x509 \
    -days 9999 \
    -config $server_config \
    -keyout $server_key \
    -out $server_cert

cp $server_cert $server_chain
cd $previous_dir

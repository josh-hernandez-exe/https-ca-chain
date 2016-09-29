#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Server Key"
echo "#######################"

cd $project_root

# This makes it easy to make multiple server certs
server_index=""
if [[ $1 -ne "" ]];then
	server_index=$1
fi

source scripts/load_vars.sh

echo "[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
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



# Create Key
openssl genrsa -out $server_key 4096
chmod 400 $server_private_key

# Generate Certificate Signing Request
openssl req -new \
    -config $server_config \
    -key $server_key \
    -out $server_csr

# Process the CSR
# Note that the following is done as if it was on machine of the intermediate key
openssl x509 -req \
    -extfile $server_config \
    -days 999 \
    -in $server_csr \
    -CA $intermediate_cert \
    -CAkey $intermediate_key \
    -CAcreateserial \
    -out $server_cert \
    $passin_string

chmod 444 $server_cert

### Verify Intermediate Certificate Info
openssl verify -CAfile $intermediate_cert_chain $server_cert

# Create Cerfificate Chain
cat $server_cert $intermediate_cert_chain > $server_chain
chmod 444 $server_chain

echo "Server Key Creation Complete"
cd $previous_dir

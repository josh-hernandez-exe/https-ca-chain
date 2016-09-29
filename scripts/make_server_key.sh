#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Server Key"
echo "#######################"

cd $project_root

server_index=""
parent_type="intermediate"

while [[ $# -gt 0 ]]; do
key="$1"
value="$2"
case $key in

    --debug)
      set -x
    ;;

    --name)
    # This makes it easy to make multiple server certs
      server_index="$value"
      shift
    ;;

    --parent-type)
      parent_type="$value"
      shift
    ;;

esac
shift
done

source scripts/load_vars.sh

if [ "$parent_cert" == "" ];then
    exit 1;
fi

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
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, emailProtection

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
    -CA $parent_cert \
    -CAkey $parent_key \
    -CAcreateserial \
    -out $server_cert \
    $passin_string

chmod 444 $server_cert

### Verify Intermediate Certificate Info
openssl verify -CAfile $parent_cert $server_cert

# Create Cerfificate Chain
cat $server_cert $parent_cert_chain > $server_chain
chmod 444 $server_chain

echo "Server Key Creation Complete"
cd $previous_dir

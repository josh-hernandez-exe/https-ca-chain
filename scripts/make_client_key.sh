#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root

# This makes it easy to make multiple client certs

client_prefix="client"
client_index=""
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
      client_index="$value"
      shift
    ;;

    --parent-type)
      parent_type="$value"
      shift
    ;;

    --prefix)
      client_prefix="$value"
      shift
    ;;

esac
shift
done

source scripts/catch_errors.sh
source scripts/load_vars.sh

if [ "$parent_cert" == "" ];then
    exit 1;
fi




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
OU                     = Example Team
CN                     = $client_common_name
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
authorityInfoAccess = @issuer_info
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ issuer_info ]
OCSP;URI.0 = http://ocsp.example.com/
caIssuers;URI.0 = http://example.com/ca.cert
" > $client_config

catch openssl genrsa -out $client_key 4096
chmod 400 $client_key

catch openssl req -new \
    -config $client_config \
    -key $client_key \
    -out $client_csr

catch openssl x509 -req \
    -extfile $client_config \
    -extensions "v3_ca" \
    -days 999 \
    $passin_string \
    -in $client_csr \
    -CA $parent_cert \
    -CAkey $parent_key \
    -CAcreateserial \
    -out $client_cert

chmod 444 $client_cert

cat $client_cert $parent_cert_chain > $client_chain

### Verify Certificate Info
catch openssl verify -CAfile $parent_cert_chain $client_cert

echo "Client Key Creation Complete"
cd $previous_dir

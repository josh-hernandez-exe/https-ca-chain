#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Intermediate Key"
echo "#######################"

cd $project_root
source scripts/load_vars.sh

echo "[ ca ]
default_ca      = CA_default

[ CA_default ]
dir              = $project_root/intermediate
serial           = \$dir/intermediate.serial
crl              = \$dir/intermediate.crl.pem
database         = \$dir/intermediate.database.txt
name_opt         = CA_default
cert_opt         = CA_default
default_crl_days = 9999
default_md       = sha256

[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
prompt                 = no
output_password        = password

[ req_distinguished_name ]
C                      = XX
ST                     = YY
L                      = Somecity
O                      = Example Co
OU                     = Example Team
CN                     = Intermediate
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = test
" > $intermediate_config





# Create Key
openssl genrsa -out $intermediate_key 4096
# openssl genrsa -aes256 -out $intermediate_key 4096

chmod 400 $intermediate_key

# Generate Certificate Signing Request
openssl req -new \
    -config $intermediate_config \
    -key $intermediate_key \
    -out $intermediate_csr

# Process the CSR
# Note that the following is done as if it was on machine of the master key

openssl x509 -req \
    -extfile $intermediate_config \
    -days 999 \
    -passin "pass:password" \
    -in $intermediate_csr \
    -CA $master_cert \
    -CAkey $master_key \
    -CAcreateserial \
    -out $intermediate_cert



chmod 444 $intermediate_cert

### Verify Intermediate Certificate Info based off Master
openssl verify -CAfile $master_cert $intermediate_cert

# Create Cerfificate Chain
cat $intermediate_cert $master_cert > $intermediate_cert_chain
chmod 444 $intermediate_cert_chain

# Our certificate chain file must include the root certificate because no client application knows about it yet. 
# A better option, particularly if you’re administrating an intranet, is to install your root certificate on every client that needs to connect. 
# In that case, the chain file need only contain your intermediate certificate.

touch $intermediate_database

# create certificate revokation list
if [ ! -f $intermediate_crl ]; then
    openssl ca \
        -keyfile $intermediate_key \
        -cert $intermediate_cert \
        -config $intermediate_config \
        -gencrl \
        -out $intermediate_crl \
        -passin "pass:password"
fi

echo "Intermediate Key Creation Complete"
cd $previous_dir

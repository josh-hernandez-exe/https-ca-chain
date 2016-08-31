#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Intermediate Key"
echo "#######################"

## Prepare Directory
cd $project_root
mkdir intermediate
cd intermediate
mkdir certs crl csr newcerts private
cd ..

chmod 700 intermediate/private

touch intermediate/index.txt

echo 1000 > intermediate/serial
# crlnumber is used to keep track of certificate revocation lists.
echo 1000 > intermediate/crlnumber


intermediate_config_file="intermediate/openssl.cnf"
intermediate_key_file="intermediate/private/intermediate.key.pem"
intermediate_cert_file="intermediate/certs/intermediate.cert.pem"
intermediate_csr_file="intermediate/csr/intermediate.csr.pem"
intermediate_crl_file="intermediate/crl/intermediate.crl.pem"

if [ ! -f $intermediate_config_file ]; then
    bash "scripts/make_configs.sh"
fi


# Create Key
openssl genrsa -aes256 \
    -out $intermediate_key_file 4096 # anotherpassword
chmod 400 $intermediate_key_file

# Generate Certificate Signing Request
openssl req \
    -config $intermediate_config_file -new -sha256 \
    -key $intermediate_key_file \
    -out $intermediate_csr_file

# Process the CSR
# Note that the following is done as if it was on machine of the master key

openssl x509 -req -days 999 \
    -extfile master/openssl.cnf \
    -in $intermediate_csr_file \
    -extensions v3_intermediate_ca \
    -CA master/certs/ca.cert.pem \
    -CAkey master/private/ca.key.pem \
    -CAcreateserial \
    -out $intermediate_cert_file

chmod 444 $intermediate_cert_file

### View intermediate Certificate Info
openssl x509 -noout -text -in $intermediate_cert_file

### Verify Intermediate Certificate Info based off Master
openssl verify -CAfile master/certs/ca.cert.pem $intermediate_cert_file

# Create Cerfificate Chain
cat $intermediate_cert_file master/certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

# Our certificate chain file must include the root certificate because no client application knows about it yet. 
# A better option, particularly if you’re administrating an intranet, is to install your root certificate on every client that needs to connect. 
# In that case, the chain file need only contain your intermediate certificate.

# create certificate revokation list
if [ ! -f $intermediate_crl_file ]; then
    openssl ca \
        -config $intermediate_config_file \
        -gencrl \
        -out $intermediate_crl_file
fi

echo "Intermediate Key Creation Complete"
cd $previous_dir

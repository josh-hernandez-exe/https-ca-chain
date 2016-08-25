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

# Create Key
openssl genrsa -aes256 \
    -out intermediate/private/intermediate.key.pem 4096 # anotherpassword
chmod 400 intermediate/private/intermediate.key.pem

# Generate Certificate Signing Request
openssl req \
    -config intermediate/openssl.cnf -new -sha256 \
    -key intermediate/private/intermediate.key.pem \
    -out intermediate/csr/intermediate.csr.pem

# Process the CSR
# Note that the following is done as if it was on machine of the master key
openssl ca \
    -config master/openssl.cnf \
    -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 \
    -in intermediate/csr/intermediate.csr.pem \
    -out intermediate/certs/intermediate.cert.pem

chmod 444 intermediate/certs/intermediate.cert.pem

### View intermediate Certificate Info
openssl x509 -noout -text -in intermediate/certs/intermediate.cert.pem

### Verify Intermediate Certificate Info based off Master
openssl verify -CAfile master/certs/ca.cert.pem intermediate/certs/intermediate.cert.pem

# Create Cerfificate Chain
cat intermediate/certs/intermediate.cert.pem master/certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
chmod 444 intermediate/certs/ca-chain.cert.pem

# Our certificate chain file must include the root certificate because no client application knows about it yet. 
# A better option, particularly if you’re administrating an intranet, is to install your root certificate on every client that needs to connect. 
# In that case, the chain file need only contain your intermediate certificate.


# create certificate revokation list
if [ ! -f intermediate/crl/intermediate.crl.pem ]; then
	openssl ca -config intermediate/openssl.cnf -gencrl -out intermediate/crl/intermediate.crl.pem
fi


echo "Intermediate Key Creation Complete"
cd $previous_dir

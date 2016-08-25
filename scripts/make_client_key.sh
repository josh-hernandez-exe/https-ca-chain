#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Client Key"
echo "#######################"

## Prepare Directory
cd $project_root
mkdir client
cd client
mkdir certs private csr
cd ..
chmod 700 client/private

# This makes it easy to make multiple client certs
client_index=""
if [[ $1 -ne "" ]];then
	client_index=$1
fi

client_name="client$client_index-key"
client_private_key="client/private/$client_name.pem"
client_csr="client/csr/$client_name.csr.pem"
client_cert="client/certs/$client_name.cert.pem"
client_chain="client/certs/$client_name.chain.cert.pem"

# # Create Key
openssl genrsa -out $client_private_key 2048
chmod 400 $client_private_key

# # Generate Certificate Signing Request
# # Note that we use the same config as intermediate for convience
openssl req \
    -config intermediate/openssl.cnf \
    -key $client_private_key \
    -new -sha256 \
    -out $client_csr


# # Process the CSR
# # Note that the following is done as if it was on machine of the intermediate key
openssl ca \
    -config intermediate/openssl.cnf \
    -extensions usr_cert -days 375 -notext -md sha256 \
    -in $client_csr \
    -out $client_cert
chmod 444 $client_cert


# # View the certificate
openssl x509 -noout -text -in $client_cert

# ### Verify Intermediate Certificate Info based off intermediate
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem $client_cert

# Create Cerfificate Chain
cat $client_cert intermediate/certs/ca-chain.cert.pem > $client_chain
chmod 444 $client_chain

echo "Client Key Creation Complete"
cd $previous_dir

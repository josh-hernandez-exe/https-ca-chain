#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Server Key"
echo "#######################"

## Prepare Directory
cd $project_root
mkdir server
cd server
mkdir certs private csr
cd ..
chmod 700 server/private


# This makes it easy to make multiple server certs
server_index=""
if [[ $1 -ne "" ]];then
	server_index=$1
fi


server_name="server$server_index-key"

server_private_key="server/private/$server_name.pem"
server_csr="server/csr/$server_name.csr.pem"
server_cert="server/certs/$server_name.cert.pem"
server_chain="server/certs/$server_name.chain.cert.pem"

# Create Key
openssl genrsa -out $server_private_key 2048
chmod 400 $server_private_key

# Generate Certificate Signing Request
# Note that we use the same config as intermediate for convience
echo "NOTE: Common Name must be the same as the hostname (\"localhost\" for dev)"
openssl req -config intermediate/openssl.cnf \
    -key $server_private_key \
    -new -sha256 \
    -out $server_csr


# Process the CSR
# Note that the following is done as if it was on machine of the intermediate key
openssl ca -config intermediate/openssl.cnf \
      -extensions server_cert -days 375 -notext -md sha256 \
      -in $server_csr \
      -out $server_cert

if [ $? -ne 0 ];then
	exit 1;
fi

chmod 444 $server_cert

# View the certificate
openssl x509 -noout -text -in $server_cert

### Verify Intermediate Certificate Info based off intermediate
openssl verify -CAfile intermediate/certs/ca-chain.cert.pem $server_cert


# Create Cerfificate Chain
cat $server_cert intermediate/certs/ca-chain.cert.pem > $server_chain
chmod 444 $server_chain

echo "Server Key Creation Complete"
cd $previous_dir

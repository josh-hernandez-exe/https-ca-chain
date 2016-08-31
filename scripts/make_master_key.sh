#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Master Key"
echo "#######################"

## Prepare Directory
cd $project_root
mkdir master
cd master
mkdir certs crl newcerts private
cd ..
chmod 700 master/private

touch master/private/.rand
touch master/index.txt

echo 1000 > master/serial
# crlnumber is used to keep track of certificate revocation lists.
echo 1000 > master/crlnumber

master_config_file="master/openssl.cnf"
master_private_key="master/private/ca.key.pem"
master_cert_file="master/certs/ca.cert.pem"

if [ ! -f $master_config_file ]; then
	bash "scripts/make_configs.sh"
fi

## Create Master Key, with a password
openssl genrsa -aes256 -out $master_private_key 4096  # testpassword
chmod 400 master/private/ca.key.pem

## Create Root Certificate
openssl req -config $master_config_file \
    -key $master_private_key \
    -extensions v3_ca \
    -new -x509 -days 7300 -sha256 \
    -out $master_cert_file

chmod 444 $master_cert_file

### View Root Certificate Info
openssl x509 -noout -text -in $master_cert_file

echo "Master Key Creation Complete"
cd $previous_dir

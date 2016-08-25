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

## Create Master Key, with a password
openssl genrsa -aes256 -out master/private/ca.key.pem 4096  # testpassword
chmod 400 master/private/ca.key.pem

## Create Root Certificate
openssl req -config master/openssl.cnf \
    -key master/private/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -out master/certs/ca.cert.pem

chmod 444 master/certs/ca.cert.pem

### View Root Certificate Info
openssl x509 -noout -text -in master/certs/ca.cert.pem

echo "Master Key Creation Complete"
cd $previous_dir

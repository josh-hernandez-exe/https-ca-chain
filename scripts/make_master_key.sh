#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Master Key"
echo "#######################"

cd $project_root
source scripts/catch_errors.sh
source scripts/load_vars.sh

echo "[ ca ]
default_ca      = CA_default

[ CA_default ]
dir              = $project_root/master
serial           = \$dir/master.serial
crl              = \$dir/master.crl.pem
database         = \$dir/master.database.txt
name_opt         = CA_default
cert_opt         = CA_default
default_crl_days = 9999
default_md       = sha256
x509_extensions  = v3_ca

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
CN                     = master
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = test

[ v3_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
" > $master_config

catch openssl req -new -x509 \
    -days 9999 \
    -config $master_config \
    -keyout $master_key \
    -out $master_cert

# Add a passphrase to an existing private key
# http://security.stackexchange.com/questions/59136/can-i-add-a-password-to-an-existing-private-key

# openssl rsa -des3 -in $master_key -out $master_key.temp
# mv $master_key.temp $master_key
# rm $master_key.temp

touch $master_database

# create certificate revokation list
if [ ! -f $master_crl ]; then
    catch openssl ca \
        -keyfile $master_key \
        -cert $master_cert \
        -config $master_config \
        -gencrl \
        -out $master_crl \
        -passin "pass:password"
fi

echo "Master Key Creation Complete"

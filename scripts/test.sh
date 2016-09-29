#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root


mkdir master
mkdir master/private
mkdir master/certs
mkdir master/csr
mkdir master/crl

mkdir intermediate
mkdir intermediate/private
mkdir intermediate/certs
mkdir intermediate/csr
mkdir intermediate/crl

mkdir server
mkdir server/private
mkdir server/certs
mkdir server/csr
mkdir server/crl

mkdir client
mkdir client/private
mkdir client/certs
mkdir client/csr
mkdir client/crl



# bash scripts/make_dirs.sh

source scripts/load_vars.sh

echo "[ ca ]
default_ca      = CA_default

[ CA_default ]
serial           = $project_root/$master_serial
crl              = $project_root/$master_crl
database         = $project_root/$master_database
name_opt         = CA_default
cert_opt         = CA_default
default_crl_days = 9999
default_md       = md5

[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
prompt                 = no
output_password        = password

[ req_distinguished_name ]
C                      = US
ST                     = MA
L                      = Boston
O                      = Example Co
OU                     = techops
CN                     = master
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password
" > $master_config

echo "[ ca ]
default_ca      = CA_default

[ CA_default ]
serial           = $project_root/$intermediate_serial
crl              = $project_root/$intermediate_crl
database         = $project_root/$intermediate_database
name_opt         = CA_default
cert_opt         = CA_default
default_crl_days = 9999
default_md       = md5

[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
prompt                 = no
output_password        = password

[ req_distinguished_name ]
C                      = US
ST                     = MA
L                      = Boston
O                      = Example Co
OU                     = techops
CN                     = intermediate
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password
" > $intermediate_config

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
OU                     = techops
CN                     = localhost
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password

[ v3_ca ]
authorityInfoAccess = @issuer_info

[ issuer_info ]
OCSP;URI.0 = http://ocsp.example.com/
caIssuers;URI.0 = http://example.com/ca.cert
" > $server_config

# Make master key and certificate

openssl req -new -x509 \
    -days 9999 \
    -config $master_config \
    -keyout $master_key \
    -out $master_cert

# Intermediate

# openssl req -new -x509 \
#     -days 9999 \
#     -config $intermediate_config \
#     -keyout $intermediate_key \
#     -out $intermediate_cert

openssl genrsa -out $intermediate_key 4096

openssl req -new \
    -config $intermediate_config \
    -key $intermediate_key \
    -out $intermediate_csr

openssl x509 -req \
    -extfile $intermediate_config \
    -days 999 \
    -passin "pass:password" \
    -in $intermediate_csr \
    -CA $master_cert \
    -CAkey $master_key \
    -CAcreateserial \
    -out $intermediate_cert

cat $intermediate_cert $master_cert > $intermediate_cert_chain

# Server

openssl genrsa -out $server_key 4096
openssl req -new \
    -config $server_config \
    -key $server_key \
    -out $server_csr

openssl x509 -req \
    -extfile $server_config \
    -days 999 \
    -passin "pass:password" \
    -in $server_csr \
    -CA $intermediate_cert \
    -CAkey $intermediate_key \
    -CAcreateserial \
    -out $server_cert

cat $server_cert $intermediate_cert_chain > $server_chain

# Client

bash scripts/test_make_client.sh
bash scripts/test_make_client.sh 1
bash scripts/test_make_client.sh 2

# bash scripts/validate_certificates.sh

touch $intermediate_database

cert_to_revoke="client/certs/client2.cert.pem"

openssl ca \
   -revoke $cert_to_revoke \
   -keyfile $intermediate_key \
   -config $intermediate_config \
   -cert $intermediate_cert \
   -passin "pass:password"

openssl ca \
    -keyfile $intermediate_key \
    -cert $intermediate_cert \
    -config $intermediate_config \
    -gencrl \
    -out $intermediate_crl \
    -passin "pass:password"

cd $previous_dir

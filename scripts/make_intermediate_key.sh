#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Intermediate Key"
echo "#######################"

cd $project_root
source scripts/catch_errors.sh
source scripts/load_vars.sh

tmp_int_ext_file="/tmp/intermediate_extensions.txt"

echo "[ v3_int_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
" > $tmp_int_ext_file

echo "[ ca ]
default_ca      = CA_default

[ CA_default ]
dir              = $project_root/intermediate
new_certs_dir    = \$dir/certs
database         = $intermediate_database
serial           = $intermediate_serial
crl              = $intermediate_crl
private_key      = $intermediate_key
certificate      = $intermediate_cert
name_opt         = CA_default
cert_opt         = CA_default
default_crl_days = 9999
default_md       = sha256
policy           = policy_anything

[ policy_anything ]
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
prompt                 = no
output_password        = password
x509_extensions        = v3_int_ca

[ req_distinguished_name ]
C                      = XX
ST                     = YY
L                      = Somecity
O                      = Example Co
OU                     = Example Team
CN                     = intermediate
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password

$(cat $tmp_int_ext_file)
" > $intermediate_config

# Create Key
catch openssl genrsa -out $intermediate_key 4096
# openssl genrsa -aes256 -out $intermediate_key 4096

chmod 400 $intermediate_key

# Generate Certificate Signing Request
catch openssl req -new \
    -config $intermediate_config \
    -key $intermediate_key \
    -out $intermediate_csr


# tmp_config="/tmp/ca.conf"
# cat $master_config $tmp_int_ext_file > $tmp_config

# Process the CSR
# Note that the following is done as if it was on machine of the master key
    # -config $tmp_config
catch openssl ca \
    -batch \
    -config <(cat $master_config $tmp_int_ext_file) \
    -extensions v3_int_ca \
    -days 999 \
    -notext \
    -md sha256 \
    -create_serial \
    -in $intermediate_csr \
    -out $intermediate_cert \
    $passin_string

# catch openssl x509 -req \
#     -extfile $intermediate_config \
#     -extensions "v3_int_ca" \
#     -days 999 \
#     -in $intermediate_csr \
#     -CA $master_cert \
#     -CAkey $master_key \
#     -CAcreateserial \
#     -out $intermediate_cert \
#     $passin_string


chmod 444 $intermediate_cert

### Verify Intermediate Certificate Info based off Master
catch openssl verify -CAfile $master_cert $intermediate_cert

# Create Cerfificate Chain
cat $master_cert $intermediate_cert > $intermediate_cert_chain
chmod 444 $intermediate_cert_chain

# Our certificate chain file must include the root certificate because no client application knows about it yet.
# A better option, particularly if you’re administrating an intranet, is to install your root certificate on every client that needs to connect.
# In that case, the chain file need only contain your intermediate certificate.

touch $intermediate_database
touch "$intermediate_database.attr"
echo "01" > $intermediate_serial

# create certificate revokation list
if [ ! -f $intermediate_crl ]; then
    catch openssl ca \
        -keyfile $intermediate_key \
        -cert $intermediate_cert \
        -config $intermediate_config \
        -gencrl \
        -out $intermediate_crl \
        -passin "pass:password"
fi

echo "Intermediate Key Creation Complete"
cd $previous_dir

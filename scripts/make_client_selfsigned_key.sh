#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Create Self Signed Client Key"
echo "#######################"

# This makes it easy to make multiple client certs

cd $project_root

client_index="bad"
if [[ $1 -ne "" ]];then
	client_index=$1
fi

source scripts/load_vars.sh

echo "[ req ]
default_bits           = 4096
days                   = 9999
distinguished_name     = req_distinguished_name
attributes             = req_attributes
output_password        = password
prompt                 = no

[ req_distinguished_name ]
C                      = XX
ST                     = YY
L                      = Somecity
O                      = Example Co
OU                     = Example Team
CN                     = $client_common_name
emailAddress           = certs@example.com

[ req_attributes ]
challengePassword      = password
" > $client_config


# Create Key and Certificate

openssl req -new -x509 \
    -days 9999 \
    -config $client_config \
    -keyout $client_key \
    -out $client_cert \

exit

cp $client_cert $client_chain
cd $previous_dir

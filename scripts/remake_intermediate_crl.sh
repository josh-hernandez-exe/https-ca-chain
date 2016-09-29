#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root
source scripts/load_vars.sh

echo "#######################"
echo "Remake Intermediate CRL"
echo "#######################"

rm $intermediate_crl
openssl ca \
    -keyfile $intermediate_key \
    -cert $intermediate_cert \
    -config $intermediate_config \
    -gencrl \
    -out $intermediate_crl \
    $passin_string

# View CRL
openssl crl -text -noout -in $intermediate_crl
cd $previous_dir

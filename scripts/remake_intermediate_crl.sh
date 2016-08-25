#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Remake Intermediate CRL"
echo "#######################"

intermediate_crl_path="$project_root/intermediate/crl/intermediate.crl.pem"

rm $intermediate_crl_path
openssl ca \
    -config $project_root/intermediate/openssl.cnf \
    -gencrl -out $intermediate_crl_path

# View CRL
openssl crl -text -noout -in $intermediate_crl_path
cd $previous_dir

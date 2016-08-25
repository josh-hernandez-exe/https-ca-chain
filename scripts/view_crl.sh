#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

intermediate_crl_path="$project_root/intermediate/crl/intermediate.crl.pem"

# View CRL
openssl crl -text -noout -in $intermediate_crl_path
cd $previous_dir

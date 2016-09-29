#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root
source scripts/load_vars.sh

# View CRL
openssl crl -text -noout -in $intermediate_crl
cd $previous_dir

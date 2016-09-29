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

chmod 700 master/private

mkdir intermediate
mkdir intermediate/private
mkdir intermediate/certs
mkdir intermediate/csr
mkdir intermediate/crl

chmod 700 intermediate/private

mkdir server
mkdir server/private
mkdir server/certs
mkdir server/csr
mkdir server/crl

chmod 700 server/private

mkdir client
mkdir client/private
mkdir client/certs
mkdir client/csr
mkdir client/crl

chmod 700 client/private

cd $previous_dir
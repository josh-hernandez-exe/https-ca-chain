#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cert_file_to_verify=$1

if [ ! -f $cert_file_to_verify ]; then
	echo "Enter a file location for the certificate file that you want to validate"
	exit 1;
fi

openssl verify -CAfile intermediate/certs/ca-chain.cert.pem -CRLfile intermediate/crl/intermediate.crl.pem -crl_check $cert_file_to_verify
cd $previous_dir

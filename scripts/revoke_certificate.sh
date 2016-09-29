#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root
source scripts/load_vars.sh

echo "#######################"
echo "Revoke Certificate"
echo "#######################"

cert_to_revoke=$1

if [ ! -f $cert_to_revoke ]; then
	echo "Enter a file location for the certificate file that you want to revoke"
	exit 1;
fi

openssl ca \
   -revoke $cert_to_revoke \
   -keyfile $intermediate_key \
   -config $intermediate_config \
   -cert $intermediate_cert \
   $passin_string

echo "Remake the certificate revocation list"
bash "$parent_path/remake_intermediate_crl.sh"

echo "Certificate Revocation Completed: $cert_to_revoke"

#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Revoke Certificate"
echo "#######################"

cert_file_to_revoke=$1

if [ ! -f $cert_file_to_revoke ]; then
	echo "Enter a file location for the certificate file that you want to revoke"
	exit 1;
fi

openssl ca -config intermediate/openssl.cnf -revoke $cert_file_to_revoke

echo "Remake the certificate revocation list"
bash "$parent_path/remake_intermediate_crl.sh"

echo "Certificate Revocation Completed: $cert_file_to_revoke"

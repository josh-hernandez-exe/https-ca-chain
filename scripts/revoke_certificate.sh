#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root
source scripts/load_vars.sh


cert_to_revoke=""
parent_type="intermediate"

while [[ $# -gt 0 ]]; do
key="$1"
value="$2"
case $key in

    --debug)
      set -x
    ;;

    --parent-type)
      parent_type="$value"
      shift
    ;;

    --cert)
      cert_to_revoke="$value"
      shift
    ;;

esac
shift
done

source scripts/load_vars.sh

if [ "$parent_cert" == "" ];then
    exit 1;
fi



echo "#######################"
echo "Revoke Certificate"
echo "#######################"

if [ ! -f "$cert_to_revoke" ]; then
	echo "Enter a file location for the certificate file that you want to revoke"
	exit 1;
fi

openssl ca \
   -revoke $cert_to_revoke \
   -keyfile $parent_key \
   -config $parent_config \
   -cert $parent_cert \
   $passin_string

echo "Remake the certificate revocation list"
bash "$parent_path/remake_intermediate_crl.sh" --parent-type $parent_type

echo "Certificate Revocation Completed: $cert_to_revoke"

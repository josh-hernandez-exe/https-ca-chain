#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root

cert_wild_card="*.cert.pem"
server_cert_dir="server/certs/"
client_cert_dir="client/certs/"

server_cert_files=$(ls $server_cert_dir$cert_wild_card)
client_cert_files=$(ls $client_cert_dir$cert_wild_card)

all_cert_files="$server_cert_files $client_cert_files"

for cert_file in $all_cert_files;do
    openssl verify \
        -CAfile intermediate/certs/ca-chain.cert.pem \
        -CRLfile intermediate/crl/intermediate.crl.pem \
        -crl_check $cert_file > /dev/null
    echo "$cert_file : $?"
done

cd $previous_dir

#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cert_file_to_view=$1

if [ ! -f $cert_file_to_view ]; then
	echo "Enter a file location for the certificate file that you want to view"
	exit 1;
fi

openssl x509 -noout -text -purpose -in $cert_file_to_view

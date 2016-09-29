#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

bash "$parent_path/scripts/make_dirs.sh"

bash "$parent_path/scripts/make_master_key.sh"

bash "$parent_path/scripts/make_client_key.sh" --parent-type master
bash "$parent_path/scripts/make_client_key.sh" --parent-type master --name 1
bash "$parent_path/scripts/make_client_key.sh" --parent-type master --name 2

bash "$parent_path/scripts/make_server_key.sh" --parent-type master

bash "$parent_path/scripts/make_server_selfsigned_key.sh"
bash "$parent_path/scripts/make_client_selfsigned_key.sh"

cert_to_revoke="$client_cert_dir/client2.cert.pem"

bash "$parent_path/scripts/revoke_certificate.sh" --cert $cert_to_revoke --parent-type master
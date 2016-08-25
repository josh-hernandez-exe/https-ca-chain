#!/bin/bash

# Sources of information
# https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
# https://engineering.circle.com/https-authorized-certs-with-node-js-315e548354a2#.w4n1knrb1


parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"

bash "$parent_path/scripts/make_configs.sh"
bash "$parent_path/scripts/make_master_key.sh"
bash "$parent_path/scripts/make_intermediate_key.sh"
bash "$parent_path/scripts/make_server_key.sh"
bash "$parent_path/scripts/make_client_key.sh"
bash "$parent_path/scripts/make_server_selfsigned_key.sh"
bash "$parent_path/scripts/make_client_selfsigned_key.sh"

echo "Setup Complete"

#!/bin/bash

# Sources of information
# https://jamielinux.com/docs/openssl-certificate-authority/create-the-root-pair.html
# https://engineering.circle.com/https-authorized-certs-with-node-js-315e548354a2#.w4n1knrb1


parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
cd "$parent_path"
source scripts/catch_errors.sh

catch bash "$parent_path/scripts/make_dirs.sh"

catch bash "$parent_path/scripts/make_master_key.sh"
catch bash "$parent_path/scripts/make_intermediate_key.sh"
catch bash "$parent_path/scripts/make_server_key.sh"
catch bash "$parent_path/scripts/make_client_key.sh"
catch bash "$parent_path/scripts/make_client_key.sh" --name 1
catch bash "$parent_path/scripts/make_client_key.sh" --name 2
catch bash "$parent_path/scripts/make_server_selfsigned_key.sh"
catch bash "$parent_path/scripts/make_client_selfsigned_key.sh"

source "$parent_path/scripts/load_vars.sh"

cert_to_revoke="$client_cert_dir/client2.cert.pem"

catch bash "$parent_path/scripts/revoke_certificate.sh" --cert $cert_to_revoke

catch bash "$parent_path/scripts/validate_certificates.sh"

echo "Setup Complete"

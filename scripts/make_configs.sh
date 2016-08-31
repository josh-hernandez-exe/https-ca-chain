#!/bin/bash
previous_dir=$(pwd)
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")

echo "#######################"
echo "Make Config Files"
echo "#######################"

cd $project_root
mkdir master
mkdir intermediate

# Then create Config File
# https://jamielinux.com/docs/openssl-certificate-authority/appendix/root-configuration-file.html
# https://jamielinux.com/docs/openssl-certificate-authority/appendix/intermediate-configuration-file.html


master_config_content="[ ca ]
# \`man ca\`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = $project_root/master
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

# The root key and root certificate.
private_key       = \$dir/private/ca.key.pem
certificate       = \$dir/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/ca.crl.pem
#crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = CA_default
cert_opt          = CA_default
default_days      = 375
preserve          = no
policy            = policy_strict
"

intermediate_config_contents="[ ca ]
# \`man ca\`
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = $project_root/intermediate
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

# The root key and root certificate.
private_key       = \$dir/private/intermediate.key.pem
certificate       = \$dir/certs/intermediate.cert.pem

# For certificate revocation lists.
# crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/intermediate.crl.pem
# crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256
# default_md        = md5

name_opt          = CA_default
cert_opt          = CA_default
default_days      = 375
"


common_contents="
[ req ]
# Options for the \`req\` tool (\`man req\`).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only
x509_extensions     = v3_ca

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# For Convience Only (Remove of actual uses)
# prompt                 = no
# output_password        = password

[ req_attributes ]
challengePassword      = password

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = CA
stateOrProvinceName_default     = Manitoba
localityName_default            = Winnipeg
0.organizationName_default      = The Organization
organizationalUnitName_default  = The Unit
emailAddress_default            = nameless@unit.organization.example.com



# [ v3_ca ]
# authorityInfoAccess = @issuer_info

[ v3_ca ]
# Extensions for a typical CA (\`man x509v3_config\`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign


[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (\`man x509v3_config\`).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (\`man x509v3_config\`).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = \"OpenSSL Generated Client Certificate\"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection



[ server_cert ]
# Extensions for server certificates (\`man x509v3_config\`).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = \"OpenSSL Generated Server Certificate\"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth




[ issuer_info ]
OCSP;URI.0 = http://ocsp.example.com/
caIssuers;URI.0 = http://example.com/ca.cert

"


echo -e "$master_config_content\n$common_contents"> "$project_root/master/openssl.cnf"
echo -e "$intermediate_config_contents\n$common_contents" > "$project_root/intermediate/openssl.cnf"

cd $previous_dir

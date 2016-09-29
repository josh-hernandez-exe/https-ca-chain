master_config="master/master.conf"
master_key="master/private/master.key.pem"
master_cert="master/certs/master.cert.pem"
master_csr="master/csr/master.csr.pem"
master_crl="master/crl/master.crl.pem"
master_serial="master/master.serial"
master_database="master/master.database.txt"

intermediate_cert_dir="intermediate/certs"
intermediate_cert="$intermediate_cert_dir/intermediate.cert.pem"
intermediate_cert_chain="$intermediate_cert_dir/intermediate.chain.cert.pem"

intermediate_config="intermediate/intermediate.conf"
intermediate_crl="intermediate/crl/intermediate.crl.pem"
intermediate_database="intermediate/intermediate.database.txt"
intermediate_csr="intermediate/csr/intermediate.csr.pem"
intermediate_key="intermediate/private/intermediate.key.pem"
intermediate_serial="intermediate/intermediate.serial"

server_cert_dir="server/certs"
server_name="server$server_index"

server_cert="$server_cert_dir/$server_name.cert.pem"
server_chain="$server_cert_dir/$server_name.chain.cert.pem"

server_config="server/$server_name.conf"
server_csr="server/csr/$server_name.csr.pem"
server_key="server/private/$server_name.key.pem"

client_cert_dir="client/certs"
client_name="client$client_index"

client_cert="$client_cert_dir/$client_name.cert.pem"
client_chain="$client_cert_dir/$client_name.chain.cert.pem"

client_common_name="Client $client_index"
client_config="client/$client_name.conf"
client_csr="client/csr/$client_name.csr.pem"
client_key="client/private/$client_name.key.pem"

passin_string="-passin pass:password"

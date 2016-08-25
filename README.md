### Initialize Project

Run the `setup.sh` script. This will create several folders, keys and certificates.

Run the server with `node server`.

Run the client with `node client` or `node client [prefix]` if you have made muliple client certificates. Note that the formate expected is from use of the script `./scripts/make_client_key.sh [prefix]`

### Issues

Currently passing the certificate revokation list to the node server causes the server to ignore any/all clients.

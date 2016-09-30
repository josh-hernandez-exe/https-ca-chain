#!/bin/bash
#
#
# This client connects to the local server running on port 1337.
# Should print 'hello world' and exit 0 on success
# On failure will print a curl error.
#
# Tested with the root->server->client model
# Untested with the root->intermediate->server->client model
#

help() {
  echo "USAGE: run.sh [--parent-type TYPE] [--name INDEX]"
  echo "TYPE (default: intermediate)"
  echo "INDEX (default: 1)"
  exit 0;
}

parent_type="intermediate"
client_index="1"

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

    --name)
      client_index="$value"
      shift
    ;;
    --help|-h)
      usage
    ;;

esac
shift
done

source "../scripts/load_vars.sh"

curl --cacert "../$parent_cert_chain" --cert "../$client_cert:password" --key "../$client_key" "https://localhost:1337/"

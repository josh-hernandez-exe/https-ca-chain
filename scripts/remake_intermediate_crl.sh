#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

cd $project_root

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

esac
shift
done

source scripts/load_vars.sh

if [ "$parent_cert" == "" ];then
    exit 1;
fi

echo "#######################"
echo "Remake Intermediate CRL"
echo "#######################"

rm $parent_crl
openssl ca \
    -keyfile $parent_key \
    -cert $parent_cert \
    -config $parent_config \
    -gencrl \
    -out $parent_crl \
    $passin_string

# View CRL
openssl crl -text -noout -in $parent_crl
cd $previous_dir

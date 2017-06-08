#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")

echo "#######################"
echo "Wipe"
echo "#######################"

rm -rf $project_root/client
rm -rf $project_root/intermediate
rm -rf $project_root/master
rm -rf $project_root/server

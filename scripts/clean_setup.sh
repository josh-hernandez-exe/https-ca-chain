#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Clean Setup"
echo "#######################"

rm -rf $project_root/client
rm -rf $project_root/intermediate
rm -rf $project_root/master
rm -rf $project_root/server

bash $project_root/setup.sh

echo "Done Clean Setup"
cd $previous_dir

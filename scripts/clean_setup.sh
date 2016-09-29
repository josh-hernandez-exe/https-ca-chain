#!/bin/bash
parent_path=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P )
project_root=$(dirname "$parent_path")
previous_dir=$(pwd)

echo "#######################"
echo "Clean Setup"
echo "#######################"

bash $project_root/scripts/wipe.sh
bash $project_root/setup.sh

echo "Done Clean Setup"
cd $previous_dir

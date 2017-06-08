#!/bin/bash
set -o pipefail
# Catches non-zero errors display a message and exits program
# Can be passed a bash command or an exit code
# Usage:
# eg 1:
#   catch echo "hello";
# OUTPUT:
#   [OK]

# eg 2:
#   bash return_1.sh;
#   catch $?;
# OUTPUT:
#   [FAILED]

# eg 3:
#   bash return_0.sh;
#   catch $?;
# OUTPUT:
#   [OK]
catch() {
  if [[ "$@" =~ ^-?[0-9]+$ ]]; then
    local STATUS="$@";
  else
    "$@"
    local STATUS=$?;
  fi
  if [ $STATUS -ne 0 ]; then
    echo -e "[\e[31mFAILED\e[39m]";
    exit $STATUS;
  else
    echo -e "[\e[32mOK\e[39m]";
  fi
  return $STATUS;
}



#catches non-zero errors, displays a message but lets the program continue.
pass() {
  "$@"
  local STATUS=$?
  if [ $STATUS -ne 0 ]; then
    echo -e "[\e[33mWARNING\e[39m]";
  else
    echo -e "[\e[32mOK\e[39m]";
  fi
}


#This function was written by: http://fitnr.com/showing-a-bash-spinner.html
#https://github.com/marascio/bash-tips-and-tricks/tree/master/showing-progress-with-a-bash-spinner
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    echo "$pid" > "/tmp/.spinner.pid"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

#Preppends the date to the line fed to this.
# exit status is preserved.
timestampit() {
  local status_in=$? # ${PIPESTATUS[0]}
    while IFS= read -r line; do
        echo -e "$(date) $line"
    done
  return $status_in
}

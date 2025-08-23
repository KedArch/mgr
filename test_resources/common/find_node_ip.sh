#!/bin/bash

if [ "$#" -eq 1 ]; then
    TYPE=name
    NODE="$1"
elif [ "$#" -eq 2 ]; then
    TYPE="$1"
    NODE="$2"
else
    echo "Usage: $0 <name|ip> [value]"
    exit 2
fi
INVENTORY=$(dirname $(realpath $0))/../../ansible/inventory/hosts

if [ "$TYPE" == "name" ]; then
  FOUND=$(grep -A 1 -E "$NODE:" "$INVENTORY" | grep ansible_host | tr -s ' ' | cut -d ' ' -f 3)
elif [ "$TYPE" == "ip" ]; then
  FOUND=$(grep -B 1 -E "$NODE( |$)" "$INVENTORY" | grep -v ansible_host | tr -s ' ' | cut -d ' ' -f 2 | sed "s/:$//")
else
  echo "ERROR: Unrecognized type: '$TYPE' - Allowed types: 'ip', 'name'"
  exit 3
fi
if [ -z $FOUND ]; then
  echo "Couldn't find '$TYPE' with value '$NODE' in '$INVENTORY'"
  exit 1
else
  echo $FOUND
fi

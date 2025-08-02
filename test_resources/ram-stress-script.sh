#!/bin/bash

export LANG=C

PERCENTAGE=$1
if [ -z $PERCENTAGE ]; then
  PERCENTAGE=95
fi

total_memory=$(free -m | awk '/^Mem:/{print $2}')
target_memory=$(($total_memory * $PERCENTAGE / 100))

while true; do
  a=$(cat /dev/zero | tr '\0' 'a' | head -c ${target_memory}M)
done


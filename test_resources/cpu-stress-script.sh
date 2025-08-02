#!/usr/bin/env bash
COUNT=$1
if [ -z $COUNT ]; then
  COUNT=1
fi
for i in $(seq 1 $COUNT); do
  sh -c "while true; do :; done" &
done

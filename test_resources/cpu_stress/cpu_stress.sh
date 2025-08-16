#!/bin/sh
cleanup() {
    for job in $(jobs -p); do
        kill "$job" 2>/dev/null
    done
}
trap cleanup EXIT
trap cleanup INT
trap cleanup TERM
COUNT=$1
if [ -z $COUNT ]; then
  COUNT=$(nproc)
fi
for i in $(seq $COUNT); do
  while true; do :; done &
done
wait

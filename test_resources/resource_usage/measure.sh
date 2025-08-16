#!/bin/bash
export ANSIBLE_INVENTORY=$(dirname $(realpath $0))/../../ansible/inventory/
export ANSIBLE_LOAD_CALLBACK_PLUGINS=True
export ANSIBLE_STDOUT_CALLBACK=ansible.posix.json

NO_OF_MEASURMENTS=15

# for i in nonrtric nearrtric gnb; do
#   for j in $(kubectl -n $i get deployment | sed "1d" | cut -d ' ' -f 1); do
#     kubectl -n $i scale deployment --replicas=0 $j
#   done
#   for j in $(kubectl -n $i get statefulset | sed "1d" | cut -d ' ' -f 1); do
#     kubectl -n $i scale statefulset --replicas=0 $j
#   done
# done

mkdir -p test

TIME=$(date "+%Y-%m-%dT%H:%M:%S.%6N")

i=1
while [ $i -le $NO_OF_MEASURMENTS ]; do
  sleep 61
  echo Measurment off $i
  kubectl top nodes > test/kubectl_top_off_$i\_$TIME.log
  kubectl=$?
  ansible control,worker -b -a "bash -c 'free; uptime'" > test/free_uptime_off_$i\_$TIME.log
  ansible=$?
  if [ $kubectl -eq 0 ] && [ $ansible -eq 0 ]; then
    i=$(($i+1))
  fi
done

for i in nonrtric nearrtric gnb; do
  for j in $(kubectl -n $i get deployment | sed "1d" | cut -d ' ' -f 1); do
    kubectl -n $i scale deployment --replicas=1 $j
  done
  for j in $(kubectl -n $i get statefulset | sed "1d" | cut -d ' ' -f 1); do
    kubectl -n $i scale statefulset --replicas=1 $j
  done
done
for i in a1-sim-osc a1-sim-std a1-sim-std2; do
  kubectl -n nonrtric scale statefulset --replicas=2 $i
done

TIME=$(date "+%Y-%m-%dT%H:%M:%S.%6N")

i=1
while [ $i -le $NO_OF_MEASURMENTS ]; do
  sleep 61
  echo Measurment on $i
  kubectl top nodes > test/kubectl_top_on_$i\_$TIME.log
  kubectl=$?
  ansible control,worker -b -a "bash -c 'free; uptime'" > test/free_uptime_on_$i\_$TIME.log
  ansible=$?
  if [ $kubectl -eq 0 ] && [ $ansible -eq 0 ]; then
    i=$(($i+1))
  fi
done

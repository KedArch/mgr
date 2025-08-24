#!/bin/bash

SSH_ARGS="-o StrictHostKeyChecking=no"
JUMP_HOST="10.29.5.40"
JUMP_USER="rw"
REMOTE_USER="deploy"
REMOTE_HOST_CP="control-main-1"
REMOTE_HOST_W="worker-main-2"
INVENTORY=$(dirname $(realpath $0))/../../../ansible/inventory
FIND_NODE=$(dirname $(realpath $0))/../../common/find_node_ip.sh
KUBECONFIG=$(dirname $(realpath $0))/../../../ansible/creds/kubeconfig
TEST_COMMAND="kubectl get node"

clean(){
  kill $pid 2>/dev/null
  ssh -J "$JUMP_USER@$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$NODE_IP" "pkill cpu_stress.sh"
}
cleanup() {
  echo "Cleaning up..."
  clean
  exit
}
trap cleanup SIGINT

cpu_test() {
DATE=$(date +"%Y-%m-%dT%H:%M:%S.%6N")
echo $DATE
NODE_NAME=$1
NODE_IP=$($FIND_NODE $NODE_NAME)
if [[ $NODE_NAME == control* ]]; then
    CONTROL=true
else
    CONTROL=false
fi

cpu=0

while true; do

echo $NODE_IP $cpu

ssh -J "$JUMP_USER@$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$NODE_IP" "./cpu_stress.sh $cpu" &
pid=$!
CHECK=$(kubectl get node | grep $NODE_NAME | grep NotReady)

sleep 65

CHECK=$(kubectl get node | grep $NODE_NAME | grep NotReady)
if [ -n "$CHECK" ]; then
  touch "test/${NODE_NAME}_failed_at_${cpu}"
  FAILED=true
else
  FAILED=false
fi

if [ "$CONTROL" == "true" ] && [ "$FAILED" == "false" ];then
for i in {1..15}; do
  { time $(echo $TEST_COMMAND ); } 2>&1 | grep real | cut -d 'm' -f 2 | tr ',' '.' | sed "s/[^0-9]*\([0-9]*\).\([0-9]*\)[^0-9]*/\1.\2/"  >> "test/${NODE_NAME}_${cpu}_${DATE}"
  if [ "$?" != 0 ]; then
    FAILED=true
    break
  fi
done
fi

kill $pid
clean

if [ "$FAILED" == "true" ]; then
  break
fi

cpu=$(($cpu+1))

done
}

mkdir -p test
cpu_test $REMOTE_HOST_CP
cpu_test $REMOTE_HOST_W

for i in $(ls test/$REMOTE_HOST_CP*); do
  awk '{ sum += $1; count++ } END { if (count > 0) print sum / count }' test/$i > test/result_$REMOTE_HOST_CP
done
for i in $(ls test/$REMOTE_HOST_W*); do
  awk '{ sum += $1; count++ } END { if (count > 0) print sum / count }' test/$i > test/result_$REMOTE_HOST_W
done

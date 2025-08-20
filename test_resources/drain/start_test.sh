#!/bin/bash

if ! kubectl get node &> /dev/null; then
  echo "Set KUBECONFIG var or ensure communication to kube-apiserver"
  exit 1
fi

ETCDCTL=$(dirname $(realpath $0))/../../ansible/bin/etcdctl-wrapper
SSH_ARGS="-o StrictHostKeyChecking=no"
JUMP_HOST="rw@10.29.5.40"
REMOTE_USER="deploy"
REMOTE_HOST="10.200.0.31"
NAMESPACE="nonrtric"
NODE="worker-main-1"
REMOTE_LOG_FILE="/opt/rancher/data/agent/containerd/containerd.log"
CONTROL_NODES="10.200.0.11 10.200.0.12 10.200.0.21"
NO_OF_MEASURMENTS=15

# get_control_node_ip() {
#   if [ $1 == 'control-main-1' ]; then
#     echo "10.200.0.11"
#   elif [ $1 == 'control-main-2' ]; then
#     echo "10.200.0.12"
#   elif [ $1 == 'control-reg-1' ]; then
#     echo "10.200.0.21"
#   else
#     echo "No control node with that name"
#     return 1
#   fi
# }
#
# etcd_control_node() {
#   ETCD_LEADER_ID=$($ETCDCTL endpoint status | cut -d ',' -f 2,9 | grep true | cut -d ',' -f 1)
#   CONTROL_NODE=$($ETCDCTL member list | grep $ETCD_LEADER_ID | cut -d ',' -f 3 | sed "s/\(.*\)-[0-9a-f]\{8\}/\1/")
#   CONTROL_NODE_IP=$(get_control_node_ip $CONTROL_NODE)
#   scp -J "$JUMP_HOST" $SSH_ARGS "$(dirname $(realpath $0))/../common/find_logs.py" "$REMOTE_USER@$CONTROL_NODE_IP:"
#   if [ $? -ne 0 ]; then
#     echo "Error sending script to control node."
#     exit 1
#   fi
# }

kubectl uncordon $NODE
kubectl rollout restart deployment -n $NAMESPACE
kubectl rollout status deployment -n $NAMESPACE

for node in $CONTROL_NODES; do
  scp -J "$JUMP_HOST" $SSH_ARGS "$(dirname $(realpath $0))/../common/find_logs.py" "$REMOTE_USER@$node:"
  if [ $? -ne 0 ]; then
    echo "Error sending script to control node: $node."
    exit 1
  fi
done

scp -J "$JUMP_HOST" $SSH_ARGS "$(dirname $(realpath $0))/../common/find_logs.py" "$REMOTE_USER@$REMOTE_HOST:"
if [ $? -ne 0 ]; then
  echo "Error sending script to node."
  exit 1
fi

measurment=1

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  rm containerd_drain.csv agent_drain.csv
  rm containerd_uncordon.csv agent_uncordon.csv
EOF
for node in $CONTROL_NODES; do
ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node" << EOF
  echo $node
  rm server_drain.csv
  rm server_uncordon.csv
EOF
done

while [ $measurment -le $NO_OF_MEASURMENTS ]; do

sleep 30

echo Measurment $measurment

DATE=$(date +"%Y-%m-%d %H:%M:%S.%6N")
echo $DATE

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo cp "$REMOTE_LOG_FILE" $(basename $REMOTE_LOG_FILE)-old
EOF

kubectl drain --ignore-daemonsets --delete-emptydir-data $NODE

while ! kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running 2>&1 | grep "No resources found"; do
    echo Waiting...
    sleep 1
done

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo diff $(basename $REMOTE_LOG_FILE)-old "$REMOTE_LOG_FILE" | grep '^>' | sed 's/^> //' > $(basename $REMOTE_LOG_FILE)-diff
  echo "Checking containerd logs"
  sudo python3 find_logs.py "$DATE" "$(basename $REMOTE_LOG_FILE)-diff" containerd_drain.csv "StopContainer"
  echo "Checking agent logs"
  sudo python3 find_logs.py "$DATE" k3s-agent.service agent_drain.csv "operationExecutor.UnmountVolume"
EOF
if [ $? -ne 0 ]; then
  echo "Error when retrieving agent logs"
  exit 1
fi
state=bad
for node in $CONTROL_NODES; do
ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node" << EOF
  echo "Checking server logs: $node"
  sudo python3 find_logs.py "$DATE" k3s.service server_drain.csv "\"Successfully synced\" key=\"$NODE\""
EOF
if [ $? -eq 0 ]; then
  state=good
fi
done
if [ $state == bad ]; then
  echo "Error when retrieving server logs"
  exit 1
fi

sleep 30

DATE=$(date +"%Y-%m-%d %H:%M:%S.%6N")
echo $DATE

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo cp "$REMOTE_LOG_FILE" $(basename $REMOTE_LOG_FILE)-old
EOF

kubectl uncordon $NODE
sleep 1
kubectl rollout restart deployment -n $NAMESPACE
kubectl rollout status deployment -n $NAMESPACE

while ! kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running 2>&1 | grep "No resources found"; do
    echo Waiting...
    sleep 1
done

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo diff $(basename $REMOTE_LOG_FILE)-old "$REMOTE_LOG_FILE" | grep '^>' | sed 's/^> //' > $(basename $REMOTE_LOG_FILE)-diff
  echo "Checking containerd logs"
  sudo python3 find_logs.py "$DATE" "$(basename $REMOTE_LOG_FILE)-diff" containerd_uncordon.csv "RunPodSandbox for"
  echo "Checking agent logs"
  sudo python3 find_logs.py "$DATE" k3s-agent.service agent_uncordon.csv "operationExecutor.VerifyControllerAttachedVolume"
EOF
if [ $? -ne 0 ]; then
  echo "Error when retrieving agent logs"
  exit 1
fi
state=bad
for node in $CONTROL_NODES; do
ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node" << EOF
  echo "Checking server logs: $node"
  sudo python3 find_logs.py "$DATE" k3s.service server_uncordon.csv "\"Successfully synced\" key=\"$NODE\""
EOF
if [ $? -eq 0 ]; then
  state=good
fi
done
if [ $state == bad ]; then
  echo "Error when retrieving server logs"
  exit 1
fi

measurment=$((measurment + 1))

done

DATE=$(date +"%Y-%m-%dT%H:%M:%S.%6N")
echo $DATE

mkdir -p test
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:containerd_drain.csv" "test/containerd_drain_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:containerd_uncordon.csv" "test/containerd_uncordon_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:agent_drain.csv" "test/agent_drain_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:agent_uncordon.csv" "test/agent_uncordon_$DATE.csv"
for node in $CONTROL_NODES; do
  scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node:server_drain.csv" "test/server_drain_$node\_$DATE.csv"
  scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node:server_uncordon.csv" "test/server_uncordon_$node\_$DATE.csv"
done

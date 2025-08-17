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
NO_OF_MEASURMENTS=15

get_control_node_ip() {
  if [ $1 == 'control-main-1' ]; then
    return 10.200.0.11
  elif [ $1 == 'control-main-2' ]; then
    return 10.200.0.12
  elif [ $1 == 'control-reg-1' ]; then
    return 10.200.0.21
  else
    echo "No control node with that name"
    exit 1
  fi
}

control_node() {
  ETCD_LEADER_ID=$($ETCDCTL endpoint status | cut -d ',' -f 2,9 | grep true | cut -d ',' -f 1)
  CONTROL_NODE=$($ETCDCTL member list | grep $ETCD_LEADER_ID | cut -d ',' -f 3 | sed "s/\(.*\)-[0-9a-f]\{8\}/\1/")
  CONTROL_NODE_IP=$(get_control_node_ip $CONTROL_NODE)
  scp -J "$JUMP_HOST" $SSH_ARGS "$(dirname $(realpath $0))../container_failure/find_logs.py" "$REMOTE_USER@$CONTROL_NODE_IP:"
  if [ $? -ne 0 ]; then
    echo "Error sending script to control node."
    exit 1
  fi
}

scp -J "$JUMP_HOST" $SSH_ARGS "$(dirname $(realpath $0))../container_failure/find_logs.py" "$REMOTE_USER@$REMOTE_HOST:"
if [ $? -ne 0 ]; then
  echo "Error sending script to node."
  exit 1
fi
control_node

measurment=0

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  rm containerd-drain.csv agent-drain.csv
  rm containerd-uncordon.csv agent-uncordon.csv
EOF
ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$CONTROL_NODE_IP" << EOF
  rm server-drain.csv
  rm server-uncordon.csv
EOF

while [ $measurment -le $NO_OF_MEASURMENTS ]; do

echo Measurment $measurment
fail=false

DATE=$(date +"%Y-%m-%d %H:%M:%S.%6N")

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo cp "$REMOTE_LOG_FILE" $(basename $REMOTE_LOG_FILE)-old
EOF

kubectl drain --ignore-daemonsets --delete-emptydir-data $NODE

while ! kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running 2>&1 | grep "No resources found"; do
    sleep 1
done

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo diff $(basename $REMOTE_LOG_FILE)-old "$REMOTE_LOG_FILE" | grep '^>' | sed 's/^> //' > $(basename $REMOTE_LOG_FILE)-diff
  sudo python3 find_logs.py "$DATE" "$(basename $REMOTE_LOG_FILE)-diff" containerd-drain.csv "StopContainer"
  sudo python3 find_logs.py "$DATE" k3s-agent.service agent-drain.csv "operationExecutor.UnmountVolume"
EOF
ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$CONTROL_NODE_IP" << EOF
  sudo python3 find_logs.py "$DATE" k3s.service server-drain.csv "\"Successfully synced\" key=\"$NODE\""
EOF

DATE=$(date +"%Y-%m-%d %H:%M:%S.%6N")

kubectl uncordon $NODE
sleep 1
kubectl rollout restart deployment -n $NAMESPACE
kubectl rollout restart statefulset -n $NAMESPACE
kubectl rollout status deployment -n $NAMESPACE
kubectl rollout status statefulset -n $NAMESPACE

while ! kubectl get pods -n $NAMESPACE --field-selector=status.phase!=Running 2>&1 | grep "No resources found"; do
    sleep 1
done

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST" << EOF
  sudo diff $(basename $REMOTE_LOG_FILE)-old "$REMOTE_LOG_FILE" | grep '^>' | sed 's/^> //' > $(basename $REMOTE_LOG_FILE)-diff
  sudo python3 find_logs.py "$DATE" "$(basename $REMOTE_LOG_FILE)-diff" containerd-drain.csv "operationExecutor.VerifyControllerAttachedVolume"
  sudo python3 find_logs.py "$DATE" k3s-agent.service agent-drain.csv "RunPodSandbox for"
EOF
ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$CONTROL_NODE_IP" << EOF
  sudo python3 find_logs.py "$DATE" k3s.service server-drain.csv "\"Successfully synced\" key=\"$NODE\""
EOF

measurment=$((measurment + 1))

done

DATE=$(date +"%Y-%m-%d %H:%M:%S.%6N")

mkdir -p test
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:containerd_drain.csv" "containerd_drain_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:containerd_uncordon.csv" "containerd_uncordon_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:agent_drain.csv" "agent_drain_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$REMOTE_HOST:agent_uncordon.csv" "agent_uncordon_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$CONTROL_NODE_IP:server_drain.csv" "server_drain_$DATE.csv"
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$CONTROL_NODE_IP:server_uncordon.csv" "server_uncordon_$DATE.csv"

#!/bin/bash

if ! kubectl get node &> /dev/null; then
  echo "Set KUBECONFIG var or ensure communication to kube-apiserver"
  exit 1
fi

SSH_ARGS="-o StrictHostKeyChecking=no"
JUMP_HOST="rw@10.29.5.40"
REMOTE_HOST="deploy@10.200.0.52"
DEPLOYMENT="appmgr"
NAMESPACE="nearrtric"
NODE="worker-reg-2"
REMOTE_LOG_FILE="/opt/rancher/data/agent/containerd/containerd.log"
PATTERNS=("received exit event" "PullImage" "PullImage.*returns image reference" "StartContainer")
NO_OF_MEASURMENTS=15

kubectl patch deployment $DEPLOYMENT -n $NAMESPACE --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/nodeName\", \"value\": \"$NODE\"}]"

scp -J "$JUMP_HOST" $SSH_ARGS "../common/find_logs.py" "$REMOTE_HOST:"
if [ $? -ne 0 ]; then
  echo "Error sending script."
  exit 1
fi

measurment=0

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_HOST" << EOF
  rm time.csv
EOF

while [ $measurment -le $NO_OF_MEASURMENTS ]; do

echo Measurment $measurment

kubectl rollout restart deployment -n $NAMESPACE $DEPLOYMENT
kubectl rollout status deployment -n $NAMESPACE $DEPLOYMENT

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_HOST" << EOF
  sudo cp "$REMOTE_LOG_FILE" $(basename $REMOTE_LOG_FILE)-old
  echo $(date +"%Y-%m-%dT%H:%M:%S.%6N") > time
  sudo pkill -9 -f "$DEPLOYMENT.sh"
EOF

while true; do
    pod_count=$(kubectl get -n $NAMESPACE pods -l app=$DEPLOYMENT | tail -n +2 | wc -l)
    if [ "$pod_count" -eq 1 ]; then
        break
    fi
    sleep 1
done

ssh -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_HOST" << EOF
  sudo diff $(basename $REMOTE_LOG_FILE)-old "$REMOTE_LOG_FILE" | grep '^>' | sed 's/^> //' > $(basename $REMOTE_LOG_FILE)-diff
  sudo python3 find_logs.py "\$(cat time)" "$(basename $REMOTE_LOG_FILE)-diff" time.csv $(printf '%q ' "${PATTERNS[@]}")
EOF

if [ $? -eq 0 ]; then
  measurment=$((measurment + 1))
fi

done

kubectl patch deployment $DEPLOYMENT -n $NAMESPACE --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/nodeName\", \"value\": \"\"}]"

mkdir -p test
scp -J "$JUMP_HOST" $SSH_ARGS "$REMOTE_HOST:time.csv" "test/container_failure_$(date +'%Y-%m-%dT%H:%M:%S.%6N').csv"
if [ $? -ne 0 ]; then
  echo "Error retrieving csv file."
  exit 1
fi

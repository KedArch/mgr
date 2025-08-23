#!/bin/bash

ETCDCTL=$(dirname $(realpath $0))/../../ansible/bin/etcdctl-wrapper

if ! $ETCDCTL member list &> /dev/null; then
  echo "Set ensure communication to etcd"
  exit 1
fi

SSH_ARGS="-o StrictHostKeyChecking=no"
JUMP_HOST="10.29.5.40"
JUMP_USER="rw"
REMOTE_USER="deploy"
INVENTORY=$(dirname $(realpath $0))/../../ansible/inventory
FIND_LEADER=$(dirname $(realpath $0))/../common/find_leader.sh
FIND_NODE=$(dirname $(realpath $0))/../common/find_node_ip.sh
PORT_FORWARD=$(dirname $(realpath $0))/../../ansible/port_forward.yml

CONTROL_NODES=("control-main-1" "control-main-2" "control-reg-1")
TO_START=()

remove_from_array() {
    local string_to_remove="$1"
    local new_array=()

    for item in "${CONTROL_NODES[@]}"; do
        if [[ "$item" != "$string_to_remove" ]]; then
            new_array+=("$item")
        fi
    done

    CONTROL_NODES=("${new_array[@]}")
}

mkdir -p test

ansible-playbook -i $INVENTORY $PORT_FORWARD &> /dev/null

while ! $FIND_LEADER &>/dev/null; do
  sleep 1
done

DATE=$(date +"%Y-%m-%d %H:%M:%S.%6N")
echo $DATE

for i in 1 2; do

DATE_LOOP=$(date +"%Y-%m-%d %H:%M:%S.%6N")

read LEADER_NODE LEADER_IP <<< $($FIND_LEADER 2>/dev/null)
echo $LEADER_NODE $LEADER_IP
echo $LEADER_NODE >> "test/leaders_$DATE.txt"

remove_from_array $LEADER_NODE
TO_START+=($LEADER_NODE)

ansible-playbook -i $INVENTORY $PORT_FORWARD -e host=${CONTROL_NODES[0]} &>/dev/null

ansible -i $INVENTORY host -b -a "virsh destroy $LEADER_NODE"

while [[ "$($FIND_LEADER 2>/dev/null)" =~ "true" ]]; do
  sleep 1
done

for node in "${CONTROL_NODES[@]}"; do
node_ip=$($FIND_NODE $node)
ssh -J "$JUMP_USER@$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node_ip" << EOF
sudo journalctl -u k3s --since '$DATE_LOOP' > log.txt
EOF
scp -J "$JUMP_USER@$JUMP_HOST" $SSH_ARGS "$REMOTE_USER@$node_ip:log.txt" "test/$DATE\_$i\_$node.txt"
done

done

for node in "${TO_START[@]}"; do
  ansible -i $INVENTORY host -b -a "virsh start $node"
done

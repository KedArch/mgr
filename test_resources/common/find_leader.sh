#!/bin/bash

ETCDCTL=$(dirname $(realpath $0))/../../ansible/bin/etcdctl-wrapper
ETCD_LEADER_ID=$($ETCDCTL endpoint status | cut -d ',' -f 2,9 | grep true | cut -d ',' -f 1)
CONTROL_NODE=$($ETCDCTL member list | grep $ETCD_LEADER_ID | cut -d ',' -f 3 | sed "s/\(.*\)-[0-9a-f]\{8\}/\1/")
CONTROL_NODE_IP=$($(dirname $(realpath $0))/find_node_ip.sh $CONTROL_NODE)

echo $CONTROL_NODE $CONTROL_NODE_IP

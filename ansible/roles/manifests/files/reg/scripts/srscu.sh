#!/usr/bin/env bash
cp /etc/srscu.yaml.in /etc/srscu.yaml
sed -i "s/AMF_ADDR/$AMF_ADDR/g" /etc/srscu.yaml
CONTAINER_INTERNAL_IP="$(ip a show eth0 | grep 'inet ' | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)"
sed -i "s/CORE_BIND_ADDR/$CONTAINER_INTERNAL_IP/g" /etc/srscu.yaml
sed -i "s/F1U_EXT_ADDR/$SRSCU_F1U_SERVICE_SERVICE_HOST/g" /etc/srscu.yaml
apt install -y iptables
iptables -t nat -A POSTROUTING -p udp --sport 2152 -s 127.0.0.1 -j SNAT --to-source $CONTAINER_INTERNAL_IP
/usr/bin/srscu -c /etc/srscu.yaml

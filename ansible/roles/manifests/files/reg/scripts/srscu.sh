#!/usr/bin/env bash
cp /etc/srscu.yaml.in /etc/srscu.yaml
sed -i "s/AMF_ADDR/$AMF_ADDR/g" /etc/srscu.yaml
CONTAINER_INTERNAL_IP="$(ip a show eth0 | grep 'inet ' | tr -s ' ' | cut -d ' ' -f 3 | cut -d '/' -f 1)"
sed -i "s/CORE_BIND_ADDR/$CONTAINER_INTERNAL_IP/g" /etc/srscu.yaml
/usr/bin/srscu -c /etc/srscu.yaml
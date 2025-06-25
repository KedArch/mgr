#!/usr/bin/env bash
cp /etc/srscu.yaml.in /etc/srscu.yaml
sed -i "s/AMF_ADDR/$AMF_ADDR/g" /etc/srscu.yaml
/usr/bin/srscu -c /etc/srscu.yaml
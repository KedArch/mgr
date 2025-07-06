#!/usr/bin/env bash
cp /etc/srsdu.yaml.in /etc/srsdu.yaml
sed -i "s/CU_CP_ADDR/$CU_CP_ADDR/g" /etc/srsdu.yaml
sed -i "s/UE_ADDR/$UE_ADDR/g" /etc/srsdu.yaml
sed -i "s/F1U_EXT_ADDR/$SRSDU_F1U_SERVICE_HOST/g" /etc/srsdu.yaml
/usr/bin/srsdu -c /etc/srsdu.yaml

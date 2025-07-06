#!/usr/bin/env bash
cp /opt/config/submgr-config.yaml{.in,}
cp /opt/config/submgr-uta-rtg.rt{.in,}
CONTAINER_INTERNAL_IP="$(hostname -I)"
export RMR_SRC_ID=$CONTAINER_INTERNAL_IP
sed -i "s/SUBMGR_IP/$CONTAINER_INTERNAL_IP/g" /opt/config/submgr-config.yaml
sed -i "s/RTMGR_IP/$RTMGR_SIM_SERVICE_HOST/g" /opt/config/submgr-config.yaml
sed -i "s/DBAAS_IP/$DBAAS_SERVICE_HOST/g" /opt/config/submgr-config.yaml
sed -i "s/E2MGR_IP/$E2MGR_SERVICE_HOST/g" /opt/config/submgr-uta-rtg.rt
sed -i "s/E2TERM_IP/$E2TERM_SERVICE_HOST/g" /opt/config/submgr-uta-rtg.rt
sed -i "s/SUBMGR_IP/$SUBMGR_SERVICE_HOST/g" /opt/config/submgr-uta-rtg.rt
sed -i "s/XAPP_PY_RUNNER_IP/$XAPP_PY_RUNNER_SERVICE_HOST/g" /opt/config/submgr-uta-rtg.rt
/submgr

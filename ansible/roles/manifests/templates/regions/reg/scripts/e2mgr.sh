#!/usr/bin/env bash
cp /opt/E2Manager/resources/configuration.yaml{.in,}
cp /opt/E2Manager/router.txt{.in,}
CONTAINER_INTERNAL_IP="$(hostname -I)"
export RMR_SRC_ID=$CONTAINER_INTERNAL_IP
sed -i "s/RTMGR_IP/$RTMGR_SIM_SERVICE_HOST/g" /opt/E2Manager/resources/configuration.yaml
sed -i "s/E2MGR_IP/$E2MGR_SERVICE_HOST/g" /opt/E2Manager/router.txt
sed -i "s/E2TERM_IP/$E2TERM_SERVICE_HOST/g" /opt/E2Manager/router.txt
sed -i "s/SUBMGR_IP/$SUBMGR_SERVICE_HOST/g" /opt/E2Manager/router.txt
sed -i "s/XAPP_PY_RUNNER_IP/$PYTHON_XAPP_RUNNER_SERVICE_HOST/g" /opt/E2Manager/router.txt
./main -port=3800 -f /opt/E2Manager/resources/configuration.yaml

#!/usr/bin/env bash
cp /opt/ric/config/appmgr.yaml{.in,}
cp /opt/ric/config/router.txt{.in,}
CONTAINER_INTERNAL_IP="$(hostname -I)"
export RMR_SRC_ID=$CONTAINER_INTERNAL_IP
sed -i "s/DBAAS_IP/$DBAAS_SERVICE_HOST/g" /opt/ric/config/appmgr.yaml
sed -i "s/E2MGR_IP/$E2MGR_SERVICE_HOST/g" /opt/ric/config/router.txt
sed -i "s/E2TERM_IP/$E2TERM_SERVICE_HOST/g" /opt/ric/config/router.txt
sed -i "s/SUBMGR_IP/$SUBMGR_SERVICE_HOST/g" /opt/ric/config/router.txt
sed -i "s/XAPP_PY_RUNNER_IP/$XAPP_PY_RUNNER_SERVICE_HOST/g" /opt/ric/config/router.txt
/opt/xAppManager/appmgr-entrypoint.sh

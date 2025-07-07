#!/usr/bin/env bash
cp /opt/ric/config/uta-rtg.rt{.in,}
CONTAINER_INTERNAL_IP="$(hostname -I)"
export RMR_SRC_ID=$CONTAINER_INTERNAL_IP
sed -i "s/E2MGR_IP/$E2MGR_SERVICE_HOST/g" /opt/ric/config/uta-rtg.rt
sed -i "s/E2TERM_IP/$E2TERM_SERVICE_HOST/g" /opt/ric/config/uta-rtg.rt
sed -i "s/SUBMGR_IP/$SUBMGR_SERVICE_HOST/g" /opt/ric/config/uta-rtg.rt
sed -i "s/XAPP_PY_RUNNER_IP/$PYTHON_XAPP_RUNNER_SERVICE_HOST/g" /opt/ric/config/uta-rtg.rt
/bin/bash

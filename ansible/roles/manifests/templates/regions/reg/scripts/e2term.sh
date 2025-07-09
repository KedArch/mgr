#!/usr/bin/env bash
cp /configs/e2term.conf /opt/e2/config/config.conf
cp /configs/routes.rtg /opt/e2/dockerRouter.txt
CONTAINER_INTERNAL_IP="$(hostname -I)"
export RMR_SRC_ID=$CONTAINER_INTERNAL_IP
sed -i "s/E2TERM_IP/$CONTAINER_INTERNAL_IP/g" /opt/e2/config/config.conf
sed -i "s/E2MGR_IP/$E2MGR_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
sed -i "s/E2TERM_IP/$E2TERM_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
sed -i "s/SUBMGR_IP/$SUBMGR_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
sed -i "s/XAPP_PY_RUNNER_IP/$PYTHON_XAPP_RUNNER_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
/bin/sh -c ./startup.sh

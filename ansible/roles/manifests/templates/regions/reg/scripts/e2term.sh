#!/usr/bin/env bash
cp /opt/e2/config/config.conf{.in,}
cp /opt/e2/dockerRouter.txt{.in,}
CONTAINER_INTERNAL_IP="$(hostname -I)"
export RMR_SRC_ID=$CONTAINER_INTERNAL_IP
sed -i "s/E2TERM_IP/$CONTAINER_INTERNAL_IP/g" /opt/e2/config/config.conf
sed -i "s/E2MGR_IP/$E2MGR_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
sed -i "s/E2TERM_IP/$E2TERM_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
sed -i "s/SUBMGR_IP/$SUBMGR_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
sed -i "s/XAPP_PY_RUNNER_IP/$XAPP_PY_RUNNER_SERVICE_HOST/g" /opt/e2/dockerRouter.txt
/bin/sh -c ./startup.sh

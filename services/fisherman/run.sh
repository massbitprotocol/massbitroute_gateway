#!/bin/bash

ROOT=$(realpath $(dirname $(realpath $0))/../..)
VERSION=
source $ROOT/.env_raw

TYPE=gw
export RUST_LOG=debug
export SCHEDULER_ENDPOINT=https://scheduler.fisherman.$DOMAIN
export WORKER_ID=$(cat $ROOT/vars/ID)
export WORKER_IP=$(cat $ROOT/vars/IP)
export WORKER_ENDPOINT=https://$WORKER_IP/__worker
export WORKER_SERVICE_ENDPOINT=127.0.0.1:4040
export BENCHMARK_WRK_PATH=benchmark

$ROOT/services/fisherman/fisherman$VERSION

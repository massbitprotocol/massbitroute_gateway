#!/bin/bash

export DOMAIN=massbitroute.net
export RUST_LOG=debug
export SCHEDULER_ENDPOINT=http://127.0.0.1:3031
export WORKER_ID=7c7da61c-aec7-45b1-9e32-7436d4721ce0
export WORKER_ENDPOINT=http://192.168.1.34:4040/job_handle
export WORKER_SERVICE_ENDPOINT=0.0.0.0:4040
export BENCHMARK_WRK_PATH=benchmark

./fisherman
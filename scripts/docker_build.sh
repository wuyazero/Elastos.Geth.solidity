#!/usr/bin/env sh

set -e

docker build -t wuyazero/solc:build -f scripts/Dockerfile .
tmp_container=$(docker create wuyazero/solc:build sh)
mkdir -p upload
docker cp ${tmp_container}:/usr/bin/solc upload/solc-static-linux

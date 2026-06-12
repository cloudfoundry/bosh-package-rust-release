#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEBUG:=}" != "" ]]; then
  set -x
fi

dir="$(dirname "$0")"

fly -t "${CONCOURSE_TARGET:-bosh}" \
  set-pipeline \
  -p bosh-package-rust-release \
  -c "${dir}/pipeline.yml"

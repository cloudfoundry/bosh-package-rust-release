#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEBUG:=}" != "" ]]; then
  set -x
fi

build_dir="$(pwd)"
release_dir="${build_dir}/rust-release"
release_tgz="${build_dir}/release.tgz"

echo "-----> $(date): Create a release tarball"
bosh create-release \
  --dir "${release_dir}/" \
  --tarball "${release_tgz}" \
  --force

# shellcheck source=/dev/null
source start-bosh

# shellcheck source=/dev/null
source /tmp/local-bosh/director/bosh-env

echo "-----> $(date): Upload release"
bosh upload-release "${release_tgz}"

echo "-----> $(date): Upload stemcell"
bosh -n upload-stemcell "${build_dir}/stemcell/stemcell.tgz"

echo "-----> $(date): Deploy"
bosh -n -d rust deploy "${release_dir}/manifests/test.yml" \
  -v stemcell_os="${STEMCELL_OS}"

echo "-----> $(date): Run test errand"
bosh -n -d rust run-errand rust-1-test

echo "-----> $(date): Done"

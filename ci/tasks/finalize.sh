#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEBUG:=}" != "" ]]; then
  set -x
fi

cd release-repo || exit 1
git clone ../bumped-rust-release .

git config user.name "CI Bot"
git config user.email "bots@cloudfoundry.org"

version="$(cat ../semver/version)"
bosh create-release --final --version "${version}"

echo "rust/${version}" > ../release-metadata/tag-name

git add -A
git commit -m "Final release ${version}"

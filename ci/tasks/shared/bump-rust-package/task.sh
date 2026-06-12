#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEBUG:=}" != "" ]]; then
  set -x
fi

cd bumped-release-repo || exit 1
git clone "../${RELEASE_DIR}" .

git config user.name "${GIT_USER_NAME}"
git config user.email "${GIT_USER_EMAIL}"

set +x
echo "${PRIVATE_YML}" > config/private.yml
if [[ "${DEBUG:=}" != "" ]]; then
  set -x
fi

bosh vendor-package "${PACKAGE}" ../rust-release

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "Bump ${PACKAGE} via bosh vendor-package"
fi

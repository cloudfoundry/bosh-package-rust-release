#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEBUG:=}" != "" ]]; then
  set -x
fi

cd bumped-rust-release || exit 1
git clone ../rust-release .

git config user.name "CI Bot"
git config user.email "bots@cloudfoundry.org"

new_version="$(cat ../rust-stable/.resource/version)"
new_tarball="rust-${new_version}-x86_64-unknown-linux-gnu.tar.gz"

existing_blob="$(bosh blobs | awk '{print $1}' | grep 'rust-.*x86_64-unknown-linux-gnu\.tar\.gz' || true)"
if [[ -n "${existing_blob}" ]]; then
  if bosh blobs | grep -q "${new_tarball}"; then
    echo "Blob ${new_tarball} already present, nothing to do"
    exit 0
  fi
  bosh remove-blob "${existing_blob}"
fi

if [[ -f "../rust-stable/${new_tarball}" ]]; then
  tarball_src="../rust-stable/${new_tarball}"
else
  echo "Tarball not present in resource directory, downloading directly..."
  curl -fSL --retry 3 "https://static.rust-lang.org/dist/${new_tarball}" -o "/tmp/${new_tarball}"
  tarball_src="/tmp/${new_tarball}"
fi

bosh add-blob --sha2 "${tarball_src}" "${new_tarball}"

if [[ "${tarball_src}" == "/tmp/${new_tarball}" ]]; then
  rm -f "${tarball_src}"
fi

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "Bump to rust ${new_version}"
fi

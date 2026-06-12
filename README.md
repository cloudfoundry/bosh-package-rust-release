# bosh-package-rust-release

Rust release for use with `bosh vendor-package`.

Requires bosh-cli version `v2.0.36`+ to `vendor-package` and `create-release`.

## Vendoring into your release

```bash
git clone https://github.com/cloudfoundry/bosh-package-rust-release
cd ~/workspace/your-release
bosh vendor-package rust-1-linux ~/workspace/bosh-package-rust-release
```

This adds the `rust-1-linux` package to your release and creates a `spec.lock`.

The package always tracks the current Rust stable release. Since [Rust supports only one stable version at a time](https://endoflife.date/rust), 
there is a single package that is bumped automatically via CI whenever a new stable is released (~every 6 weeks).

## Using the package in your packaging script

```bash
#!/bin/bash -eu
source /var/vcap/packages/rust-1-linux/bosh/compile.env
cargo build --release ...
```

## Using the package at runtime in your job scripts

```bash
#!/bin/bash -eu
source /var/vcap/packages/rust-1-linux/bosh/runtime.env
./your-binary
```

## Environment variables set by compile.env / runtime.env

| Variable     | Description                                           |
|--------------|-------------------------------------------------------|
| `RUST_HOME`  | Path to the installed Rust toolchain package          |
| `CARGO_HOME` | Path to the Cargo home directory                      |
| `PATH`       | Prepended with `$RUST_HOME/bin` and `$CARGO_HOME/bin` |

## Keeping your vendored package up to date

Use the shared Concourse task `ci/tasks/shared/bump-rust-package` in your own pipeline:

```yaml
- task: bump-rust-package
  file: rust-release/ci/tasks/shared/bump-rust-package/task.yml
  params:
    GIT_USER_NAME: CI Bot
    GIT_USER_EMAIL: bots@example.org
    PACKAGE: rust-1-linux
    PRIVATE_YML: ((your_release_private_yml))
    RELEASE_DIR: your-release
```

## Development

### Blobstore

This release uses git-lfs as its blobstore (`config/final.yml` with `provider: local`).

### Adding a new Rust stable blob

When a new Rust stable is released, CI handles the update automatically. To update manually:

```bash
VERSION=1.95.0
TARBALL="rust-${VERSION}.x86_64-unknown-linux-gnu.tar.gz"
curl -LO "https://static.rust-lang.org/dist/${TARBALL}"
bosh add-blob --sha2 "${TARBALL}" "${TARBALL}"
rm "${TARBALL}"
git add -A && git commit -m "Bump to rust ${VERSION}"
```

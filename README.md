# `zano-docker`

Builds the `dfxswiss/zanod` image used by DFX's Zano full node — `:beta` on dfxdev, `:latest` on dfxprd.

Zano publishes **no container image**, only an official x64 release binary (build.zano.org). This repo wraps that official binary into a container; it does **not** compile Zano from source.

> **Why wrap the official binary (and not self-compile / not arm64):** the from-source `linux/arm64` build of 2.2.0 rejects canonical mainnet blocks (`wrong inputs in transactions` → `MDB_BAD_TXN`) — proven a source-level aarch64 defect, not a build-config issue (it survives `-O0` + UB-hardening). Self-compiling for amd64 just reproduces the official binary. So we package the official x64 binary and run it under Rosetta on the Apple-silicon hosts.

## Contents

- **`Dockerfile`** — downloads the official Zano x64 AppImage, extracts the statically-linked `zanod` + `simplewallet`, and asserts the version matches before packaging.
- **`include/zano-startup.sh`** — entrypoint; runs `zanod` (or `simplewallet` when `USE_WALLET_BINARY=true`).
- **`.github/workflows/zanod-dev.yaml`** — builds & pushes `:beta` on push to `develop`.
- **`.github/workflows/zanod-prd.yaml`** — builds & pushes `:latest` on push to `main`.
- **`.github/workflows/auto-release-pr.yaml`** — opens the `develop` → `main` release PR.

## Version bump

Edit `ZANO_VERSION` / `ZANO_COMMIT` in `zanod-dev.yaml` and `zanod-prd.yaml` to the desired official release (must exist at `build.zano.org/builds/zano-linux-x64-release-v<VERSION>[<COMMIT>].AppImage`).

## Run

The image is `linux/amd64`; on Apple-silicon hosts it runs under Rosetta (set `platform: linux/amd64` in compose).

```bash
docker run -t --platform linux/amd64 \
  -v ./zano-data:/home/ubuntu/.Zano \
  dfxswiss/zanod:beta --rpc-bind-ip=0.0.0.0 --rpc-bind-port=11211 --confirm-rpc-ssl-inicialization-and-disable-ssl-rpc=1
```

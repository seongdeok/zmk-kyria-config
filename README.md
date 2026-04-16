# Kyria ZMK Config

This repository is a starter ZMK user config for Kyria.

It is usable in two ways:

- GitHub Actions builds from this repo directly
- Local Docker builds using a separate containerized ZMK checkout

## Included

- GitHub Actions build workflow
- Kyria default keymap copied from upstream ZMK
- Kyria config with encoder support enabled
- `settings_reset` build for split pairing resets

## Current board setting

`build.yaml` is now set for nice!nano v2.

For this ZMK v0.3 setup, the board target is `nice_nano_v2`.

If your controller is different, change the `board` field in `build.yaml`:

- `nice_nano_v2` for nice!nano v2
- `nice_nano@1` for nice!nano v1
- `proton_c` for Proton-C builds

## Files to edit

- `config/kyria.keymap`: key layout and layer behavior
- `config/kyria.conf`: keyboard features like display and RGB
- `build.yaml`: controller board and build matrix

## Typical local builds

Build left half:

```sh
west build -d build/left -p -b nice_nano_v2 -- -DSHIELD=kyria_left -DZMK_CONFIG="$PWD/config"
```

Build right half:

```sh
west build -d build/right -p -b nice_nano_v2 -- -DSHIELD=kyria_right -DZMK_CONFIG="$PWD/config"
```

If you use Proton-C, replace `nice_nano_v2` with `proton_c` in both commands.

## Local Docker build

This repo is primarily a ZMK config repo for GitHub Actions, but local Docker builds are now set up too.

Files added for Docker:

- `docker-compose.yml`
- `.docker/Dockerfile`
- `scripts/docker-setup.sh`
- `scripts/docker-build.sh`

The Docker flow uses an isolated ZMK checkout in a Docker volume at `/workspaces/zmk`, while this repo is mounted as `/workspaces/zmk-config`.
That means your repo stays clean and the upstream ZMK source does not get cloned into this working tree.

### 1. Initialize the Docker workspace

```sh
docker compose run --rm zmk ./scripts/docker-setup.sh
```

This will:

- build the local Docker image based on the official ZMK dev container
- clone `zmk` v0.3 into the container volume
- run `west init -l app/`
- run `west update`
- install required Python packages

### 2. Build firmware locally

Build everything:

```sh
docker compose run --rm zmk ./scripts/docker-build.sh all
```

Build only the left half:

```sh
docker compose run --rm zmk ./scripts/docker-build.sh left
```

Build only the right half:

```sh
docker compose run --rm zmk ./scripts/docker-build.sh right
```

Build the settings reset firmware:

```sh
docker compose run --rm zmk ./scripts/docker-build.sh reset
```

Artifacts will be written to:

- `out/firmware/kyria_left.uf2`
- `out/firmware/kyria_right.uf2`
- `out/firmware/settings_reset.uf2`

Intermediate build directories will be written under `out/build/`.

### 3. Open an interactive shell in the container

```sh
docker compose run --rm zmk bash
```

Inside the container, the ZMK app lives at `/workspaces/zmk/app` and this config repo lives at `/workspaces/zmk-config`.

### Flashing note

For nice!nano v2, local Docker builds produce UF2 files normally, but flashing is still done outside the container by copying the UF2 file onto the board in bootloader mode.

## Next step

1. Adjust `build.yaml` if your MCU board is not nice!nano v2.
2. Edit `config/kyria.keymap` to your preferred layout.
3. Run `docker compose run --rm zmk ./scripts/docker-build.sh all` for local builds, or push to GitHub for Actions builds.
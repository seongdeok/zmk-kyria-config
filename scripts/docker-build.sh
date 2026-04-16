#!/usr/bin/env bash

set -euo pipefail

target="${1:-all}"
board="${BOARD:-nice_nano_v2}"
zmk_dir="${ZMK_DIR:-/workspaces/zmk}"
config_dir="${ZMK_CONFIG_DIR:-/workspaces/zmk-config/config}"
repo_dir="${ZMK_CONFIG_REPO:-/workspaces/zmk-config}"
app_dir="${zmk_dir}/app"
out_dir="${repo_dir}/out"
build_root="${out_dir}/build"
firmware_dir="${out_dir}/firmware"

if [[ ! -d "${zmk_dir}/.west" ]]; then
    echo "ZMK workspace is not initialized. Run ./scripts/docker-setup.sh first." >&2
    exit 1
fi

mkdir -p "${build_root}" "${firmware_dir}"

copy_artifact() {
    local build_dir="$1"
    local artifact_name="$2"
    local artifact_path=""

    if [[ -f "${build_dir}/zephyr/zmk.uf2" ]]; then
        artifact_path="${build_dir}/zephyr/zmk.uf2"
    elif [[ -f "${build_dir}/zephyr/zmk.hex" ]]; then
        artifact_path="${build_dir}/zephyr/zmk.hex"
    else
        echo "No firmware artifact found in ${build_dir}/zephyr" >&2
        exit 1
    fi

    cp "${artifact_path}" "${firmware_dir}/${artifact_name}.${artifact_path##*.}"
}

build_target() {
    local side="$1"
    local shield="$2"
    local build_dir="${build_root}/${side}"

    cd "${app_dir}"
    west build -d "${build_dir}" -p -b "${board}" -- -DSHIELD="${shield}" -DZMK_CONFIG="${config_dir}"
    copy_artifact "${build_dir}" "${shield}"
}

case "${target}" in
    left)
        build_target left kyria_left
        ;;
    right)
        build_target right kyria_right
        ;;
    reset)
        build_target reset settings_reset
        ;;
    all)
        build_target left kyria_left
        build_target right kyria_right
        build_target reset settings_reset
        ;;
    *)
        echo "Usage: ./scripts/docker-build.sh [left|right|reset|all]" >&2
        exit 1
        ;;
esac

echo "Artifacts written to ${firmware_dir}."
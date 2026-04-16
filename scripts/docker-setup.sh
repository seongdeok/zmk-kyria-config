#!/usr/bin/env bash

set -euo pipefail

zmk_dir="${ZMK_DIR:-/workspaces/zmk}"
zmk_ref="${ZMK_REF:-v0.3}"

if [[ ! -d "${zmk_dir}/.git" ]]; then
    git clone --branch "${zmk_ref}" --single-branch https://github.com/zmkfirmware/zmk.git "${zmk_dir}"
fi

cd "${zmk_dir}"

if [[ ! -d .west ]]; then
    west init -l app/
fi

west update
west zephyr-export

if west help 2>/dev/null | grep -q "packages"; then
    west packages pip --install
else
    echo "Skipping 'west packages pip --install' because this workspace does not provide the west-packages extension."
fi

echo "ZMK Docker workspace is ready at ${zmk_dir}."
#!/usr/bin/env bash
set -euo pipefail

# Prevent multiple sourcing
if [ -n "${__DOCKER_LAUNCHER_SH_SOURCED:-}" ]; then
    return
fi
readonly __DOCKER_LAUNCHER_SH_SOURCED=1

readonly DOCKER_IMAGE_NAME="lumerical:latest"

readonly HOST_X11_SOCKET="/tmp/.X11-unix"
readonly TARGET_X11_SOCKET="/tmp/.X11-unix"
readonly DISPLAY_NUM="${DISPLAY:-:0}"

__docker_launcher_load_image() {
    local -r image="$1"

    docker load -i "${image}"
}

__docker_launcher_is_image() {
    local -r image_name="$1"

    if docker image inspect "$image_name" >/dev/null 2>&1; then
        echo "Image exists"
        return 0
    else
        echo "Image does not exist"
        return 1
    fi
}

docker_launcher_load_image() {
    if __docker_launcher_is_image "lumerical:latest"; then
        return 0
    fi

    # Try to load image if DOCKER_IMAGE_TAR has been set 
    if [[ -n "${DOCKER_IMAGE_TAR}" ]]; then
        __docker_launcher_load_image "${DOCKER_IMAGE_TAR}"
    fi
}

docker_launcher_start_lumerical() {
    local -r host_uid=$(id -u)
    local -r host_gid=$(id -g)
    local -r host_user=$(id -un)
    local -r host_group=$(id -gn)

    user_flags=(
        -e "HOST_UID=${host_uid}"
        -e "HOST_GID=${host_gid}"
        -e "HOST_USR=${host_user}"
        -e "HOST_GRP=${host_group}"
    )

    net_flags=(
        --cap-add=NET_ADMIN
        --device /dev/net/tun
    )

    x11_flags=(
        -e "QT_QPA_PLATFORM=xcb"
        -e "DISPLAY=${DISPLAY_NUM}"
        -e "XDG_RUNTIME_DIR=/tmp"
        -v "${HOST_X11_SOCKET}:${TARGET_X11_SOCKET}"
    )

    amd_flags=(
        --device=/dev/kfd
        --device=/dev/dri
        --group-add video
    )

    # Fix this PWD later
    local -r config_json="-v${PWD}/secrets/config.json:/tmp/config.json:ro"
    local -r workspace="-v/home/jatsekku/lumerical_test:/home/lumerical"
    local -r docker_img="${DOCKER_IMAGE_NAME}"
    local -r user_entrypoint="/scripts/lumerical.sh start"

    # Run container
    docker run -it \
        "${user_flags[@]}" \
        "${net_flags[@]}" \
        "${x11_flags[@]}" \
        "${amd_flags[@]}" \
        "$config_json" \
        "$workspace" \
        "$docker_img" \
        /bin/bash -c "$user_entrypoint"
}

docker_launcher_main() {
    docker_launcher_load_image
    docker_launcher_start_lumerical
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    docker_launcher_main
fi


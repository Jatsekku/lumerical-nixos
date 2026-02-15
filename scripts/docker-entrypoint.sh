#!/usr/bin/env bash
set -euo pipefail

# Prevent multiple sourcing
if [ -n "${__DOCKER_ENTRYPOINT_SH_SOURCED:-}" ]; then
    return
fi
readonly __DOCKER_ENTRYPOINT_SH_SOURCED=1

source "/scripts/openconnect.sh"

readonly TARGET_UID=${HOST_UID:-1000}
readonly TARGET_GID=${HOST_GID:-1000}
readonly TARGET_USER_NAME=${HOST_USR:-lumerical}
readonly TARGET_GROUP_NAME=${HOST_GRP:-lumerical}

__docker_entrypoint_does_gid_exists() {
    local -r gid="$1"

    if getent group "$gid" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

__docker_entrypoint_add_group() {
    local -r gid="$1"
    local -r name="$2"

    # Create group wiith given GID and name
    groupadd -g "${gid}" "${name}"
}

__docker_entrypoint_handle_group() {
    local -r gid="$1"
    local -r group_name="$2"

    if ! __docker_entrypoint_does_gid_exists "${gid}"; then
        __docker_entrypoint_add_group "${gid}" "${group_name}"
    fi
}

__docker_entrypoint_does_uid_exists() {
    local -r uid="$1"

    if id -u "${uid}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

__docker_entrypoint_add_user() {
    local -r uid="$1"
    local -r user_name="$2"
    local -r gid="$3"

    # Create user
    # -u -> with given UID
    # -g -> with given primary GID
    # -m -> with home directory
    # -s -> specified shell
    useradd -u "${uid}" -g "${gid}" -m -s /bin/bash "${user_name}"
}

__docker_entrypoint_handle_user() {
    local -r uid="$1"
    local -r user_name="$2"
    local -r gid="$3"

    if ! __docker_entrypoint_does_uid_exists "${uid}"; then
        __docker_entrypoint_add_user "${uid}" "${user_name}" "${gid}"
    fi
}

__docker_entrypoint_ensure_home_dir() {
    local -r uid="$1"
    local -r gid="$2"

    # Get home dir path
    local -r home_dir=$(getent passwd "${uid}" | cut -d: -f6)
    # Create dir (if needed)
    mkdir -p "${home_dir}"
    # Set ownership
    chown "${uid}:${gid}" "${home_dir}"
}

__docker_entrypoint_run_as_user() {
    local -r uid="$1"
    local -r gid="$2"
    shift 2

    exec gosu "${uid}:${gid}" "$@"
}

docker_entrypoint_main() {
    local -r uid="$1"
    local -r gid="$2"
    local -r user_name="$3"
    local -r group_name="$4"
    shift 4

    __docker_entrypoint_handle_group "${gid}" "${group_name}"
    __docker_entrypoint_handle_user "${uid}" "${user_name}" "${gid}"
    __docker_entrypoint_ensure_home_dir "${uid}" "${gid}"
    __docker_entrypoint_run_as_user "${uid}" "${gid}" "$@"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    # Connect via VPN as root
    openconnect_connect_json
    docker_entrypoint_main \
        "${TARGET_UID}" \
        "${TARGET_GID}" \
        "${TARGET_USER_NAME}" \
        "${TARGET_GROUP_NAME}" \
        "$@"
fi


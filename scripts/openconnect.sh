#!/usr/bin/bash
set -euo pipefail

# Prevent multiple sourcing
if [ -n "${__OPENCONNECT_SH_SOURCED:-}" ]; then
    return
fi
readonly __OPENCONNECT_SH_SOURCED=1

readonly JSON_CONFIG_FILE="/tmp/config.json"

__openconnect_install() {
    apt-get install -y openconnect jq sudo
}

__openconnect_connect() {
    local -r protocol="$1"
    local -r server="$2"
    local -r user="$3"
    local -r password="$4"

    echo "${password}" | sudo openconnect \
        "${server}" \
        --protocol="${protocol}" \
        --user="${user}" \
        -b --passwd-on-stdin
}

__openconnect_connect_json() {
    local -r json_file="$1"

    if [[ ! -f "$json_file" ]]; then
        echo "JSON config file not found: $json_file"
        return 1
    fi

    local -r protocol=$(jq -r '.protocol' "${json_file}")
    local -r server=$(jq -r '.server' "${json_file}")
    local -r user=$(jq -r '.user' "${json_file}")
    local -r password=$(jq -r '.password' "${json_file}")

    __openconnect_connect "${protocol}" "${server}" "${user}" "${password}"
}

openconnect_connect_json() {
    __openconnect_connect_json "${JSON_CONFIG_FILE}"
}

openconnect_main() {
    local -r command="$1"

    case "$command" in
        install)
            __openconnect_install
            ;;
        connect)
            __openconnect_connect_json "${JSON_CONFIG_FILE}"
            ;;
        *)
            return 1
            ;;
        esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    openconnect_main "${1:-}"
fi

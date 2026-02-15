#!/usr/bin/env bash
set -euo pipefail

# Prevent multiple sourcing
if [ -n "${__DOCKER_SH_SOURCED:-}" ]; then
    return
fi
readonly __DOCKER_SH_SOURCED=1

# Paths of this script
readonly DOCKER_SH_PATH=$(realpath "${BASH_SOURCE[0]}")
readonly DOCKER_SH_DIR=$(dirname "${DOCKER_SH_PATH}")

# Source docker-launcher.sh
readonly DOCKER_LAUNCHER_SH_PATH="${DOCKER_SH_DIR}/docker-launcher.sh"
source "${DOCKER_LAUNCHER_SH_PATH}"

readonly DOCKERFILE_DIR="${DOCKER_SH_DIR}/../."

# Usename for push/pull utilities
readonly DOCKERHUB_DOWNSTREAM_USER=${DOCKERHUB_DOWNSTREAM_USER:-jatsekku}
readonly DOCKERHUB_UPSTREAM_USER=${DOCKERHUB_UPSTREAM_USER:-jatsekku}

__docker_build_image() {
    DOCKER_BUILDKIT=1 docker build \
    --rm \
    -t "${DOCKER_IMAGE_NAME}" \
    "${DOCKERFILE_DIR}"
}

__docker_push_image() {
    docker push "${DOCKERHUB_UPSTREAM_USER}/${DOCKER_IMAGE_NAME}"
}

__docker_pull_image() {
    local -r remote_ref="${DOCKERHUB_DOWNSTREAM_USER}/${DOCKER_IMAGE_NAME}"
    local -r local_ref="${DOCKER_IMAGE_NAME}"

    docker pull "${remote_ref}"
    docker tag "${remote_ref}" "${local_ref}"
}

docker_main() {
    local -r command="$1"

    case "$command" in
        build)
            __docker_build_image
            ;;
        push)
            __docker_push_image
            ;;
        pull)
            __docker_pull_image
            ;;
        start)
            docker_launcher_start_lumerical
            ;;
        *)
            return 1
            ;;
        esac
}

docker_main "$1"

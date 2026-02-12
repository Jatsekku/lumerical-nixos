#!/usr/bin/bash
set -euo pipefail

# Prevent multiple sourcing
if [ -n "${__LUMERICAL_SH_SOURCED:-}" ]; then
    return
fi
readonly __LUMERICAL_SH_SOURCED=1

# Config containing license server
readonly JSON_CONFIG_FILE="/tmp/config.json"

# Path to .deb parts of Lumerical
readonly LUMERICAL_DEB_PARTS_DIR="/lumerical/deb"
readonly LUMERICAL_DEB_FINAL_FILE="/lumerical.deb"

# Paath to Lumerical launcher
readonly LUMERICAL_LAUNCHER_PATH="/opt/lumerical/v232/bin/launcher"

__lumerical_combine_deb_parts() {
    local -r deb_parts_dir="$1"
    local -r final_deb_path="$2"

    cat "${deb_parts_dir}"/* > "${final_deb_path}"
}

__lumerical_install_dependencies() {
    apt-get install -y --no-install-recommends \
        debianutils \
        freeglut3 \
        libapparmor1 \
        libasound2 \
        libasyncns0 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libatomic1 \
        libatspi2.0-0 \
        libavahi-client3 \
        libavahi-common3 \
        libblkid1 \
        libbrotli1 \
        libbsd0 \
        libbz2-1.0 \
        libc6 \
        libcairo-gobject2 \
        libcairo2 \
        libcap2 \
        libcom-err2 \
        libcrypt1 \
        libcups2 \
        libdatrie1 \
        libdrm2 \
        libegl1 \
        libelf1 \
        libepoxy0 \
        libexpat1 \
        libffi8 \
        libflac8 \
        libfontconfig1 \
        libfreetype6 \
        libfribidi0 \
        libgbm1 \
        libgcrypt20 \
        libgdk-pixbuf-2.0-0 \
        libglib2.0-0 \
        libglu1-mesa \
        libglvnd0 \
        libglx0 \
        libgmp10 \
        libgnutls30 \
        libgpg-error0 \
        libgraphite2-3 \
        libgssapi-krb5-2 \
        libgtk-3-0 \
        libharfbuzz0b \
        libhogweed6 \
        libice6 \
        libidn2-0 \
        libjpeg-turbo8 \
        libjpeg62 \
        libk5crypto3 \
        libkeyutils1 \
        libkrb5-3 \
        libkrb5support0 \
        libltdl7 \
        liblz4-1 \
        liblzma5 \
        libmd0 \
        libmount1 \
        libnettle8 \
        libnsl2 \
        libnspr4 \
        libnss3 \
        libnuma1 \
        libogg0 \
        libopengl0 \
        libopus0 \
        libp11-kit0 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libpangoft2-1.0-0 \
        libpcre2-8-0 \
        libpcre3 \
        libpcsclite1 \
        libpixman-1-0 \
        libpulse0 \
        libselinux1 \
        libsm6 \
        libsndfile1 \
        libsystemd0 \
        libtasn1-6 \
        libthai0 \
        libunistring2 \
        libuuid1 \
        libvorbis0a \
        libvorbisenc2 \
        libwayland-client0 \
        libwayland-cursor0 \
        libwayland-egl1 \
        libwayland-server0 \
        libx11-6 \
        libx11-xcb1 \
        libxau6 \
        libxcb-cursor0 \
        libxcb-dri2-0 \
        libxcb-dri3-0 \
        libxcb-glx0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-present0 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-render0 \
        libxcb-shape0 \
        libxcb-shm0 \
        libxcb-sync1 \
        libxcb-util1 \
        libxcb-xfixes0 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxdmcp6 \
        libxext6 \
        libxfixes3 \
        libxft2 \
        libxi6 \
        libxinerama1 \
        libxkbcommon-x11-0 \
        libxkbcommon0 \
        libxkbfile1 \
        libxrandr2 \
        libxrender1 \
        libxshmfence1 \
        libxslt1.1 \
        libxtst6 \
        libxxf86vm1 \
        libzstd1 \
        xfonts-100dpi \
        xfonts-75dpi \
        libxt6
}

__lumerical_install_deb() {
    # Install Lumerical using .deb package
    dpkg -i "${LUMERICAL_DEB_FINAL_FILE}"

    # Fix dependecies
    apt-get -f install -y
}

__lumerical_remove_deb() {
    rm "${LUMERICAL_DEB_FINAL_FILE}"
}

__lumerical_full_install() {
    __lumerical_combine_deb_parts "${LUMERICAL_DEB_PARTS_DIR}" "${LUMERICAL_DEB_FINAL_FILE}"
    __lumerical_install_dependencies
    __lumerical_install_deb
    __lumerical_remove_deb
}

__lumerical_set_license_server() {
    local -r json_file="$1"

    local -r license_server=$(jq -r '.license_server' "${json_file}")
    export ANSYSLMD_LICENSE_FILE="${license_server}"
}

__lumerical_start() {
    "$LUMERICAL_LAUNCHER_PATH"
}

lumerical_main() {
    local -r command="$1"

    case "$command" in
        install)
            __lumerical_full_install
            ;;
        start)
            __lumerical_set_license_server "${JSON_CONFIG_FILE}"
            __lumerical_start
            ;;
        *)
            return 1
            ;;
        esac
}

lumerical_main "$1"

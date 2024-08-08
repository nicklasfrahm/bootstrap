#!/usr/bin/env bash
# Usage: wget -O - -o /dev/null https://raw.githubusercontent.com/nicklasfrahm/bootstrap/main/bootstrap.sh | bash

DEBUG=${DEBUG:-false}

if [ "$DEBUG" == "true" ]; then
    set -x
fi
set -eou pipefail

print_info() {
    green='\033[0;32m'
    reset='\033[0m'
    echo -e "${green}inf: ${reset}$1"
}

print_error() {
    red='\033[0;31m'
    reset='\033[0m'
    echo -e "${red}err: ${reset}$1"
}

ensure_apt_packages() {
    desired_packages="$*"

    missing_packages=()

    for desired_package in $desired_packages; do
        if ! dpkg -l | grep -q "$desired_package"; then
            missing_packages+=("$desired_package")
        fi
    done

    if [ ${#missing_packages[@]} -gt 0 ]; then
        print_info "Installing missing packages ..."
        sudo apt update
        sudo apt install -y "${missing_packages[@]}"
    fi
}

ensure_gvm() {
    print_info "Installing gvm ..."

    if [ ! -d "$HOME/.gvm" ]; then

        ensure_apt_packages "curl" "bison"

        bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

        # It will only be available after installation,
        # so this avoids the shellcheck warning.
        # shellcheck source=/dev/null
        source "$HOME/.gvm/scripts/gvm"
    fi

    print_info "Installing gvm ... done"
}

ensure_go() {
    print_info "Installing go ..."

    go_version_regex='go[0-9]+(\.[0-9]+){1,2}$'

    # List all go version and install the latest stable.
    stable_version=$(gvm listall | grep -oE "${go_version_regex}" | sort -V | tail -n 1)

    gvm install "$stable_version" -B >/dev/null

    # HACK: Avoid this issue: https://github.com/moovweb/gvm/issues/188
    gvm use "$stable_version" --default 2>/dev/null || true

    # Remove all other installed versions.
    mapfile -t installed_versions < <(gvm list | grep -oE "${go_version_regex}")

    for installed_version in "${installed_versions[@]}"; do
        if [ "$installed_version" == "$stable_version" ]; then
            continue
        fi

        # HACK: Avoid this issue: https://github.com/moovweb/gvm/issues/188
        gvm use "$installed_version" 2>/dev/null || true

        go clean -modcache

        # HACK: Avoid this issue: https://github.com/moovweb/gvm/issues/188
        gvm use "$stable_version" 2>/dev/null || true

        gvm uninstall "$installed_version"
    done

    print_info "Installing go ... done"
}

ensure_arkade() {
    print_info "Installing arkade ..."

    if ! command -v arkade &>/dev/null; then
        curl -sLS https://get.arkade.dev | sudo sh
    fi

    print_info "Installing arkade ... done"
}

main() {
    print_info "Installing developer tools ..."

    ensure_gvm
    ensure_go
    ensure_arkade
}

main "$@"

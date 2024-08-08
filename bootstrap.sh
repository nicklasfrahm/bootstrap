#!/usr/bin/env bash
# Usage: wget -O - -o /dev/null https://raw.githubusercontent.com/nicklasfrahm/bootstrap/main/bootstrap.sh | sudo bash

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

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "script must be run as root or using sudo"
        exit 1
    fi
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
        apt update
        apt install -y "${missing_packages[@]}"
    fi
}

install_gvm() {
    print_info "Installing gvm ..."

    ensure_apt_packages "curl" "bison"

    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
}

main() {
    print_info "Bootstrapping developer tools ..."

    check_root

    install_gvm
}

main "$@"

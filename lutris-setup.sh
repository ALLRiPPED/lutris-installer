#!/bin/bash
#
# Description : Easy lutris Setup
# Author      : Supreme Team
# Version     : 1.0
#
clear

readonly INSTALL_DIR="/tmp/"
readonly MUGEN_INSTALLER_URL="https://github.com/SupremePi/lutris-Installer/raw/main/lutris-installer.sh"

install() {
    local IS_RASPBERRYPI
    IS_RASPBERRYPI=$(grep </proc/cpuinfo 'BCM2711')
    cd "$INSTALL_DIR" || exit 1

    if [[ -z $IS_RASPBERRYPI ]]; then
        echo "Sorry.The mugen installer is only available for Raspberry Pi 4 boards."
        sleep 5
        exit
    fi

    if [[ ! -d $HOME/RetroPie-Setup ]]; then
        echo "Sorry.The lutris installer is only available for builds with RetroPie installed."
        sleep 5
        exit
    fi

    wget -q "$MUGEN_INSTALLER_URL" 
    sudo chmod +x /tmp/lutris-installer.sh 2>/dev/null
    /tmp/lutris-installer.sh
    sudo rm /tmp/lutris-installer.sh
    clear
    exit 1
}

install

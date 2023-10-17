#!/bin/bash

# This script set's up an Ubuntu WSL environment for running ansible commands

check_root_privileges() {
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
  fi
}

check_root_privileges

apt update -y && apt install python3-pip -y

pip3 install ansible==8.4.0 ansible-core==2.15.4 docker-py docker-compose

wsl_conf_file="/etc/wsl.conf"
automount_options=$(cat << EOF
[automount]
enabled = true
options = metadata,umask=022
EOF
)

check_file_contains_automount_options() {
  if grep -Fxq "$automount_options" $wsl_conf_file; then
    echo "wsl.conf already contains automount options"
  else
    echo "$automount_options" >> $wsl_conf_file
  fi
}

check_file_contains_automount_options

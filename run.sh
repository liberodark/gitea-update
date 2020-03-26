#!/bin/bash
#
# About: Update Gitea automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.1"

echo "Welcome on Gitea Update Script $version"

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

name="gitea"
version="1.11.3"
date=$(date +%Y.%m.%d_%H-%M-%S)
old_version="3"
destination="/opt/gitea/"
lock="/tmp/gitea.lock"
remove() { ls "$destination""$name"_old-* | head -n -"$old_version" | xargs rm -f; }

exec 9>"${lock}"
flock -n 9 || exit

install(){
      echo "Downloading Gitea "$version""
      systemctl stop gitea
      pushd "$destination" || exit
      mv gitea gitea_old-"$date"
      wget -O "$name" "https://github.com/go-gitea/gitea/releases/download/v"$version"/gitea-"$version"-linux-amd64" &> /dev/null
      chmod +x gitea
      echo "Old Gitea is Cleaned"
      "remove"
      popd || exit
      echo "Gitea "$version" is Installed"
      systemctl start gitea
      }

install

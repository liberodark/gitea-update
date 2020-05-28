#!/bin/bash
#
# About: Update Gitea automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.4"

echo "Welcome on Gitea Update Script $version"

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

name="gitea"
#version="1.11.3"
date=$(date +%Y.%m.%d_%H-%M-%S)
old_version="3"
destination="/opt/gitea/"
lock="/tmp/gitea.lock"
remove() { ls "$destination""$name"_old-* | head -n -"$old_version" | xargs rm -f; }
#remove() { find "$destination" -maxdepth 1 -name 'gitea_old-*' | head -n -"$old_version" | xargs rm -f; }

exec 9>"${lock}"
flock -n 9 || exit

#=================================================
# ASK
#=================================================

echo "What version Download ? Ex : 1.11.3"
read -r version

install(){
      echo "Downloading Gitea $version"
      pushd "$destination" || exit
      wget -Nnv -O gitea_new "https://github.com/go-gitea/gitea/releases/download/v$version/gitea-$version-linux-amd64" &> /dev/null || exit
      #wget -Nnv -O gitea_new "https://dl.gitea.io/gitea/$version/gitea-$version-linux-amd64" &> /dev/null || exit
      systemctl stop gitea
      mv gitea gitea_old-"$date"
      mv gitea_new gitea
      chmod +x gitea
      echo "Old Gitea is Cleaned"
      "remove"
      popd || exit
      echo "Gitea $version is Installed"
      systemctl start gitea
      }

install

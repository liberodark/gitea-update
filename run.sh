#!/bin/bash
#
# About: Update Gitea automatically
# Author: liberodark
# License: GNU GPLv3

version="0.0.2"
echo "Welcome on Gitea Update Script ${version}"
gitea_version=$1

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

name="gitea"
date=$(date +%Y.%m.%d_%H-%M-%S)
old_version="3"
destination="/opt/gitea/"
lock="/tmp/gitea.lock"
remove() { ls "${destination}""${name}"_old-* | head -n -"${old_version}" | xargs rm -f; }

usage ()
{
     echo "usage: script -v 1.17.3"
     echo "options :"
     echo "v : 1.17.3"
     echo "-h: Show help"
}

exec 9>"${lock}"
flock -n 9 || exit

#=================================================
# ASK
#=================================================

set_version(){
gitea_version="$1"
}

install(){
      echo "Downloading Gitea ${gitea_version}"
      pushd "${destination}" || exit
      wget -Nnv -O gitea_new "https://github.com/go-gitea/gitea/releases/download/v${gitea_version}/gitea-${gitea_version}-linux-amd64" &> /dev/null || exit
      systemctl stop gitea
      mv gitea "gitea_old-${date}"
      mv gitea_new gitea
      chmod +x gitea
      echo "Old Gitea is Cleaned"
      "remove"
      popd || exit
      echo "Gitea ${gitea_version} is Installed"
      systemctl start gitea
      }

parse_args ()
{
    while [ $# -ne 0 ]
    do
        case "${1}" in
            -v)
                shift
                set_version "$@"
                install
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Invalid argument : ${1}" >&2
                usage >&2
                exit 1
                ;;
        esac
        shift
    done

}

parse_args "$@"

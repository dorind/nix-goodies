#!/bin/sh

#
# Copyright(c) Dorin Duminica. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
#
#   1. Redistributions of source code must retain the above copyright notice, 
#      this list of conditions and the following disclaimer.
#
#   2. Redistributions in binary form must reproduce the above copyright notice,
#      this list of conditions and the following disclaimer in the documentation
#      and/or other materials provided with the distribution.
#
#   3. Neither the name of the copyright holder nor the names of its 
#      contributors may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

#
# homepage: https://github.com/nodesource/distributions/blob/master/README.md
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""
SNAME=$(basename $0)
SCRIPT_URL="https://github.com/nodesource/distributions/blob/master/README.md"

PKG_DEB="wget build-essential"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

# bail, exec_cmd_nobail and exec_cmd shamelessly stolen from 
# https://deb.nodesource.com/setup_14.x
bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

fetch_install() {
    echo "$SNAME checking for latest nodejs version"
    URL_DL=$(wget -qO- $SCRIPT_URL | grep -Eo https:\/\/deb\.nodesource\.com\/setup_[0-9]+.x | sort -V | tail -n1)
    if [ -z "$URL_DL" ]; then
        echo "$SNAME Error parsing download URL, take a look at fetch_install()"
        exit 1
    fi
    echo "$SNAME latest version $URL_DL"
    exec_cmd "wget -qO- $URL_DL | bash -" &&
        apt-get install -y nodejs
}

install_nodejs() {
    install_deps &&
        fetch_install
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
    esac
done

install_nodejs



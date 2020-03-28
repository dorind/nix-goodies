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
# homepage: https://golang.org/
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""

SNAME=$(basename $0)
GOLANG_URL_DL="https://golang.org/dl/"
GOLANG_INSTALL_LOCATION="/usr/local"

install_deps() {
    echo "$SNAME installing dependencies..."
    apt-get install -y wget
}

fetch_install() {
    echo "$SNAME checking for latest golang version"
    URL_DL=$(wget -qO- https://golang.org/dl/ | grep -Eo \"https*\:*\/\/.*go[0-9]*\.[0-9]*\.[0-9]*\.linux-amd64\.tar\.gz\" | tr -d '"' | head -n 1)
    GOLANG_VER_LATEST=$(basename $URL_DL)
    echo "Downloading $GOLANG_VER_LATEST from from $URL_DL"
    # download
    sudo -u $CURRENT_USER wget $URL_DL &&
    # extract sources
    echo "$SNAME extracting $GOLANG_VER_LATEST to $GOLANG_INSTALL_LOCATION" &&
    CLEANUP_LIST="$GOLANG_VER_LATEST" &&
    tar -C $GOLANG_INSTALL_LOCATION -xzf $GOLANG_VER_LATEST
}

exports() {
    SHRC="/home/$CURRENT_USER"
    if [ "$(which bash)" != "" ]; then
        SHRC="$SHRC/.bashrc"
    elif [ "$(which zsh)" != "" ]; then
        SHRC="$SHRC/.zshrc"
    else
        echo "$SNAME unhandled case, bailing out!"
        exit 1
    fi
    # export paths
    echo "" >> $SHRC
    echo "# golang" >> $SHRC
    echo "export PATH=\$PATH:$GOLANG_INSTALL_LOCATION/go/bin" >> $SHRC
    echo "" >> $SHRC
    echo "$SNAME reloading $SHRC"
    su $CURRENT_USER
    . $SHRC
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then exit 0; fi
    echo "cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_golang() {
    install_deps &&
    fetch_install &&
    cleanup $@ &&
    exports
}

install_golang $@



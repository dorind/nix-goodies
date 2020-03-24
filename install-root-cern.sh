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
# homepage: https://root.cern.ch
#

CURRENT_USER=""

if [ $SUDO_USER ]; then 
    CURRENT_USER=$SUDO_USER
else 
    CURRENT_USER=$(whoami)
fi

SNAME=$(basename $0)
ROOT_URL_DL_BASE="https://root.cern.ch/download/"
ROOT_URL_DL_LIST=$ROOT_URL_DL_BASE
ROOT_VER_LATEST=""

install_deps() {
    echo "$SNAME installing dependencies..."
    apt-get install -y wget build-essential manpages-dev llvm cmake \
        libx11-dev libxpm-dev libxft-dev libxext-dev libtiff5-dev \
        libgif-dev libgsl-dev libpython-dev libkrb5-dev libxml2-dev \
        libssl-dev default-libmysqlclient-dev libpq-dev libqt4-opengl-dev \
        libgl2ps-dev libpcre-ocaml-dev libgraphviz-dev libdpm-dev \
        unixodbc-dev libsqlite3-dev libfftw3-dev libcfitsio-dev dcap-dev \
        libldap2-dev libavahi-compat-libdnssd-dev
}

fetch_src() {
    echo "$SNAME checking for latest ROOT version"
    ROOT_VER_LATEST=$(wget -qO- $ROOT_URL_DL_LIST | grep -Eo \"root_v[0-9]+\.[0-9]+\.[0-9]+\.source\.tar\.gz\" | uniq | tr -d '"' | tail -n 1)
    echo "$SNAME latest ROOT version: $ROOT_VER_LATEST"
    URL_DL=$ROOT_URL_DL_BASE$ROOT_VER_LATEST
    echo "Downloading ROOT from $URL_DL"
    # download
    sudo -u $CURRENT_USER wget $URL_DL &&
    # extract sources
    echo "$SNAME extracting sources..." &&
    sudo -u $CURRENT_USER tar -zxf $ROOT_VER_LATEST &&
    # switch to build dir
    cd root*/build
}

build() {
    # configure
    echo "$SNAME configuring..." &&
    cmake ../ -DCMAKE_INSTALL_PREFIX=/usr/opt/root -Dgnuinstall=ON &&
    # build
    echo "$SNAME building..." &&
    make -j$(nproc)
}

make_install() {
    # install
    echo "$SNAME installing..." &&
    make install &&
    # refresh dynamic linker
    ldconfig
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
    echo "export ROOTSYS=/usr/opt/root" >> $SHRC
    echo "export PATH=\$PATH:\$ROOTSYS/bin" >> $SHRC
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$ROOTSYS/lib/root" >> $SHRC
    echo "$SNAME reloading $SHRC"
    su $CURRENT_USER
    . $SHRC
}

install_root() {
    install_deps &&
    fetch_src &&
    build &&
    make_install &&
    exports
}

install_root



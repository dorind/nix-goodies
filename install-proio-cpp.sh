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
# homepage: https://github.com/proio-org/proio
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST="proio-cpp"

install_deps() {
    apt-get install -y git make cmake
}

fetch_src() {
    sudo -u $CURRENT_USER git clone https://github.com/proio-org/cpp-proio.git proio-cpp &&
    cd ./proio-cpp &&
    git submodule init && 
    git submodule update
}

make_install() {
    sudo -u $CURRENT_USER mkdir build && 
    cd build && 
    sudo -u $CURRENT_USER cmake ../ && 
    sudo -u $CURRENT_USER make -j$(nproc) && 
    sudo -u $CURRENT_USER make test -j$(nproc) && 
    make install &&
    ldconfig
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then exit 0; fi
    echo "cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_proio_cpp() {
    install_deps &&
    fetch_src &&
    make_install
}

install_proio_cpp &&
cleanup $@



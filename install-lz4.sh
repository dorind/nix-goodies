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
# homepage: http://www.lz4.org https://github.com/lz4/lz4
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST="lz4"

install_deps() {
    apt-get install -y build-essential git make cmake
}

fetch_src() {
    sudo -u $CURRENT_USER git clone https://github.com/lz4/lz4.git lz4 && 
    cd lz4
}

build_install() {
    sudo -u $CURRENT_USER make cmake -j$(nproc) &&
    cmake --build contrib/cmake_unofficial/. -- install
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then exit 0; fi
    echo "cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_lz4() {
    install_deps &&
    fetch_src &&
    build_install
}

install_lz4 &&
cleanup $@



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
# homepage: https://www.flashrom.org/ https://github.com/flashrom/flashrom/
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST="build_flashrom"
SNAME=$(basename $0)

PKG_DEB="build-essential git make libpci-dev pciutils zlib1g-dev"
PKG_DEB="$PKG_DEB libftdi-dev libusb-dev libusb-1.0-0-dev"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "$SNAME fetching source..."
    sudo -u $CURRENT_USER git clone https://github.com/flashrom/flashrom build_flashrom && 
        cd build_flashrom
}

git_checkout_latest() {
    echo "$SNAME checking out latest version..."
    # list git tags
    #   find tag formatted as vX.Y, where X, Y are numbers
    #       sort naturally i.e. human versioning
    #           return last item from sorted list of versions
    sudo -u $CURRENT_USER git checkout tags/$(git tag -l | grep -Eo v[0-9]+\.[0-9]+ | sort -V | tail -n 1)
}

make_install() {
    echo "$SNAME make install..."
    sudo -u $CURRENT_USER make -j$(nproc) &&
        make install
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then exit 0; fi
    echo "cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_flashrom() {
    install_deps &&
        fetch_src &&
        git_checkout_latest &&
        make_install &&
        cleanup $@
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
    esac
done

install_flashrom $@



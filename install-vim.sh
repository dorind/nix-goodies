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
# homepage: https://www.vim.org https://github.com/vim/vim
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""
SNAME=$(basename $0)

PKG_DEB="git make cmake build-essential libncurses5-dev libatk1.0-dev"
PKG_DEB="$PKG_DEB libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1"
PKG_DEB="$PKG_DEB liblua5.1-dev libperl-dev"

GIT_SRC="https://github.com/vim/vim.git"
GIT_SRC_BRANCH="master"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "$SNAME fetching source..."
    sudo -u $CURRENT_USER mkdir ./vim_build &&
        cd vim_build &&
        CLEANUP_LIST=$(pwd) &&
        sudo -u $CURRENT_USER git clone --recursive $GIT_SRC
}

git_checkout_latest() {
    # switch to branch
    git checkout $GIT_SRC_BRANCH &&
        # list git tags
        #   find tag formatted as X.Y.Z, where X, Y, Z are numbers
        #       sort naturally i.e. human versioning
        #           return last item from sorted list of versions
        sudo -u $CURRENT_USER git checkout tags/$(git tag -l | grep -Eo v[0-9]+\.[0-9]+\.[0-9]+ | sort -V | tail -n 1)
}

checkout_latest_ver() {
    echo "$SNAME checking out latest version"
    # switch to vim repository
    cd vim &&
        # checkout latest vim release
        git_checkout_latest
}

make_install() {
    echo "$SNAME configuring..."
    sudo -u $CURRENT_USER CFLAGS="-march=native -O2" ./configure  \
            --with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-python3interp=yes \
            --with-python3-config-dir=$(python3-config --configdir) \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
            --enable-gui=no \
            --disable-gtktest \
            --enable-cscope \
            --enable-terminal \
            --with-compiledby="$CURRENT_USER" \
            --prefix=/usr/local &&
        echo "$SNAME building..." &&
        sudo -u $CURRENT_USER make -j$(nproc) VIMRUNTIMEDIR=/usr/local/share/vim/vim$(git tag -l | grep -Eo v[0-9]+\.[0-9]+ | sort -V | tail -n 1 | sed s/v//g | sed s/\\.//g) &&
        make install
}

update_alts() {
    update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
    update-alternatives --set editor /usr/local/bin/vim
    update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
    update-alternatives --set vi /usr/local/bin/vim
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then return 0; fi
    echo "$SNAME cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_vim() {
    install_deps &&
        fetch_src &&
        checkout_latest_ver &&
        make_install &&
        update_alts &&
        cleanup $@
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
    esac
done

install_vim $@



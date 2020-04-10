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
# homepage: https://github.com/tpope/vim-fugitive
#

#
# check your ~/.vimrc
# filetype plugin on
# set laststatus=2
# set statusline+=%{fugitive#Statusline()}
# set statusline+=%F
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
USER_HOME="/home/$CURRENT_USER"
DIR_INIT=$(pwd)
CLEANUP_LIST=""
SNAME=$(basename $0)

PKG_DEB="git"

GIT_SRC="https://github.com/tpope/vim-fugitive.git"
GIT_SRC_BRANCH="master"
INSTALL_DIR="$USER_HOME/.vim/pack/dist/start/vim-fugitive"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "$SNAME fetching source..."
        sudo -u $CURRENT_USER git clone --recursive $GIT_SRC $INSTALL_DIR
}

git_checkout_latest() {
    # switch to branch
    git checkout $GIT_SRC_BRANCH &&
        # list git tags
        #   find tag formatted as X.Y, where X, Y are numbers
        #       sort naturally i.e. human versioning
        #           return last item from sorted list of versions
        sudo -u $CURRENT_USER git checkout tags/$(git tag -l | grep -Eo v[0-9]+\.[0-9]+ | sort -V | tail -n 1)
}

checkout_latest_ver() {
    echo "$SNAME checking out latest version"
    # switch to vim-fugitive repository
    cd $INSTALL_DIR &&
        # checkout latest vim-fugitive release
        git_checkout_latest
}

install_vim_fugitive() {
    install_deps &&
        fetch_src &&
        checkout_latest_ver
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
    esac
done

install_vim_fugitive $@



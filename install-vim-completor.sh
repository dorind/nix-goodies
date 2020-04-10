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
# homepage: https://github.com/maralla/completor.vim
#

#
# check your ~/.vimrc
# filetype plugin on
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
USER_HOME="/home/$CURRENT_USER"
DIR_INIT=$(pwd)
CLEANUP_LIST=""
SNAME=$(basename $0)

PKG_DEB="git"

GIT_SRC="https://github.com/maralla/completor.vim.git"
GIT_SRC_BRANCH="master"
INSTALL_DIR="$USER_HOME/.vim/pack/completor/start/completor.vim"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "$SNAME fetching source..."
        sudo -u $CURRENT_USER git clone --recursive $GIT_SRC $INSTALL_DIR
}

cfg_completor_vim() {
    VIMRC="$USER_HOME/.vimrc"
    sudo -u $CURRENT_USER echo "\"completor vim" >> $VIMRC
    
    # clang autocompletion
    BIN_CLANG=$(command -v clang)
    if [ ! -x "$BIN_CLANG" ]; then
        echo "$SNAME clang not found"
        echo "\"let g:completor_clang_binary = '/path/to/clang'" >> $VIMRC
    else
        echo "$SNAME enabling clang"
        echo "let g:completor_clang_binary = '$BIN_CLANG'" >> $VIMRC
    fi
    
    # golang autocompletion
    # $ go get -u github.com/nsf/gocode
    # add to your PATH
    BIN_GOCODE=$(command -v gocode)
    if [ ! -x "$BIN_GOCODE" ]; then
        echo "$SNAME gocode not found"
        echo "\"let g:completor_gocode_binary = '/path/to/gocode'" >> $VIMRC
    else
        echo "$SNAME enabling gocode"
        echo "let g:completor_gocode_binary = '$BIN_GOCODE'" >> $VIMRC
    fi
    
    # nodejs autocompletion
    # $ sudo apt-get install -y nodejs
    BIN_NODE=$(command -v node)
    if [ ! -x "$BIN_NODE" ]; then
        echo "$SNAME node not found"
        echo "\"let g:completor_node_binary = '/path/to/node'" >> $VIMRC
    else
        echo "$SNAME enabling node"
        echo "let g:completor_node_binary = '$BIN_NODE'" >> $VIMRC
    fi
    
    # rust
    # $ rustup toolchain add nightly && cargo +nightly install racer
    # add racer to your path
    BIN_RACER=$(command -v racer)
    if [ ! -x "$BIN_RACER" ]; then
        echo "$SNAME racer not found"
        echo "\"let g:completor_racer_binary = '/path/to/racer'" >> $VIMRC
    else
        echo "$SNAME enabling rust"
        echo "let g:completor_racer_binary = '$BIN_RACER'" >> $VIMRC
    fi
    
    echo "" >> $VIMRC
}

install_completor_vim() {
    install_deps &&
        fetch_src &&
        cfg_completor_vim
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
        "--config") cfg_completor_vim; exit 0;;
    esac
done

install_completor_vim $@



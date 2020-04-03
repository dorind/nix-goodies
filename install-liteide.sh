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
# homepage: http://liteide.org/en/ https://github.com/visualfc/liteide
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""
LITEIDE_INSTALL_LOCATION="/usr/local"
LITEIDE_INSTALL_BIN=""
ICON_PATH="/usr/share/icons/hicolor/scalable/apps/liteide.svg"
ICON_REMOTE="https://raw.githubusercontent.com/dorind/nix-goodies/master/res/icons/liteide.svg"

install_deps() {
    apt-get install -y wget qt5-default
}

fetch_install() {
    URL_PATH=$(wget -qO- https://github.com/visualfc/liteide/releases/latest | grep -Eo \"\/visualfc\/liteide\/releases\/download\/x[0-9]+\.[0-9]\/liteidex[0-9]+\.[0-9]\.linux64\-qt5\.[0-9]+\.[0-9]+\.tar\.gz\" | tr -d '"')
    URL_DL="https://www.github.com$URL_PATH"
    NAME=$(basename $URL_PATH)
    CLEANUP_LIST="$NAME"
    sudo -u $CURRENT_USER wget $URL_DL &&
    tar -C $LITEIDE_INSTALL_LOCATION -xzf $NAME &&
    LITEIDE_INSTALL_BIN=$LITEIDE_INSTALL_LOCATION/liteide/bin
}

setup_app() {
    FDESK="/usr/local/share/applications" &&
    mkdir -p $FDESK &&
    FDESK="$FDESK/liteide.desktop"
    wget -O $ICON_PATH $ICON_REMOTE || true
    echo "[Desktop Entry]" >> $FDESK
    echo "Name=LiteIDE" >> $FDESK
    echo "Comment=Code Editing" >> $FDESK
    echo "GenericName=Text Editor" >> $FDESK
    echo "Exec=$LITEIDE_INSTALL_BIN/liteide" >> $FDESK
    echo "Icon=$ICON_PATH" >> $FDESK
    echo "Type=Application" >> $FDESK
    echo "StartupNotify=false" >> $FDESK
    echo "Categories=Utility;TextEditor;Development;IDE;" >> $FDESK
    echo "Keywords=liteide;" >> $FDESK
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
    echo "# liteide" >> $SHRC
    echo "export PATH=\$PATH:$LITEIDE_INSTALL_BIN" >> $SHRC
    echo "" >> $SHRC
    echo "$SNAME reloading $SHRC"
    su $CURRENT_USER
    . $SHRC
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then return 0; fi
    echo "cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_liteide() {
    install_deps &&
    fetch_install &&
    cleanup $@ &&
    setup_app &&
    exports
}

install_liteide $@



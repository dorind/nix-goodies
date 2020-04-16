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
# homepage: https://albertlauncher.github.io/
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""
SNAME=$(basename $0)

# OMG!
PKG_DEB="git make cmake libc6 libgcc1 libmuparser2v5 libpython3.7 libqt5charts5"
PKG_DEB="$PKG_DEB qt5-default libqt5svg5-dev libqt5x11extras5-dev"
PKG_DEB="$PKG_DEB libqt5concurrent5 libqt5core5a libqt5dbus5 libqt5gui5"
PKG_DEB="$PKG_DEB libqt5network5 libqt5qml5 libqt5quick5 libqt5sql5 libqt5svg5"
PKG_DEB="$PKG_DEB libqt5widgets5 libqt5x11extras5 libstdc++6 libx11-6 libxext6"
PKG_DEB="$PKG_DEB libqt5sql5-sqlite qtdeclarative5-dev libqt5charts5-dev"
PKG_DEB="$PKG_DEB libmuparser-dev python3-distutils pybind11-dev python3-dev"

# extra
PKG_DEB="$PKG_DEB fortune locate units copyq python3-numpy wmctrl"

GIT_SRC="https://github.com/albertlauncher/albert.git"
GIT_SRC_BRANCH="master"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "$SNAME fetching source..."
    sudo -u $CURRENT_USER mkdir ./albert_build &&
        cd albert_build &&
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
    # switch to albert repository
    cd albert &&
        # checkout latest albert release
        git_checkout_latest &&
        # make build dir
        sudo -u $CURRENT_USER mkdir ../build &&
        # switch to albert build directory
        cd ../build
}

make_install() {
    echo "$SNAME make install..."
    sudo -u $CURRENT_USER cmake ../albert -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release &&
        sudo -u $CURRENT_USER make -j$(nproc) &&
        make install
}

def_cfg() {
    echo "$SNAME writing default configuration to /home/$CURRENT_USER/.config/albert/albert.conf"
    ACF="/home/$CURRENT_USER/.config/albert"
    sudo -u $CURRENT_USER mkdir $ACF
    ACF="$ACF/albert.conf"
    
    AMOD="arch_wiki, aur, base_converter, binance, bitfinex, coinmarketcap,"
    AMOD="$AMOD copyq, currency_converter, datetime, fortune, units,"
    AMOD="$AMOD goldendict, google_translate, ip, kill, locate, python_eval,"
    AMOD="$AMOD trash, wikipedia, window_switcher, youtube"
    
    sudo -u $CURRENT_USER echo "[General]" > $ACF
    echo "hotkey=Meta+Space" >> $ACF
    echo "showTray=true" >> $ACF
    echo "telemetry=false" >> $ACF
    echo "terminal=xfce4-terminal -x" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.applications]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.calculator]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.externalextensions]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.files]" >> $ACF
    echo "enabled=false" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.firefoxbookmarks]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.hashgenerator]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.mpris]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.python]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "enabled_modules=$AMOD" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.snippets]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.ssh]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.system]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.terminal]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.extension.websearch]" >> $ACF
    echo "enabled=true" >> $ACF
    echo "" >> $ACF
    echo "[org.albert.frontend.widgetboxmodel]" >> $ACF
    echo "alwaysOnTop=true" >> $ACF
    echo "clearOnHide=false" >> $ACF
    echo "displayIcons=true" >> $ACF
    echo "displayScrollbar=true" >> $ACF
    echo "displayShadow=true" >> $ACF
    echo "hideOnClose=false" >> $ACF
    echo "hideOnFocusLoss=true" >> $ACF
    echo "itemCount=5" >> $ACF
    echo "showCentered=true" >> $ACF
    echo "theme=Adapta" >> $ACF
    echo "" >> $ACF
}

set_icon() {
    sed -i 's/Icon=albert/Icon=\/usr\/share\/icons\/hicolor\/scalable\/apps\/albert.svg/' /usr/share/applications/albert.desktop
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then return 0; fi
    echo "$SNAME cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_albert() {
    install_deps &&
        fetch_src &&
        checkout_latest_ver &&
        make_install &&
        def_cfg &&
        set_icon &&
        cleanup $@ &&
        sudo -u $CURRENT_USER albert &
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
    esac
done

install_albert $@



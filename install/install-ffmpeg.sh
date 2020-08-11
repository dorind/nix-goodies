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
# homepage: https://ffmpeg.org
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""
SNAME=$(basename $0)

# OMG!
PKG_DEB="wget build-essential autoconf automake cmake libtool"
PKG_DEB="$PKG_DEB bzip2 nasm yasm libass-dev libfreetype6-dev"
PKG_DEB="$PKG_DEB libsdl2-dev p11-kit libva-dev libvdpau-dev libvorbis-dev"
PKG_DEB="$PKG_DEB libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config"
PKG_DEB="$PKG_DEB texinfo wget zlib1g-dev libchromaprint-dev frei0r-plugins-dev"
PKG_DEB="$PKG_DEB gnutls-dev ladspa-sdk libcaca-dev libcdio-paranoia-dev"
PKG_DEB="$PKG_DEB libcodec2-dev libfontconfig1-dev libfreetype6-dev"
PKG_DEB="$PKG_DEB libfribidi-dev libgme-dev libgsm1-dev libjack-dev"
PKG_DEB="$PKG_DEB libmodplug-dev libmp3lame-dev libopencore-amrnb-dev"
PKG_DEB="$PKG_DEB libopencore-amrwb-dev libopenjp2-7-dev libopenmpt-dev"
PKG_DEB="$PKG_DEB libopus-dev libpulse-dev librsvg2-dev librubberband-dev"
PKG_DEB="$PKG_DEB librtmp-dev libshine-dev libsmbclient-dev libsnappy-dev"
PKG_DEB="$PKG_DEB libsoxr-dev libspeex-dev libssh-dev libtesseract-dev"
PKG_DEB="$PKG_DEB libtheora-dev libtwolame-dev libv4l-dev libvo-amrwbenc-dev"
PKG_DEB="$PKG_DEB libvorbis-dev libvpx-dev libwavpack-dev libwebp-dev"
PKG_DEB="$PKG_DEB libx264-dev libx265-dev libxvidcore-dev libxml2-dev"
PKG_DEB="$PKG_DEB libzmq3-dev libzvbi-dev liblilv-dev libopenal-dev opencl-dev"
PKG_DEB="$PKG_DEB libjack-dev"

install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "$SNAME fetching source..."
    URL_DL=https://ffmpeg.org/$(wget -qO- https://ffmpeg.org/download.html#releases | grep -Eo releases\/ffmpeg\-[0-9]+\.[0-9]+\.[0-9]+\.tar\.bz2 | sort -V | tail -n 1) &&
        echo "$SNAME downloading latest version from $URL_DL" &&
        sudo -u $CURRENT_USER mkdir ./ffmpeg_build &&
        cd ffmpeg_build &&
        CLEANUP_LIST=$(pwd) &&
        sudo -u $CURRENT_USER wget $URL_DL &&
        sudo -u $CURRENT_USER bzip2 -d $(basename $URL_DL) &&
        sudo -u $CURRENT_USER tar -xf ffmpeg-*.tar &&
        cd $(find . -type d -name "ffmpeg*")
}

make_install() {
    #  --enable-avisynth
    echo "$SNAME make install..."
    echo "$SNAME configuring ffmpeg..."
    sudo -u $CURRENT_USER ./configure --prefix=/usr/local \
        --extra-cflags='-march=native' \
        --enable-hardcoded-tables \
        --enable-gpl --enable-version3 --disable-static \
        --enable-shared --enable-small --enable-chromaprint \
        --enable-frei0r --enable-gmp --enable-gnutls --enable-ladspa \
        --enable-libass --enable-libcaca --enable-libcdio \
        --enable-libcodec2 --enable-libfontconfig --enable-libfreetype \
        --enable-libfribidi --enable-libgme --enable-libgsm --enable-libjack \
        --enable-libmodplug --enable-libmp3lame --enable-libopencore-amrnb \
        --enable-libopencore-amrwb --enable-libopencore-amrwb \
        --enable-libopenjpeg --enable-libopenmpt --enable-libopus --enable-libpulse \
        --enable-librsvg --enable-librubberband --enable-librtmp --enable-libshine \
        --enable-libsnappy --enable-libsoxr --enable-libspeex \
        --enable-libssh --enable-libtesseract --enable-libtheora \
        --enable-libtwolame --enable-libv4l2 --enable-libvo-amrwbenc \
        --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp \
        --enable-libx264 --enable-libx265 --enable-libxvid --enable-libxml2 \
        --enable-libzmq --enable-libzvbi --enable-lv2 \
        --enable-openal --enable-opencl --enable-opengl --enable-libdrm &&
        echo "$SNAME building ffmpeg..." &&
        sudo -u $CURRENT_USER make -j$(nproc) &&
        echo "$SNAME installing ffmpeg..." &&
        make install &&
        ldconfig
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then return 0; fi
    echo "$SNAME cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_ffmpeg() {
    install_deps &&
        fetch_src &&
        make_install &&
        cleanup $@
}

for s in "$@"
do
    case $s in
        "--PKG_DEB") echo $PKG_DEB; exit 0;;
    esac
done

install_ffmpeg $@



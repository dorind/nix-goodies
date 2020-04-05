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
# homepage: https://opencv.org/
#

CURRENT_USER=${SUDO_USER:-$(whoami)}
DIR_INIT=$(pwd)
CLEANUP_LIST=""

# debian packages
# python 2
PKG_DEB="python-opencv python-opencv-apps python-dev python-numpy"

# python 3
PKG_DEB="$PKG_DEB python3-opencv python3-opencv-apps python3-dev python3-numpy"

# misc
PKG_DEB="$PKG_DEB build-essential cmake git pkg-config libgtk-3-dev libopenjp2-7-dev libqt5gstreamer-dev x264 v4l-utils"
PKG_DEB="$PKG_DEB zlib1g-dev libtbb2 libtbb-dev libdc1394-22-dev"

# ffmpeg libs
PKG_DEB="$PKG_DEB libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libavresample-dev"
PKG_DEB="$PKG_DEB libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev"
PKG_DEB="$PKG_DEB gfortran openexr libatlas-base-dev"

# opencl
PKG_DEB="$PKG_DEB beignet-opencl-icd"

# Library of linear algebra
PKG_DEB="$PKG_DEB liblapacke liblapacke-dev libeigen3-dev libopenblas-base libopenblas-dev"

# protobuf
if [ ! -z "$(ldconfig -p | grep protobuf)" ]; then
	echo "protobuf found!"
else
	PKG_DEB="$PKG_DEB libprotobuf-dev protobuf-compiler"
fi

install_deps() {
    apt-get install -y $PKG_DEB
}

fetch_src() {
    echo "fetching source..."
    sudo -u $CURRENT_USER mkdir -p ./opencv_build &&
        cd opencv_build &&
        CLEANUP_LIST=$(pwd) &&
        sudo -u $CURRENT_USER git clone https://github.com/opencv/opencv.git &&
        sudo -u $CURRENT_USER git clone https://github.com/opencv/opencv_contrib.git &&
        sudo -u $CURRENT_USER mkdir ./opencv/build
}

git_checkout_latest() {
    # list git tags
    #   find tag formatted as X.Y.Z, where X, Y, Z are numbers
    #       sort naturally i.e. human versioning
    #           return last item from sorted list of versions
    sudo -u $CURRENT_USER git checkout tags/$(git tag -l | grep -Eo [0-9]+\.[0-9]+\.[0-9]+ | sort -V | tail -n 1)
}

checkout_latest_ver() {
    echo "checking out latest release"
    # switch to opencv repository
    cd opencv &&
        # checkout latest opencv release
        git_checkout_latest &&
        # switch to opencv contrib repository
        cd ../opencv_contrib &&
        # checkout latest opencv_contrib release
        git_checkout_latest &&
        # switch to opencv build directory
        cd ../opencv/build
}

make_install() {
    echo "building..."
    sudo -u $CURRENT_USER cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_C_EXAMPLES=ON \
        -D INSTALL_PYTHON_EXAMPLES=ON \
        -D OPENCV_GENERATE_PKGCONFIG=ON \
        -D WITH_TBB=ON \
        -D WITH_V4L=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
        -D BUILD_EXAMPLES=ON .. &&
        sudo -u $CURRENT_USER make -j$(nproc) &&
        make install
}

cleanup() {
    cd $DIR_INIT
    if ! [ "$1" = "--cleanup" ]; then return 0; fi
    echo "cleaning up: $CLEANUP_LIST"
    rm -rf $CLEANUP_LIST
}

install_opencv() {
    install_deps &&
        fetch_src &&
        checkout_latest_ver &&
        make_install &&
        cleanup $@
}

install_opencv $@



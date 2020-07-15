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

MOUNT_POINT="/mnt"
CONFIG_FILE=".tmpfs"

CURRENT_USER=${SUDO_USER:-$(whoami)}
SNAME=$(basename $0)
INSTALL_LOCATION="/usr/local/bin/mktmpfs"

usage() {
    echo "usage:"
    echo "example new:"
    echo "  sudo $SNAME new ramdisk 512M"
    echo "  or"
    echo "  sudo $SNAME new ramdisk 1G"
    echo ""
    echo "example remove:"
    echo "  sudo $SNAME remove ramdisk"
    echo ""
    echo "example save:"
    echo "  sudo $SNAME save ramdisk ~/ramdisk_name"
    echo ""
    echo "example load:"
    echo "  sudo $SNAME load ~/ramdisk_name ramdisk"
}

tmpfs_new() {
    NAME=$1
    SIZE=$2
    PRINT_PATH=$3

    # sanity checks
    # is size correct?
    if ! echo $SIZE | grep -Eq "^[0-9]+[M|G]$" ; then
        echo "$SNAME error: invalid size $SIZE! example 512M or 1G"
        exit 1
    fi

    # create directory in $MOUNT_POINT
    if ! mkdir $MOUNT_POINT/$NAME ; then
        echo "$SNAME error: cannot create directory $MOUNT_POINT/$NAME"
        exit 1;
    fi

    # set directory permission
    chown -R $CURRENT_USER:$CURRENT_USER $MOUNT_POINT/$NAME
    
    # mount
    mount -t tmpfs -o size=$SIZE tmpfs $MOUNT_POINT/$NAME
    
    if [ "$PRINT_PATH" = "-pp" ]; then
        echo $MOUNT_POINT/$NAME
    fi
}

tmpfs_remove() {
    NAME=$1
    
    # unmount
    if ! umount -l $MOUNT_POINT/$NAME ; then
        echo "$SNAME error: cannot unmount $MOUNT_POINT/$NAME"
        exit 1
    fi

    # rm dir $MOUNT_POINT/$NAME
    if ! rm -rf $MOUNT_POINT/$NAME; then
        echo "$SNAME error: cannot remove $MOUNT_POINT/$NAME"
        exit 1
    fi
}

tmpfs_save() {
    NAME=$1
    SAVE_PATH=$2

    # create directory
    if ! mkdir -p $SAVE_PATH; then
        echo "$SNAME error: cannot create directory $SAVE_PATH, bailing out!"
        exit 1
    fi

    # save size
    SIZE=$(df -m | grep "$MOUNT_POINT/$NAME" | awk '{ print $2 }')

    # save name
    echo "NAME $NAME" > $SAVE_PATH"/$CONFIG_FILE"
    
    # save size
    echo "SIZE $SIZE""M" >> $SAVE_PATH"/$CONFIG_FILE"

    # set directory permission
    chown -R $CURRENT_USER:$CURRENT_USER $SAVE_PATH
    DLS=$(ls $MOUNT_POINT/$NAME)
    # avoid copy if directory is empty
    if ! [ -z "$DLS" ]; then
        cp -Rp $MOUNT_POINT/$NAME/* $SAVE_PATH
    fi
}

tmpfs_load() {
    LOAD_PATH=$1
    NAME=$2
    SIZE=$(cat $LOAD_PATH"/$CONFIG_FILE" | grep "SIZE" | awk '{ print $2 }')
    
    # empty name? load from config file
    if [ -z "$NAME" ]; then
        NAME=$(cat $LOAD_PATH"/$CONFIG_FILE" | grep "NAME" | awk '{ print $2 }')
    fi

    if ! tmpfs_new $NAME $SIZE ; then
        echo "$SNAME error: cannot load $NAME from $LOAD_PATH"
        exit 1
    fi

    cp -Rp $LOAD_PATH/* $MOUNT_POINT/$NAME
}

tmpfs_install() {
    cp $0 $INSTALL_LOCATION || echo "cannot copy to $INSTALL_LOCATION"
}

case $1 in
    # [name] [size]
    "new") tmpfs_new $2 $3 $4;;
    # [name]
    "remove") tmpfs_remove $2;;
    # name [path]
    "save") tmpfs_save $2 $3;;
    # [path] name
    "load") tmpfs_load $2 $3;;
    # copy this script to $INSTALL_LOCATION
    "install") tmpfs_install;;
    *) usage; exit 1;;
esac



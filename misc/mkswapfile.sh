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

SNAME=$(basename $0)
SWAPFILENAME="/swapfile"
FSTAB="/etc/fstab"
MAX_MULTIPLIER=3

mkswapfile_new_mib() {
    # size is in MiB
    SIZE=$1
    # allocate space
    # try with fallocate, much faster than dd
    fallocate -l $SIZE"M" $SWAPFILENAME ||
        # fallback to good ol' dd
        dd if=/dev/zero of=$SWAPFILENAME bs=1M count=$SIZE &&
        # set permission
        chmod 600 $SWAPFILENAME &&
        # setup swap
        mkswap $SWAPFILENAME &&
        # enable swap
        swapon $SWAPFILENAME &&
        # make changes persistent
        echo "$SWAPFILENAME none swap sw 0 0" >> $FSTAB
}

mkswapfile_new() {
    # fetch amount of ram in MiB
    AVAIL_RAM=$(free -m | grep Mem | awk '{print $2}')
    # set size to multiplier or available ram
    SIZE=${2:-$AVAIL_RAM}
    # is it a multiplier?
    if echo $SIZE | grep -Eq "^x"; then
        # fetch the number part of "x0123"
        MULTIPLIER=$(echo $SIZE | grep -Eo [0-9]+)
        # calculate requested size
        SIZE=$(($AVAIL_RAM * $MULTIPLIER))
        # sanity check
        if [ $MULTIPLIER -gt $MAX_MULTIPLIER ]; then
            echo "$SNAME maximum multiplier($MAX_MULTIPLIER) exceeded"
            echo "    $SIZE MiB swapfile might be a bit too much"
            exit 1
        fi
    fi
    mkswapfile_new_mib $SIZE
}

mkswapfile_rm() {
    # disable swap
    swapoff $SWAPFILENAME &&
        # remove swapfile entry from fstab
        sed -i.bak "/\\$SWAPFILENAME/d" $FSTAB &&
        # remove swap file
        rm $SWAPFILENAME
}

usage() {
    echo "usage:"
    echo "example new:"
    echo "    sudo $SNAME new"
    echo "  for a swapfile equal to amount of RAM"
    echo " or"
    echo "    sudo $SNAME new x2"
    echo "  for a swapfile equal twice the amount of RAM"
    echo ""
    echo "example remove:"
    echo "    sudo $SNAME remove"
    echo ""
}

case $1 in
    "new") mkswapfile_new $@;;
    "remove") mkswapfile_rm;;
    *) usage;;
esac



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

if [ $(id -u) -eq 0 ]; then
    echo "Please run script without root privileges"
    exit 1
fi

CURRENT_USER=${SUDO_USER:-$(whoami)}

cfg_xfce_thunar() {
    # quit thunar before attempting to change settings
    thunar -q
    
    # set default view
    xfconf-query -n --channel thunar --property "/default-view" -t "string" -s "ThunarDetailsView"
    # set buttons in path
    xfconf-query -n --channel thunar --property "/last-location-bar" -t "string" -s "ThunarLocationButtons"
    # set small icons in side pane
    xfconf-query -n --channel thunar --property "/shortcuts-icon-size" -t "string" -s "THUNAR_ICON_SIZE_24"
    # remember positions
    xfconf-query -n --channel thunar --property "/misc-remember-geometry" -t "bool" -s "true"
    # show full path in title
    xfconf-query -n --channel thunar --property "/misc-full-path-in-title" -t "bool" -s "true"
    # always show tabs
    #xfconf-query -n --channel thunar --property "/misc-always-show-tabs" -t "bool" -s "true"

    # start thunar, because why not?
    #thunar &
}

cfg_gtk_bookmarks() {
    BFS="/home/$CURRENT_USER/.config/gtk-3.0"
    mkdir -p $BFS
    BFS="$BFS/bookmarks"
    echo "file:///home/$CURRENT_USER/Documents/" >> $BFS
    echo "file:///home/$CURRENT_USER/Downloads/" >> $BFS
    echo "file:///home/$CURRENT_USER/Pictures/" >> $BFS
    echo "file:///home/$CURRENT_USER/Videos/" >> $BFS
}

cfg_gtk_bookmarks &&
    cfg_xfce_thunar   



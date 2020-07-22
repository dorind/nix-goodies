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
# shortcut              action
#
# SUPER-D               show desktop
# SHIFT-SUPER-DOWN      tile windows down 
# SHIFT-SUPER-UP        tile windows up
# SUPER-1               workspace 1
# SUPER-2               workspace 2
# SUPER-3               workspace 3
# SUPER-4               workspace 4
# SUPER-LEFT            tile window left
# SUPER-RIGHT           tile window right
# SUPER-UP              maximize/restore window
#
# SUPER-E               thunar file manager
# SUPER-T               xfce terminal
# SUPER-R               xfce appfinder
# CTRL-ESC              xfce settings manager
# SHIFT-CTRL-ALT-!      flameshot capture screenshot
# SHIFT-CTRL-ALT-$      flameshot gui mode
# PrtScn                flameshot copy to clipboard
# SHIFT-CTRL-ESC        gnome system monitor
#

if [ $(id -u) -eq 0 ]; then
    echo "Please run script without root privileges"
    exit 1
fi

DIR_SS="/home/"$USER"/Pictures/Screenshots"
mkdir -p $DIR_SS

cfg_xfce_shortcuts() {
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>d" -t string -s "show_desktop_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Shift><Super>Down" -t string -s "tile_down_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Shift><Super>Up" -t string -s "tile_up_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>1" -t string -s "workspace_1_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>2" -t string -s "workspace_2_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>3" -t string -s "workspace_3_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>4" -t string -s "workspace_4_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>Left" -t string -s "tile_left_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>Right" -t string -s "tile_right_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/xfwm4/custom/<Super>Up" -t string -s "maximize_window_key"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Super>e" -t string -s "thunar"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Super>t" -t string -s "xfce4-terminal"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Super>r" -t string -s "xfce4-appfinder"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Ctrl>Escape" -t string -s "xfce4-settings-manager"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Shift><Ctrl><Alt>exclam" -t string -s "flameshot full -p '$DIR_SS'"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Shift><Ctrl><Alt>dollar" -t string -s "flameshot gui"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/Print" -t string -s "flameshot full -c"
    xfconf-query -n --channel xfce4-keyboard-shortcuts --property "/commands/custom/<Shift><Ctrl>Escape" -t string -s "gnome-system-monitor"
}

cfg_xfce_shortcuts



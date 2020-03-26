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
# SUPER-E               show desktop
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
# SHIFT-CTRL-ESC        gnome system monitor
#

DIR_SS="/home/"$USER"/Pictures/Screenshots"
mkdir -p $DIR_SS

SHORTCUTS="\
/xfwm4/custom/<Super>d@show_desktop_key|\
/xfwm4/custom/<Shift><Super>Down@tile_down_key|\
/xfwm4/custom/<Shift><Super>Up@tile_up_key|\
/xfwm4/custom/<Super>1@workspace_1_key|\
/xfwm4/custom/<Super>2@workspace_2_key|\
/xfwm4/custom/<Super>3@workspace_3_key|\
/xfwm4/custom/<Super>4@workspace_4_key|\
/xfwm4/custom/<Super>Left@tile_left_key|\
/xfwm4/custom/<Super>Right@tile_right_key|\
/xfwm4/custom/<Super>Up@maximize_window_key|\
/commands/custom/<Super>e@thunar|\
/commands/custom/<Super>t@xfce4-terminal|\
/commands/custom/<Super>r@xfce4-appfinder|\
/commands/custom/<Ctrl>Escape@xfce4-settings-manager|\
/commands/custom/<Shift><Ctrl><Alt>exclam@flameshot full -c -p $DIR_SS|\
/commands/custom/<Shift><Ctrl><Alt>dollar@flameshot gui|\
/commands/custom/<Shift><Ctrl>Escape@gnome-system-monitor"

echo $SHORTCUTS | awk '{\
cnt=split($0, list, "|");\
for (i = 0; ++i <= cnt;) {\
    split(list[i], item, "@");\
    system("xfconf-query --channel xfce4-keyboard-shortcuts --property \""item[1]"\" --reset");\
    system("xfconf-query --channel xfce4-keyboard-shortcuts --property \""item[1]"\" --create --type string --set \""item[2]"\"");\
}\
}'



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

cfg_xfce_theme_wm() {
    # set theme
    xfconf-query --channel xsettings --property "/Net/ThemeName" -s "Arc"
    # set icons
    xfconf-query --channel xsettings --property "/Net/IconThemeName" -s "Obsidian-Aqua-SemiLight"
    # set wm theme
    xfconf-query --channel xfwm4 --property "/general/theme" -s "Arc-Dark"
    # align window title to left
    xfconf-query --channel xfwm4 --property "/general/title_alignment" -s "left"
    # center screen new windows
    xfconf-query --channel xfwm4 --property "/general/placement_ratio" -s 60
    # enable compositor
    xfconf-query --channel xfwm4 --property "/general/use_compositing" -s "true"
    # enable zoom with SUPER-MOUSE WHEEL
    xfconf-query --channel xfwm4 --property "/general/easy_click" -s "Super"
    xfconf-query --channel xfwm4 --property "/general/zoom_desktop" -s "true"
    # window title bar buttons: close to the left, minimize to the right
    xfconf-query --channel xfwm4 --property "/general/button_layout" -s "C|H"
    # no session save
    xfconf-query -n --channel xfce4-session --property "/general/SaveOnExit" -t "bool" -s "false"
}

cfg_xfce_theme_wm



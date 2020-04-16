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

CURRENT_USER=${SUDO_USER:-$(whoami)}
SNAME=$(basename $0);
FNAME="HotPlug USB Backup";
INSTALL_TS=$(date +"[%Y-%m-%d %H:%M:%S]");
SVC_NAME="hpubk"
SVC_CONF="/etc/$SVC_NAME.conf"
FN_UDEV_RULE="/etc/udev/rules.d/99-$SVC_NAME.rules"
FN_SERVICE="/etc/systemd/system/$SVC_NAME.service"
IFN_SERVICE="/usr/local/bin/$SVC_NAME"
COM_PIPE="/tmp/$SVC_NAME.pipe"
AUTOMOUNT_BASE="/media/$SVC_NAME"
PKG_DEB="rsync"

################################################################################
#   diagram
################################################################################
#
#   +---------------------------------+
#   |  USB storage device plugged in  |
#   +---------------------------------+
#                     |
#                     |
#              +-------------+
#              |  udev rule  |
#              +-------------+
#                     |
#                     |
#           +-------------------+
#           |  /tmp/hpubk.pipe  |
#           +-------------------+
#                     |
#                     |
#           +-------------------+
#           |  hpubk --service  |
#           +-------------------+
#                     |
#                     |
#     +-------------------------------+
#     |  $STORAGE_DEVICE/.hpubk/list  |
#     +-------------------------------+
#                     |
#                     |
#                +---------+
#                |  rsync  |
#                +---------+
#
#_______________________________________________________________________________

################################################################################
#   generated files
################################################################################
#
#   /etc/udev/rules.d/99-$SVC_NAME.rules | usb detection
#
#   /etc/$SVC_NAME.conf                  | configuration file
#
#   /usr/local/bin/$SVC_NAME             | this script
#
#   /tmp/$SVC_NAME.pipe                  | communication pipe between udev rule 
#                                        | and this script running as a service
#_______________________________________________________________________________

################################################################################
#   debugging
################################################################################
#
#   1. check if service is running
#
#       $ systemctl status hpubk
#
#   2. check what journalctl says
#
#       $ sudo journalctl -f -u hpubk
#
#   3.a is your usb device mounted?
#
#       $ mount
#
#   3.b is it mounted ready only? look for "ro"
#
#   4. your usb device might need to be [re]formatted
#_______________________________________________________________________________

#
#   display notifications
#
notify_send() {
    sudo -Eu $HPUBK_USER env DISPLAY=:0 /usr/bin/notify-send -u $1 -i drive-removable-media "$FNAME" "$2"
}

################################################################################
#   SECTION INSTALL/UNINSTALL
################################################################################

#
# currently only rsync
#
install_deps() {
    echo "$SNAME installing dependencies: $PKG_DEB"
    apt-get install -y $PKG_DEB
}

#
#   create udev rule in /etc/udev/rules.d/
#
install_hpubk_udev_rule() {
    # create a UDEV rule that writes to $COM_PIPE when a USB device is plugged in
    echo "$SNAME installing udev rule"
    
    echo "# $FNAME" > $FN_UDEV_RULE &&
        echo "# installed on $INSTALL_TS by $CURRENT_USER" >> $FN_UDEV_RULE &&
        echo "ACTION==\"add\", SUBSYSTEMS==\"usb\", KERNEL==\"sd[a-z][0-9]\", RUN+=\"/bin/sh -c 'echo \$DEVNAME >> $COM_PIPE'\" " >> $FN_UDEV_RULE &&
        echo "$SNAME reloading udev rules..." &&
        udevadm control --reload-rules
}

#
#   remove udev rule from /etc/udev/rules.d/
#
uninstall_hpubk_dev_rule() {
    echo "$SNAME uninstalling udev rule"
    rm -f $FN_UDEV_RULE &&
        udevadm control --reload-rules
}

#
#   generate conf file with defaults
#
install_hpubk_conf() {
    echo "# set to 'yes' to enable auto mount of usb devices" > $SVC_CONF &&
        echo "# warning: at your own risk" >> $SVC_CONF &&
        echo "automount no" >> $SVC_CONF &&
        echo "# how many seconds to wait until either auto mount or give up" >> $SVC_CONF &&
        echo "timeout_max 15" >> $SVC_CONF &&
        echo "" >> $SVC_CONF
}

#
#   delete conf file
#
uninstall_hpubk_conf() {
    rm -f $SVC_CONF
}

#
#   generate service file /etc/systemd/system/hpubk.service
#   copy this script to /usr/local/bin/hpubk
#   reload the systemd daemon
#   start hpubk service
#
install_hpubk_service() {
    # create a service that executes this script with --service at startup
    echo "$SNAME installing $SVC_NAME service"
    
    echo "# $FNAME" > $FN_SERVICE &&
        echo "# installed on $INSTALL_TS by $CURRENT_USER" >> $FN_SERVICE &&
        echo "[Unit]" >> $FN_SERVICE &&
        echo "Description=$FNAME" >> $FN_SERVICE &&
        echo "" >> $FN_SERVICE &&
        echo "[Service]" >> $FN_SERVICE &&
        echo "Environment=HPUBK_USER=$CURRENT_USER" >> $FN_SERVICE &&
        echo "ExecStart=$IFN_SERVICE --service" >> $FN_SERVICE &&
        echo "Restart=always" >> $FN_SERVICE &&
        echo "RestartSec=5" >> $FN_SERVICE &&
        echo "" >> $FN_SERVICE &&
        echo "[Install]" >> $FN_SERVICE &&
        echo "WantedBy=multi-user.target" >> $FN_SERVICE &&
        echo "Alias=hpusbbackup usbbackup bkusb" >> $FN_SERVICE &&
        echo "Starting service $SVC_NAME ..." &&
        cp $0 $IFN_SERVICE &&
        install_hpubk_conf &&
        systemctl daemon-reload &&
        systemctl start $SVC_NAME
}

#
#   stop hpubk service
#   remove /etc/systemd/system/hpubk.service file
#   remove conf file from /etc/hpubk.conf
#
uninstall_hpubk_service() {
    echo "$SNAME uninstalling $SVC_NAME service"
    
    systemctl is-active --quiet hpubk &&
        systemctl stop $SVC_NAME || echo "$SNAME $SVC_NAME not running" &&
        rm -f $IFN_SERVICE &&
        uninstall_hpubk_conf
}

#
#   install dependencies
#   then the udev rule
#   and then the service
#
install_hpubk() {
    echo "$SNAME installing..."
    install_deps &&
        install_hpubk_udev_rule &&
        install_hpubk_service
}

#
#   remove udev rule
#   remove hpubk.service
#
uninstall_hpubk() {
    echo "$SNAME uninstalling"
    
    uninstall_hpubk_dev_rule &&
        uninstall_hpubk_service &&
        echo "$SNAME uninstall complete!" ||
    echo "$SNAME something went wrong ..."
}

################################################################################
#   SECTION SERVICE
################################################################################

#
#   main backup function
#
hpubk_service_backup() {
    DEV=$1
    MOUNT_POINT=$2
    AUTO_MOUNT_POINT=$3

    BKDIR="$MOUNT_POINT/.$SVC_NAME"
    BKLIST="$BKDIR/list"
    LOG_DIR="$BKDIR/logs"
    MDATE=$(date +"%Y_%m_%d")
    MTIME=$(date +"%H_%M_%S")
    MTIMESTAMP="$MDATE\_$MTIME"
    LOG_FILE="$LOG_DIR/"$(date +"%Y_%m_%d_%H_%M_%S")".log"
    
    if [ ! -f $BKLIST ]; then
        echo "$DEV@$MOUNT_POINT does not contain a backup list at $BKLIST skipping"
        return 0
    fi
    
    echo "backing up to $DEV@$MOUNT_POINT"
    
    #
    #   a few vars that are useful for backup destination, example
    #   usage for $STORAGE_DEVICE/.hpubk/list
    #
    #   $DOCUMENTS  $USER@$HOSTNAME/$TIMESTAMP/Documents
    #   $PICTURES   $TIMESTAMP/Pictures
    #   $HOME/.config/libreoffice   $DATE/.config
    #

    MHOSTNAME=$(hostname)
    MUSER="$HPUBK_USER"
    MHOME="/home/$MUSER"
    
    MDESKTOP=$(sudo -u $HPUBK_USER xdg-user-dir "DESKTOP")
    MDOWNLOAD=$(sudo -u $HPUBK_USER xdg-user-dir "DOWNLOAD")
    MTEMPLATES=$(sudo -u $HPUBK_USER xdg-user-dir "TEMPLATES")
    MPUBLICSHARE=$(sudo -u $HPUBK_USER xdg-user-dir "PUBLICSHARE")
    MDOCUMENTS=$(sudo -u $HPUBK_USER xdg-user-dir "DOCUMENTS")
    MMUSIC=$(sudo -u $HPUBK_USER xdg-user-dir "MUSIC")
    MPICTURES=$(sudo -u $HPUBK_USER xdg-user-dir "PICTURES")
    MVIDEOS=$(sudo -u $HPUBK_USER xdg-user-dir "VIDEOS")
    
    TSBEGIN=$(date +"%s")
    
    mkdir -p $LOG_DIR &&
        echo "reading backup file $BKLIST" &&
        while read line;
        do
            # ignore empty lines
            if [ -z "$line" ]; then
                continue
            fi
            
            # ignore comment lines
            if echo $line | grep -Eq "^#"; then
                continue
            fi
            
            #
            # replace variables with actual values
            #
            # WARNING:
            #   sed doesn't like the replacement string to contain forward slash /
            #   many of the variables DO contain forward slash, and so we'll use
            #   ampersand & as delimiter, sed likes that, sed is happy!
            #
            line=$(echo $line | sed "s&\$HOSTNAME&$MHOSTNAME&g")
            line=$(echo $line | sed "s&\$USER&$MUSER&g")
            line=$(echo $line | sed "s&\$HOME&$MHOME&g")
            # TIMESTAMP must be before TIME
            line=$(echo $line | sed "s&\$TIMESTAMP&$MTIMESTAMP&g")
            line=$(echo $line | sed "s&\$DATE&$MDATE&g")
            line=$(echo $line | sed "s&\$TIME&$MTIME&g")
            
            line=$(echo $line | sed "s&\$DESKTOP&$MDESKTOP&g")
            line=$(echo $line | sed "s&\$DOWNLOAD&$MDOWNLOAD&g")
            line=$(echo $line | sed "s&\$TEMPLATES&$MTEMPLATES&g")
            line=$(echo $line | sed "s&\$PUBLICSHARE&$MPUBLICSHARE&g")
            line=$(echo $line | sed "s&\$DOCUMENTS&$MDOCUMENTS&g")
            line=$(echo $line | sed "s&\$MUSIC&$MMUSIC&g")
            line=$(echo $line | sed "s&\$PICTURES&$MPICTURES&g")
            line=$(echo $line | sed "s&\$VIDEOS&$MVIDEOS&g")
            
            #
            # forward the current backup line and mount point
            # awk is going to create MOUNT_POINT/dir if it doesn't exist
            # then call rsync with $SRC $MOUNT_POINT/$DST, where
            #   SRC         -> backup source directory
            #   MOUNT_POINT -> storage device mount point
            #   DST         -> backup destination directory
            #
            # example .hpubk/list
            #
            #   $DESKTOP $USER/Desktop
            #
            # example MOUNT_POINT
            #
            #   /media/usb_sticky
            #
            # awk will receive
            #
            #   $DESKTOP $USER/DESKTOP /media/usb_sticky
            #
            # rsync will be executed
            #
            #   rsync [OPTIONS] /home/$USER/Desktop /media/usb_sticky/$USER/Desktop
            #
            echo $line $MOUNT_POINT;
        done < $BKLIST |
        awk '{ system("mkdir -p \x27"$3"/"$2"\x27");\
            system("rsync -rltzuv \x27"$1"\x27\x20\x27"$3"/"$2"\x27") }' | tee -a $LOG_FILE
    
            #
            # rsync flags:
            #    -r, --recursive    recurse into directories
            #    -l, --links        copy symlinks as symlinks
            #    -t, --times        preserve modification times
            #    -z, --compress     compress file data during the transfer
            #    -u, --update       skip files that are newer on the receiver
            #    -v, --verbose      increase verbosity
            #
    
    TSEND=$(date +"%s")
    
    TSDIFF=$(($TSEND - $TSBEGIN))
    TSMIN=$(($TSDIFF/60))
    TSSEC=$(($TSDIFF%60))
    
    echo "--- backup complete after $TSMIN min $TSSEC sec @ "$(date +"[%Y-%m-%d %H:%M:%S]") >> $LOG_FILE
    
    notify_send normal "$DEV Backup complete!"
    
    #
    # was the drive auto-mounted?
    #
    if [ ! -z "$AUTO_MOUNT_POINT" ]; then
        #
        # yeah, let's cleanup
        # unmount and remove directory
        #
        umount $AUTO_MOUNT_POINT &&
            rm -rf $AUTO_MOUNT_POINT &&
            echo "SUCCESS unmounted $AUTO_MOUNT_POINT" ||
            echo "ERROR unmounting $AUTO_MOUNT_POINT"
    fi
}

#
# atempt to automount the current device IF AND ONLY IF the /etc/hpubk.conf file
# has a line "automount yes" and it wasn't mounted within "timeout_max"
#
hpubk_service_automount() {
    DEV=$1
    DEVBASE=$(basename $DEV)
    
    # the following snippet is based on
    # https://serverfault.com/questions/766506/automount-usb-drives-with-systemd#answer-767079
    
    # try to fetch partition label
    eval $(/sbin/blkid -o udev ${DEV})

    # figure out a mount point to use
    LABEL=${ID_FS_LABEL}
    if [ -z "${LABEL}" ]; then
        LABEL=${DEVBASE}
    elif grep -q " $AUTOMOUNT_BASE/${LABEL} " /etc/mtab; then
        # already in use, make a unique one
        LABEL="$LABEL-${DEVBASE}"
    fi
    
    # define a mount point
    MOUNT_POINT="$AUTOMOUNT_BASE/${LABEL}"

    # create mount point directory
    mkdir -p ${MOUNT_POINT}

    # global mount options
    OPTS="rw,relatime"

    # file system type specific mount options
    if [ ${ID_FS_TYPE} = "vfat" ]; then
        OPTS="$OPTS,users,gid=100,umask=000,shortname=mixed,utf8=1,flush"
    fi
    
    # try to mount
    if ! /bin/mount -o ${OPTS} ${DEV} ${MOUNT_POINT}; then
        notify_send critical "Error mounting $DEV"
        echo "Error mounting ${DEV} (status = $?)"
        /bin/rmdir ${MOUNT_POINT}
        return 1
    fi
    
    echo $MOUNT_POINT
    return 0
}

#
# give the system some time before attempting to automount or give up
#
hpubk_service_wait_mnt() {
    DEV=$1
    echo "waiting for $DEV to be mounted"
    
    MOUNT_POINT=""
    
    AUTO_MOUNT_POINT=""
    
    # try to read timeout_max from conf file
    TIMEOUT_MAX=$(grep timeout_max $SVC_CONF | head -n 1 | awk '{print $2}')
    
    # ensure a default value for timeout_max
    TIMEOUT_MAX=${TIMEOUT_MAX:-15}
    
    # countdown timer in seconds
    TIMEOUT_CNT=$TIMEOUT_MAX
    
    # loop until device is mounted or we give up
    while [ -z "$MOUNT_POINT" ];
    do
        sleep 1
        # fetch mount point
        MOUNT_POINT=$(grep "$DEV" /proc/mounts | awk '{ print $2 }')
        
        # countdown
        TIMEOUT_CNT=$(($TIMEOUT_CNT - 1))
        
        # should we give up?
        if [ $TIMEOUT_CNT -le 0 ]; then
            # read automount value from conf
            AUTOMOUNT=$(grep automount $SVC_CONF | head -n 1 | awk '{print $2}')
            
            # should we automount?
            if [ "$AUTOMOUNT" = "yes" ]; then
                #
                # the user wants automount
                # we'll do it, IF AND ONLY IF she or he is logged in!
                #
                if [ $(who | grep $HPUBK_USER | wc -l) -lt 1 ]; then
                    #
                    # user IS NOT logged in, bail out!
                    # no data exfil today mister
                    #
                    echo "user [$HPUBK_USER] is NOT logged in, skippoing automount due to security risks"
                    return 1
                fi
            
                echo "attempting automount of $DEV based on conf file $SVC_CONF"
                
                # try to automount
                MOUNT_POINT=$(hpubk_service_automount $DEV)
                
                # did we succeed?
                if [ $? -ne 0 ]; then
                    return 1
                fi
                
                AUTO_MOUNT_POINT=$MOUNT_POINT
            else
                notify_send critical "$DEV is not mounted!"
                echo "$DEV was not mounted within $TIMEOUT_MAX seconds"
                return 1
            fi
        fi
    done
    echo "$DEV mounted at $MOUNT_POINT"
    hpubk_service_backup $DEV $MOUNT_POINT $AUTO_MOUNT_POINT
}

#
# read /tmp/hpubk.pipe line by line to infinity and beyond!
#
hpubk_service_listen() {
    echo "waiting for USB devices ..."
    # wait for the UDEV rule to kick in when a USB device is plugged in
    while true
    do
        if read DEV < $COM_PIPE; then
            echo "$DEV plugged in, I got this!"
            hpubk_service_wait_mnt $DEV
        fi
    done
}

#
# remove /tmp/hpubk.pipe file if it exists
# create a new named pipe
# wait for usb devices
#
hpubk_service() {
    echo "service up for user: $HPUBK_USER"
    
    rm -f $COM_PIPE &&
        mkfifo $COM_PIPE &&
        hpubk_service_listen
}

################################################################################
#   SECTION CONFIG
################################################################################

#
# check if we can improve user experience
#
check_config() {
    #
    # check if thunar is available
    #
    THUNAR_BIN=$(command -v thunar)
    if [ -z "$THUNAR_BIN" ]; then
        # thunar isn't available
        exit 0
    fi
    #
    # thunar is available, notify user of additional options
    #
    echo ""
    echo "\e[32mit looks like you have thunar installed"
    echo "I can configure it for a better experience if you run"
    echo ""
    echo "\t$ $SVC_NAME --cfg-thunar"
    echo ""
}

#
# generate default backup list in current directory order based on MY priorities
# if the file already exists it will be overwritten!
#
cfg_default() {
    BKDIR="./.$SVC_NAME"
    BKLIST="$BKDIR/list"
    mkdir -p $BKDIR &&
        echo "#" > $BKLIST &&
        echo "# auto generated backup list" >> $BKLIST &&
        echo "# "$(date +"%c") >> $BKLIST &&
        echo "# by $CURRENT_USER@"$(hostname) >> $BKLIST &&
        echo "#" >> $BKLIST &&
        echo "# available variables:" >> $BKLIST &&
        echo "#   DATE, TIME, TIMESTAMP" >> $BKLIST &&
        echo "#   HOSTNAME, USER" >> $BKLIST &&
        echo "#   HOME, DESKTOP, DOWNLOAD, TEMPLATES" >> $BKLIST &&
        echo "#   PUBLICSHARE, DOCUMENTS, MUSIC, PICTURES, VIDEOS" >> $BKLIST &&
        echo "#" >> $BKLIST &&
        echo "# notes:" >> $BKLIST &&
        echo "#   - variables must be prefixed with $ character" >> $BKLIST &&
        echo "#   - blank lines are ignored" >> $BKLIST &&
        echo "#   - comments start with # character" >> $BKLIST &&
        echo "#" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# documents directory" >> $BKLIST &&
        echo "\$DOCUMENTS \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# pictures directory" >> $BKLIST &&
        echo "\$PICTURES \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# desktop directory" >> $BKLIST &&
        echo "\$DESKTOP \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# music directory" >> $BKLIST &&
        echo "\$MUSIC \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# videos directory" >> $BKLIST &&
        echo "\$VIDEOS \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# downloads directory" >> $BKLIST &&
        echo "\$DOWNLOAD \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# templates directory" >> $BKLIST &&
        echo "\$TEMPLATES \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "# public directory" >> $BKLIST &&
        echo "\$PUBLICSHARE \$USER@\$HOSTNAME/\$TIMESTAMP" >> $BKLIST &&
        echo "" >> $BKLIST &&
        echo "default backup configuration generated" &&
        echo "location: $BKLIST"
}

cfg_thunar() {
    #
    # check if thunar is available
    #
    THUNAR_BIN=$(command -v thunar)
    if [ -z "$THUNAR_BIN" ]; then
        echo "thunar not found, bailing out!"
        exit 1
    fi
    echo "found thunar: $THUNAR_BIN"
    #
    # add thunar custom actions
    #
    echo "adding $SVC_NAME custom action in thunar"
    ACTION="<action>\n\
\t<icon>utilities-terminal</icon>\n\
\t<name>$SVC_NAME default config</name>\n\
\t<unique-id>1583177476120399-1</unique-id>\n\
\t<command>exo-open --working-directory %f --launch TerminalEmulator $SVC_NAME --cfg-default</command>\n\
\t<description>$SVC_NAME default backup configuration</description>\n\
\t<patterns>*</patterns>\n\
\t<startup-notify/>\n\
\t<directories/>\n\
</action>\n\
</actions>"
    CFG_FILE="$HOME/.config/Thunar/uca.xml"
    echo $CFG_FILE
    sed -i "s/<\/actions>//" $CFG_FILE && echo $ACTION >> $CFG_FILE

    #
    # check if thunar-volman is available
    #
    THUNAR_VOLMAN_BIN=$(command -v thunar-volman)
    if [ -z "$THUNAR_VOLMAN_BIN" ]; then
        echo "thunar-volman not found, bailing out!"
        exit 1
    fi
    echo "found thunar-volman: $THUNAR_VOLMAN_BIN"
    #
    # enable auto-mount drives
    #
    xfconf-query -n --channel thunar-volman --property "/automount-drives/enabled" -t "bool" -s "true"
    echo "enabling auto-mount for drives"
    #
    # enable auto-mount media
    #
    echo "enabling auto-mount for media"
    xfconf-query -n --channel thunar-volman --property "/automount-media/enabled" -t "bool" -s "true"
}

################################################################################
#   SECTION HELP
################################################################################

print_help_vars() {
    echo ""
    echo "$SVC_NAME variables:"
    echo "\t \$HOSTNAME \tSystem hostname"
    echo "\t \$USER \t\tUser that installed $SVC_NAME"
    echo "\t \$HOME \t\tUser home directory"
    echo "\t \$DATE \t\tDate at the time of backup: YEAR_MONTH_DAY"
    echo "\t \$TIME \t\tTime at the time of backup: HOUR_MINUTE_SECOND"
    echo "\t \$TIMESTAMP \tTimestamp at the time of backup: YEAR_MONTH_DAY_HOUR_MINUTE_SECOND"
    echo "\t \$DESKTOP \tFull path to user [Desktop] directory"
    echo "\t \$DOWNLOAD \tFull path to user [Downloads] directory"
    echo "\t \$TEMPLATES \tFull path to user [Templates] directory"
    echo "\t \$PUBLICSHARE \tFull path to user [Public/Share] directory"
    echo "\t \$DOCUMENTS \tFull path to user [Documents] directory"
    echo "\t \$MUSIC \tFull path to user [Music] directory"
    echo "\t \$PICTURES \tFull path to user [Pictures] directory"
    echo "\t \$VIDEOS \tFull path to user [Videos] directory"
    echo ""
}

print_help_howto() {
    echo ""
    echo "$SVC_NAME how to"
    echo ""
    echo "1. Execute this script with root privileges"
    echo ""
    echo "\t$ sudo $0 --install"
    echo ""
    echo "2. Ensure that removable drives and media are automatically mounted"
    echo "\tthis depends on your desktop environment"
    echo "\tXFCE: Applications > Settings > Removable Drives and Media check off"
    echo ""
    echo "\t\t[X] Mount removable drives when hot-plugged"
    echo "\t\t[X] Mount removable media when inserted"
    echo ""
    echo "\tAlternatively, open $SVC_CONF and set automount to yes"
    echo ""
    echo "3. Plugin your favorite USB stick"
    echo "4. Open a terminal and navigate to the root directory of the usb mounted location"
    echo "5. Execute the following command to create a backup configuration on the USB stick"
    echo ""
    echo "\t$ $SVC_NAME --cfg-default"
    echo ""
    echo "6. Unplug your USB stick, give it a second and plug it back in"
    echo "7. Wait for [$SVC_NAME] to start backing up"
    echo ""
}

print_help() {
    echo ""
    echo "$FNAME"
    echo "usage:"
    echo "\t$SNAME [option]"
    echo "options:"
    echo "\t--install\t sets your system up"
    echo "\t--uninstall\t uninstalls and removes all traces of HPUBK"
    echo "\t--service\t run HPUBK in service mode"
    echo "\t--cfg-default\t create backup configuration directory and file in the root of your USB device"
    echo "\t--cfg-thunar\t configure Thunar file manager and Thunar volume manager"
    echo "\t--vars\t\t print available backup variables"
    echo "\t--howto\t\t print how to use"
    echo ""
}

case $1 in
    "--install") install_hpubk && check_config;;
    "--uninstall") uninstall_hpubk;;
    "--service") hpubk_service;;
    "--cfg-default") cfg_default;;
    "--cfg-thunar") cfg_thunar;;
    "--PKG_DEB") echo $PKG_DEB;;
    "--vars") print_help_vars;;
    "--howto") print_help_howto;;
    "--help") print_help;;
    "-h") print_help;;
esac

[ "$#" -ne 1 ] && print_help



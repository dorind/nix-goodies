# HotPlug USB Backup

Small shell script, less than 1,000 lines of code with comments(!), that sets
your system up for automatic backup to a USB storage device when plugged in.

### Quick demo on YouTube

[![](http://img.youtube.com/vi/RuQQP3Q79rA/0.jpg)](http://www.youtube.com/watch?v=RuQQP3Q79rA "HPUBK quick demo")

The only dependency right now is `rsync`, if you don't count `systemd`, therefore
the script should work pretty much on any linux distribution with minimal
modifications, if you do so, please drop me a line with your changes so that
others may benefit from your work and improve it!

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation

### Have any ideas? Drop me a line!

### Current to do

1. [ ] Device whitelist
2. [ ] Pre/Post backup scripts

## Install

```shell
$ sudo ./install-hpubk.sh --install
```

### If you use thunar file manager

```shell
$ sudo ./install-hpubk.sh --install && hpubk --cfg-thunar
```

**Notes**

1. There are some very useful variables available for the backup process, to find them out

```shell
$ hpubk --vars
```

Example
|Variable|Description|
|---|---|
|$HOSTNAME 	    |System hostname|
|$USER 		    |User that installed hpubk|
|$HOME 		    |User home directory|
|$DATE 		    |Date at the time of backup: YEAR_MONTH_DAY|
|$TIME 		    |Time at the time of backup: HOUR_MINUTE_SECOND|
|$TIMESTAMP 	|Timestamp at the time of backup: YEAR_MONTH_DAY_HOUR_MINUTE_SECOND|
|$DESKTOP 	    |Full path to user \[Desktop] directory|
|$DOWNLOAD 	    |Full path to user \[Downloads] directory|
|$TEMPLATES 	|Full path to user \[Templates] directory|
|$PUBLICSHARE 	|Full path to user \[Public/Share] directory|
|$DOCUMENTS 	|Full path to user \[Documents] directory|
|$MUSIC 	    |Full path to user \[Music] directory|
|$PICTURES 	    |Full path to user \[Pictures] directory|
|$VIDEOS 	    |Full path to user \[Videos] directory|

2. Whenever you wish to refresh your memory, simply run

```shell
$ hpubk --help
```

or

```shell
$ hpubk --howto
```

## Uninstall

```shell
$ sudo ./install-hpubk.sh --uninstall
```

## Create default backup configuration

1. Open favorite terminal
2. Navigate to root directory of your USB storage device
3. Execute the following command

```shell
$ hpubk --cfg-default
```

**Notes**

- if there's any configuration available, it will be overwritten
- if you've ran `hpubk --cfg-thunar`, you can use Thunar to navigate to USB
storage device, right-click inside that directory and select `hpubk default config`

watch hpubk do it's job in real time, CTRL-C when you wish to exit

```shell
$ sudo journalctl -f -u hpubk
```

If you'd like to learn more about how it works, check the source code, a simple diagram below

```
   +---------------------------------+
   |  USB storage device plugged in  |
   +---------------------------------+
                     |
                     |
              +-------------+
              |  udev rule  |
              +-------------+
                     |
                     |
           +-------------------+
           |  /tmp/hpubk.pipe  |
           +-------------------+
                     |
                     |
           +-------------------+
           |  hpubk --service  |
           +-------------------+
                     |
                     |
     +-------------------------------+
     |  $STORAGE_DEVICE/.hpubk/list  |
     +-------------------------------+
                     |
                     |
                +---------+
                |  rsync  |
                +---------+
```



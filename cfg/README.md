### firefox lang rm
remove extra languages, keeps english only

```shell
$ sudo ./cfg-firefox-lang-rm.sh
```

* Tested on Debian 10

### libreoffice lang rm
remove extra languages, keeps english only

```shell
$ sudo ./cfg-libreoffice-lang-rm.sh
```

* Tested on Debian 10

### xfce4 config all
calls all cfg-xfce4-* scripts one by one

```shell
$ ./cfg-xfce4-all.sh
```

### xfce4 panel and plugins
configure xfce4 to use a top panel and it's plugins

```shell
$ ./cfg-xfce4-panel-plugins.sh
```

* Tested on Debian 10, should work on any distro
* Super fast

### xfce4 shortcuts
configure xfce4 productivity shortcuts

```shell
$ ./cfg-xfce4-shortcuts.sh
```
**Note** that a directory ~/Pictures/Screenshots will be created if it doesn't exist

|shortcut|action|
|---|---|
|SUPER-D               |show desktop|
|SHIFT-SUPER-DOWN      |tile windows down|
|SHIFT-SUPER-UP        |tile windows up|
|SUPER-1               |workspace 1|
|SUPER-2               |workspace 2|
|SUPER-3               |workspace 3|
|SUPER-4               |workspace 4|
|SUPER-LEFT            |tile window left|
|SUPER-RIGHT           |tile window right|
|SUPER-UP              |maximize/restore window|
|SUPER-E               |thunar file manager|
|SUPER-T               |xfce terminal|
|SUPER-R               |xfce appfinder|
|CTRL-ESC              |xfce settings manager|
|SHIFT-CTRL-ALT-!      |flameshot capture screenshot|
|SHIFT-CTRL-ALT-$      |flameshot gui mode|
|PRTSCN                |flameshot copy to clipboard|
|SHIFT-CTRL-ESC        |gnome system monitor|

* Tested on Debian 10, should work on any distro
* Super fast

### xfce4 theme and icons

**Note** you should run `install-xfce-themes.sh` first

```shell
$ ./cfg-xfce4-theme-wm.sh
```

* Tested on Debian 10, should work on any distro
* Super fast

### xfce4 thunar custom config

```shell
$ ./cfg-xfce4-thunar.sh
```

* Tested on Debian 10, should work on any distro
* Super fast



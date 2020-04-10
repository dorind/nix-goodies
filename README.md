# nix-goodies
collection of scripts for nix systems

for install scripts pass `--cleanup` as first arg to remove sources

* `rc` directory contains various configuration files
* `res` directory contains resource files

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

### install-albert.sh
download & install latest version of albert from source

```shell
$ sudo ./install-albert.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* OKish installation speed

### install-checkinstall.sh
download & install latest version of checkinstall from source

```shell
$ sudo ./install-checkinstall.sh
```

* Tested on Debian 10
* Requires minimal user interaction
* Fast installation

### install-ffmpeg.sh
download & install latest version of ffmpeg from source

```shell
$ sudo ./install-ffmpeg.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation

### install-golang.sh
download & install latest version of golang

```shell
$ sudo ./install-golang.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation

### install-liteide.sh
download & install latest version of LiteIDE

```shell
$ sudo ./install-liteide.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation
* Includes `.desktop` file and icon

### install-lz4.sh
download & install latest version of lz4 from source

```shell
$ sudo ./install-lz4.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation

### install-opencv.sh
download & install latest version of opencv and opencv-contrib from source

```shell
$ sudo ./install-opencv.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Slow installation, run it and walk away

### install-proio-cpp.sh
download & install latest version of proio for cpp

```shell
$ sudo ./install-proio-cpp.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation
* Requires lz4(`install-lz4.sh`) and protobuf(`install-protobuf.sh`) to be installed

### install-protobuf.sh
download & install latest version of protobuf

```shell
$ sudo ./install-protobuf.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Slow installation, run it and walk away

### install-root-cern.sh
download & install latest version of ROOT from source

```shell
$ sudo ./install-root-cern.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Slow installation, run it and walk away

### install-vim-airline.sh
download & install latest vim airline plugin

```shell
$ sudo ./install-vim-airline.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Very installation

### install-vim-completor.sh
download & install latest vim completor plugin

```shell
$ sudo ./install-vim-completor.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Very installation

### install-vim-fugitive.sh
download & install latest vim fugitive plugin

```shell
$ sudo ./install-vim-fugitive.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Very installation

### install-vim.sh
download & install latest version of vim from source

```shell
$ sudo ./install-vim.sh
```

* With python3, terminal, ruby, perl and lua, native arch
* Without GUI
* Tested on Debian 10
* Doesn't require user interaction
* Very installation

### install-xfce4-themes.sh
download & install **my** prefered themes and icons

```shell
$ sudo ./install-xfce4-themes.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Fast installation

### mktmpfs.sh
create, remove, save & load a temporary file system

create a 512MiB ramdisk

```shell
$ sudo ./mktmpfs.sh new RAMDISK_NAME 512M
```

create a 2GiB ramdisk

```shell
$ sudo ./mktmpfs.sh new RAMDISK_NAME 512M
```

remove a ramdisk

```shell
$ sudo ./mktmpfs.sh remove RAMDISK_NAME
```

save a ramdisk

```shell
$ sudo ./mktmpfs.sh save RAMDISK_NAME ~/ramdisk_name_saved
```

load a ramdisk

```shell
$ sudo ./mktmpfs.sh load ~/ramdisk_name_saved
```

load a ramdisk with new name

```shell
$ sudo ./mktmpfs.sh load ~/ramdisk_name_saved NEW_NAME
```

* Tested on Debian 10
* Prints out only errors or mount location if **new** is invoked with -pp

### pkg-list.sh
list all packages required by all install scripts, flags:

* `--DEB` list all debian packages

```shell
$ ./pkg-list.sh --DEB
```

Count the number of required packages

```shell
$ ./pkg-list.sh --DEB | wc -l
```

Simpulate install on Debian based distros

**Note**: there's no sudo!

```shell
$ apt-get install --dry-run $(./pkg-list.sh --DEB | xargs echo)
```

Install all packages in one go, grab a coffee!

```shell
$ sudo apt-get install $(./pkg-list.sh --DEB | xargs echo)
```


Various installation scripts, pass `--cleanup` as first arg to remove sources

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

### install-flashrom.sh
download & install latest version of flashrom from source

```shell
$ sudo ./install-flashrom.sh
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

### install-openscad.sh
download & install latest version of OpenSCAD from source

```shell
$ sudo ./install-openscad.sh
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

or a specific version

```shell
$ sudo ./install-protobuf.sh --version=3.11.1
```

in the above example we're installing version 3.11.1 from Dec 3, 2019

**note**: version must have the following format XX.YY.ZZ, where XX, YY and ZZ are one or more digits separated by period

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



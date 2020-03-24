# nix-goodies
collection of scripts for nix systems


### install-checkinstall.sh

download & install latest version of checkinstall from source

```shell
$ sudo ./install-checkinstall.sh
```

* Tested on Debian 10
* Requires minimal user interaction
* Fast installation


### install-root-cern.sh

download & install latest version of ROOT from source

```shell
$ sudo ./install-root-cern.sh
```

* Tested on Debian 10
* Doesn't require user interaction
* Slow installation, run it and walk away

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


# miscellaneous scripts

### mkswapfile.sh
create and remove swapfiles easily

create a swapfile of size equal to amount of ram

```shell
$ sudo ./mkswapfile.sh new
```

create a swapfile twice as large as amount of ram

```shell
$ sudo ./mkswapfile.sh new x2
```

remove the swapfile

```shell
$ sudo ./mkswapfile.sh remove
```

* Tested on Debian 10, should work on most linux distros
* Fast operations via `fallocate`, falls back to `dd` in case of error which is slower
* Nobody needs swap until they do

### mktmpfs.sh
create, remove, save & load a temporary file system

create a 512MiB ramdisk

```shell
$ sudo ./mktmpfs.sh new RAMDISK_NAME 512M
```

create a 2GiB ramdisk

```shell
$ sudo ./mktmpfs.sh new RAMDISK_NAME 2G
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



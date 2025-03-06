# FreeSurfer的安装

首先去官网下载.deb或者.tar.gz的文件，安装或者解包

无论哪种，都需要去`.bashrc`添加

```bash
# manually inserted by RJX on 2024/12/12 (FreeSurfer)
export FREESURFER_HOME=/usr/local/freesurfer/6
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export PATH=$PATH:/usr/local/freesurfer/6/bin
```

完事去`$FREESURFER_HOME`文件夹下添加`licence.txt`文件，内容如下：

```
jianxiong@mail.ustc.edu.cn                                                                                        
57909
 *CHZK6MKDkk4A
 FSceDt7KYaCnU
```

如果是ubuntu 20.04系统，使用低版本的`freeview`时，可能会报错如下：

```bash
freeview.bin: error while loading shared libraries: libpng12.so.0: cannot open shared object file: No such file or directory
```

原因是ubuntu 16+之后的系统不支持`version 12 of libpng`，需要以下命令：

```bash
sudo add-apt-repository ppa:linuxuprising/libpng12
sudo apt update
sudo apt install libpng12-0
```

再次键入`freeview`，成功打开

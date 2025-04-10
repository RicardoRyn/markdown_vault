参考：[Ubuntu20.04显卡驱动安装](https://zhuanlan.zhihu.com/p/308407850)

# 一、查看电脑显卡型号

```bash
ubuntu-drivers devices
```

终端显示：

然后去NVIDIA官网下载对应型号，对应系统的驱动，例如`NVIDIA-Linux-x86_64-535.183.01.run`



# 二、安装依赖

```bash
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler
sudo apt-get install --no-install-recommends libboost-all-dev
sudo apt-get install libopenblas-dev liblapack-dev libatlas-base-dev
sudo apt-get install libgflags-dev libgoogle-glog-dev liblmdb-dev
```



# 三、禁用系统默认显卡驱动

打开系统黑名单设置文件：

```bash
sudo vim /etc/modprobe.d/blacklist.conf
```

然后在文档末尾写入：

```bash
blacklist nouveau  # 禁止系统加载nouveau模块。nouveau是开源的NVIDIA显卡驱动程序，有时在安装官方的NVIDIA驱动程序时，需要先禁用nouveau以避免冲突。
options nouveau modeset=0  # modeset选项用于控制内核模式设置（Kernel Mode Setting, KMS），将其设置为0会禁用内核模式设置。尽管nouveau模块被黑名单禁止加载，这行设置参数的命令有时被添加以确保即使nouveau被加载，它也不会使用模式设置。
```

然后更新初始内存文件系统：

```bash
sudo update-initramfs -u  # 使系统启动时可以加载最新的内核模块和配置文件。-u 选项表示更新现有的initramfs镜像，而不是生成一个新的镜像。
```

电脑重启，输入下列指令进行确认，若无输出，则禁用成功：

```bash
lsmod | grep nouveau
```



# 四、配置环境变量

在`.bashrc`中添加：

```bash
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
```

```bash
. ~/.bashrc
```



# 五、卸载原有NVIDIA驱动

```bash
sudo apt-get --purge remove nvidia*
sudo apt autoremove

# 或者执行
sudo /usr/bin/nvidia-uninstall
```

键入以下命令查看是否删除干净：

```bash
lsmod | grep nvidia
```

如果没有，再尝试删除相关组件：

```bash
sudo rmmod nvidia_uvm
sudo rmmod nvidia
```

> 如果没有删除干净，则会在安装NVIDIA驱动时报错“An NVIDIA kernel module ‘nvidia-xxx‘ appears to already be loaded in your kernel”



# 六、安装NVIDIA驱动

退出图形界面：`ctrl + alt + F1~F6`

禁用图形界面：

```bash
sudo service lightdm stop
```

如果提示：“unit lightdm.service not loaded”

则需要先安装LightDm：`sudo apt install lightdm`

安装驱动文件：

```bash
sudo chmod +x NVIDIA-Linux-x86_64-535.183.01.run
sudo ./NVIDIA-Linux-x86_64-535.183.01.run --no-opengl-files --no-x-check --no-nouveau-check
```

> –no-opengl-files                   不安装OpenGL文件。这个参数最重要
>
> –no-x-check                           安装驱动时不检查X服务
>
> –no-nouveau-check               安装驱动时不检查nouveau 


```
install nvidia's 32-bit compatibility libraries？(Yes)

如果您需要在64位系统上运行32位应用程序或游戏，那么在安装NVIDIA驱动程序时，当提示是否安装32位兼容库时，您应该选择“是”（Yes）。这样可以确保您的系统具备运行32位图形应用程序的能力。如果您不需要运行32位应用程序，或者确定不需要这些库，可以选择“否”（No）。
但是，通常建议安装这些库以避免将来可能出现的兼容性问题。

would you like to run the nvidia-xconfig utility to automatically update your X configuration file so that the NVIDIA X driver will be used when you restart X? Any pre-existing X configuration file will be backed up. (No)
如果您刚刚安装了NVIDIA驱动程序，并且希望确保新的驱动程序在您下次启动X服务器时被使用，那么您应该选择“是”（Yes）。这将允许`nvidia-xconfig`工具自动更新您的X配置文件，以便NVIDIA X驱动程序在重启X时被激活。此外，任何现有的X配置文件都会被备份，因此您可以放心选择“是”，因为这不会丢失您当前的配置。
```


# 七、安装完成并验证

恢复图形界面：

```bash
sudo service lightdm start
```

回到图形界面：`ctrl + alt +F7`

安装成功后，挂载NVIDIA驱动，键入：

```bash
modprobe nvidia
```

如果失败则需要去BIOS中关闭`secure boot`选项

重启。

键入：

```bash
sudo nvidia-smi  # 如果输出内容，则安装成功
```



# 八、ubuntu自动更新驱动内核问题

有时候发现`eddy`报错，然后键入`nvidia-smi`，终端显示：

```bash
NVIDIA-SMI has failed because it couldn‘t communicate with the NVIDIA driver.
```

推测原因为：NVIDIA内核驱动版本和系统驱动不一致（内核版本自动更新了，导致新版本内核和原来显卡驱动不匹配）

命令：

```bash
# 查看显卡驱动版本
# nvidia-535.183.01
ls /usr/src | grep nvidia

# 查看显卡内核版本
# Linux ricardo-Mi-Gaming-Laptop-15-6 5.15.0-122-generic #132~20.04.1-Ubuntu SMP Fri Aug 30 15:50:07 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
uname -a
```

更改显卡内核版本与显卡驱动版本匹配，键入：

```bash
sudo apt-get install dkms
sudo dkms install -m nvidia -v 535.183.01
```

再次输入`nvidia-smi`，就能正确显示内容。

禁止驱动内核更新

```bash
uname -a  # 显示Linux ricardo-Mi-Gaming-Laptop-15-6 5.15.0-125-generic #135~20.04.1-Ubuntu SMP Mon Oct 7 13:56:22 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux

sudo apt-mark hold linux-image-5.15.0-125-generic
sudo apt-mark hold linux-modules-extra-5.15.0-125-generic

# 如果想取消禁止内核更新，就使用
sudo apt-mark unhold linux-image-5.15.0-125-generic
sudo apt-mark unhold linux-modules-extra-5.15.0-125-generic
```
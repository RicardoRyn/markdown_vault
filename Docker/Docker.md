本文档使用：https://hub.docker.com/r/scitran/dcm2niix

# Docker的一般使用

在Docker Hub里最好不要直接从右边的`Docker Pull Command`中下载容器container，因为这条命令默认下载最近latest的版本的容器（实际上不是容器，是镜像image，但是可以理解成容器），但是作者可能忘了更新，也就是实际上最新的容器忘了更名为latest，最终导致你下载还是之前的旧版本

应该进入`Tags`中，选择适合的版本

在终端中键入：

```bash
sudo docker pull scitran/dcm2niix:0.8.0_1.0.20200331
```

docker有其自己的管理方式，下载的容器不需要管它在哪

下载以后，可以在任意位置的终端中打开docker，查看已经下载好的容器（image）

```bash
sudo docker image ls
```

本教程使用IOZ猴子（20220106_T3B_02-OM-CR）的原始DICOM文件：

```bash
cp /media/nhp/Elements_SE/RJX/IOZ2_orig/20220106_T3B_02-OM-CR/data/ /media/nhp/Elements_SE/RJX/Docker_learning -r
```

进入这个文件夹下键入：

```bash
ls *.IMA | wc -l  # 终端显示文件数量，即1283,表示有1283张图片slice
```

使用docker：

```bash
sudo docker run --rm -ti \  # i表示在运行的时候看到标准输出
    -v /media/nhp/Elements_SE/RJX/Docker_learning/data:/flywheel/v0/input/dcm2niix_input \  # 把自己电脑里的文件夹挂载到容器里的指定输入文件夹
    -v /media/nhp/Elements_SE/RJX/Docker_learning/output:/flywheel/v0/output \  # 把自己电脑里的文件夹挂载到容器里的指定输出文件夹
    scitran/dcm2niix:0.8.0_1.0.20200331
```

## 进入Docker查看里面的内容

```bash
sudo docker run --entrypoint=/bin/bash --rm -ti \
    -v /media/nhp/Elements_SE/RJX/Docker_learning/data:/flywheel/v0/input/dcm2niix_input \
    -v /media/nhp/Elements_SE/RJX/Docker_learning/output>:/flywheel/v0/output \
    scitran/dcm2niix:0.8.0_1.0.20200331
```

如果不加`--entrypoint`，是有一个默认脚本，会自动运行默认脚本的

加了`--entrypoint`，就会进入容器，可以使用命令行

此时并没有运行DICOM转nii的命令，只是进入了这个容器，但是会创建`output`文件夹（里面是空的），但是`input`文件夹中是有自己的文件的

这个时候从容器中修改`input`文件夹以及`output`文件夹中的内容会导致本机上的文件夹中内容改变，因为这两个文件夹是挂载到容器里面的

进入了容器，可以对其进行各种操作，键入：

```bash
cat /etc/issue  # 可以查看该容器的操作系统
apt update  # 更新一下数据库
apt install vim  # 可以在该容器中安装vim
```

按`ctrl + d`退出容器，一旦退出，原来的改变的内容全部丢失，除非挂载在本地的目录中

# 常用Docker命令

```bash
sudo docker images  # 查看Docker中的所有镜像
# 其中images很好理解，跟平常使用的虚拟机的镜像一个意思，相当于一个模版，而container则是images运行时的的状态
# docker对于运行过的image都保留一个状态（container）

# 可以使用命令docker ps来查看正在运行的container
sudo docker ps  # 查看Docker中的所有容器
# -a ：会列出当前服务器中所有的容器，无论是否在运行
# -s：会列出容器的文件大小（容器增加的大小/容器的虚拟大小）
# -q：仅列出CONTAINER ID 字段
# -l: 显示最后一个运行的容器（无论该容器目前处于什么状态）
# --no-trunc:不对输出进行截断操作，此时可以看到完整的COMMAND，CONTAINER ID

# 如果你退出了一个container而忘记保存其中的数据，你可以使用docker ps -a来找到对应的运行过的container，并使用docker commit命令将其保存为image然后运行

sudo docker rm <container ID>  # 删除一个container
sudo docker rmi <image ID>  # 删除一个image，只有先删除对应的container才能删除其image
```

管理Docker，不再需要管理员权限

```bash
sudo groupadd docker
sudo usermod -G docker -a $USER
# 重启电脑
docker run hello-world
```

# 国内使用Docker格外的令人糟心

首先去阿里云获取镜像加速服务地址：

镜像工具——镜像加速器——加速器地址

```
https://4bs8hd74.mirror.aliyuncs.com
```

修改`/etc/docker/daemon.json`（没有时新建该文件）

```bash
{
    "registry-mirrors": ["https://4bs8hd74.mirror.aliyuncs.com"]
}
```

然后重启Docker Daemon：

```bash
systemctl daemon-reload
```


使用显卡可以 ***显著提升*** dwi数据的处理速度

# BEDPOSTX

## 安装cuda的准备工作

键入：`nvidia`可以查看自己N卡的信息

键入：`nvcc -v`查看自己cuda的版本

cuda9.1支持`eddy_cuda`，`probtrackx_gpu`，`bedpostx_gpu`的运行，所以尽量下载cuda9.1

cuda9.1的安装只支持gcc版本6即6以下

`gcc --version`查看gcc版本

安装gcc键入：`sudo apt install gcc-5 g++-5`

`sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 50 --slave /usr/bin/g++ g++ /usr/bin/g++-5`

选择gcc版本键入：`sudo update-alternatives --config gcc`

## 安装cuda

官网下载cuda9.1的包以及补丁（共3个文件）

安装：

```bash
sudo sh ./cuda-9.1.85_378.26_linux.run
sudo ./cuda_9.1.85.1_linux.run
sudo ./cuda_9.1.85.2_linux.run
sudo ./cuda_9.1.85.3_linux.run
```

配置环境：

```bash
echo 'export PATH=$PATH:/usr/local/cuda-9.1/bin' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-9.1/ib64' >> ~/.bashrc
source ~/.bashrc
```

查看信息键入：`nvidia-smi`

## 检查安装是否成功

键入:`eddy_cuda9.1`出现帮助文档则为安装成功
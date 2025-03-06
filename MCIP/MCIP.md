# 简介

MCIP是自动化所崔玥老师等人开发的算法

目的是生成个体图集

# 使用中遇到的问题

## 1. mcip_drive.m

第60行中我添加了

```matlab
ana_conn = ana_conn(atlas_mask, :);  % add by RJX on 2024/5/21
```

`ana_conn`是seed全脑顶点与target全脑体素的结构连接矩阵

因为并不是所有顶点都属于位于Glasser图集中，例如每半脑共有32k个顶点，但是只有26k个顶点拥有Glasser图集的label，所以需要排除那些没有label的顶点。

亲测不这样改会报错。当然也可以在一开始给定的`fdt_matrix2.dot`文件中，就只包含拥有label的顶点的连接信息。

## 2. gco-v3.0

`mcip.m`中会调用这个名为`gco-v3.0`的包，这是一个用C++编写的，与“图割算法”有关的包

想要使用，就需要用MATLAB调用C++，所以需要电脑中拥有C++编译器

### (1) windows系统

在mingw64官网中下载对应的C++编译器`x86_64-12.2.0-release-win32-seh-rt_v10-rev0`

然后在系统环境变量的`path`中添加对应的路径

最后在matlab中键入

```matlab
setenv('MW_MINGW64-LOC', 'D:\mingw64\x86_64-12.2.0-release-win32-seh-rt_v10-rev0\mingw64');
mex -setup C++;
```

完成配置

### (2) ubuntu系统

ubuntu系统已经安装了gcc5.4，g++5.4

MATLAB提示需要gcc4.9，但是亲测只是警告而不是报错，还是可以用

如果没有装，可以尝试：

```bash
sudo apt-get install gcc-4.9
```

同样在matlab中键入：

```matlab
mex -setup C++
```

---

需要修改，不改会报错，不知道为什么

```bash
cd /usr/local/MATLAB/R2016b/sys/os/glnxa64
ls
rm -rf libstdc++.so.6
sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 libstdc++.so.6
```

在matlab中配置好，能够调用C++之后，进入`gco-v3.0/matlab`，键入：

```matlab
GCO_UnitTest
```

如果成功说明`gco-v3.0`可以正常调用


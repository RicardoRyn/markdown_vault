# 安装picom

picom安装一堆坑😦

首先禁掉fsl，fsl的环境可能导致编译安装失败。
进入`~/.profile`文件，把fsl相关的内容先注释掉。

在bash (最好不要用nushell) 下输入：

```bash
export PKG_CONFIG=/usr/bin/pkg-config # 使用系统自带的pkg_config
```

然后编译安装：

```bash
# 构建系统，检查依赖，生成ninja构建文件
meson setup --buildtype=release build

# ninjia构建工具进行编译
ninja -C build

# 安装把编译好的产物，移动到可执行目录，默认是/usr/local/bin
sudo ninja -C build install
```

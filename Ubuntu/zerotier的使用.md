# 简介

`Zerotier`，一个内网穿透的软件



# 下载安装zerotier

直接键入：

```bash
mkdir -p ~/ZeroTier
cd ~/ZeroTier

# 下载安装
curl -s https://install.zerotier.com | sudo bash
```

安装成功后，可以在`/usr/sbin/`中看到`zerotier-one`和`zerotier-cli`工具



# 启动Zerotier服务

键入：

```bash
sudo service zerotier-one start

# 关闭服务
sudo service zerotier-one stop

# 查看是否启动服务成功
systemctl status zerotier-one.service
# 如果终端显示active和running就是启动成功
```



# 加入虚拟网络

键入：

```bash
sudo zerotier-cli join <你的网络ID>

# 查看虚拟网络状态
sudo zerotier-cli status

# 查看虚拟网络列表（能够获取在虚拟网络中的ip地址）
sudo zerotier-cli listnetworks

# 离开网络
sudo zerotier-cli leave <你的网络ID>
```



# 开机自启（可选）

键入：

```bash
sudo systemctl enable zerotier-one.service

# 查看是否设置自启成功
sudo systemctl is-enabled zerotier-one.service
```



# 卸载

键入：

```bash
sudo apt-get remove zerotier-one
sudo dpkg -P zerotier-one

# 删除配置信息
sudo rm -rf /var/lib/zerotier-one
```


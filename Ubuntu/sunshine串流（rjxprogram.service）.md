# sunshine使用

windows b站BV号：`BV13i421U7zf`

ubuntu下载[v0.23.0](https://github.com/LizardByte/Sunshine/releases/tag/v0.23.0)里的`sunshine.AppImage`

然后给`sunshine.AppImage`可执行权限：

```bash
sudo chmod 755 ./sunshine.AppImage
```

把它放到可运行环境中，然后运行

```bash
sudo mv sunshine.AppImage /usr/local/bin/
sudo sunshine.AppImage  # 注意一定要有超级权限
```

然后根据终端提示，在浏览器里设置

```
https://localhost:47990/
```

如果忘了密码，想要重置密码，键入：

```bash
sunshine.AppImage --creds RicardoRyn 123
```



# ubuntu开机自启sunshine

思路，将ubuntu电脑当作一个服务器，自动特定程序

## 第一步：

创建一个Systemd服务单元文件，即在`/etc/systemd/system/`中创建一个以`.service`结尾的文件（服务单元文件）：

```bash
sudo vim /etc/systemd/system/rjxprogram.service
```

然后复制以下内容：

```
[Unit]
Description=Sunshine Program
After=network.target

[Service]
ExecStart=/usr/local/bin/sunshine.AppImage
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

## 第二步：

重新加载Systemd配置，使新的服务单元文件生效：

```bash
sudo systemctl daemon-reload
```

启动服务：

```bash
sudo systemctl enable rjxprogram.service
```

## 第三步：

验证服务已正确设置：

```bash
sudo systemctl is-enabled rjxprogram.service

# 如果终端显示“enabled”，则服务成功启动
```

重启电脑，平板端能直接串流，完成！



# 非局域网下的串流

需要用到软件`Zerotier`

`Zerotier`的服务器更像是一个路由器，记录了设备A访问设备B，的网络路径，然后把路径通知给双方尝试让AB自己连接。

简单来说，`Zerotier`设置了一个虚拟局域网，所有的设备都在虚拟局域网中相互访问

## 第一步：

首先在windows电脑（被控端）和平板（主控端）安装`Zerotier one`软件

进入`Zerotier`官网，注册然后创建一个网络（Create A Network）

记录网络ID

# 第二步：

被控端电脑（windows），右下角找到`Zerotier one`，右键`Join New Network`，输入刚刚的网络ID

主控端电脑（MIPad），打开`Zerotier one`软件，添加网络，输入网络ID

# 第三步

进入`Zerotier`官网，在刚刚网络中找到2个member，前面沟当选对勾，授权2个电脑能够共用一个虚拟网络

# 第四步

被控端电脑可能防火墙阻断端口的现象

打开windows防火墙和网络保护，进入`高级设置`

`入站规则` --> `新建规则` --> `端口` --> 输入对应的端口号（TCP 48010；UDP 48000；UDP 48010）

# 第五步

打开被控端任务管理器，性能，以太网（zerotier one）

查看IPv4地址

然后在主控端添加电脑，输入刚刚的IPv4地址，完成连接。

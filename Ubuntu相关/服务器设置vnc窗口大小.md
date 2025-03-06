首先通过终端利用ssh进入服务器，为自己的VNC（Virtual Network Console，虚拟网络控制台）打开端口（我的VNC端口是17和18）
```bash
ssh ruanjx@192.168.22.171
# 输入密码

ssh ruanjx@192.168.22.171 -t 'cd ~/RJX ; bash'  # 额外跳转到指定路径下
# 输入密码
```

然后在服务器里运行代码：

```bash
vncserver -geometry 2560x1440 :17  # 注意这里的乘号是字母“x”不是“*”
```

关闭端口键入：

```bash
vncserver -kill :17
```


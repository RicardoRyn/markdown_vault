# ubuntu系统下载samba

```bash
sudo apt-get install samba samba-common
```



# ubuntu系统上创建共享文件夹

```bash
mkdir -p ~/MI_sambashare
sudo chmod -R 777 ~/MI_sambashare
sudo smbpasswd -a ricardo  # 必须是系统用户名字
# 然后输入密码 123
```

 打开配置文件

```bash
sudo vim /etc/samba/smb.conf
```

在配置文件smb.conf最后添加下面的内容（[]中是待共享目录的文件名，path是带共享目录的绝对路径）

```
[share]
comment = share folder
browseable = yes
path = /home/ricardo/share
create mask = 0700
directory mask = 0700
valid users = ricardo
public = yes
available = yes
writable = yes
```

重启Samba服务器

```bash
sudo service smbd restart
sudo systemctl restart smbd
sudo systemctl restart nmbd
```

更新防火墙

```bash
sudo ufw allow 'Samba'
```

剩下的就是在其他局域网下的机器上连接该服务器（一般使用zerotier进行内网穿透）

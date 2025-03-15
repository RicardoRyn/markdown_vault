# 启动TeamSpeak服务

需要获取license

```bash
touch .ts3server_license_accepted
```

然后启动

```bash
./ts3server_startscript.sh start
```



# 防火墙开放端口

serveradmin 账户和 token 都是 TS 的最高权限账户，可修改服务器设置。下文会用到

### 防火墙配置

Teamspeak3 需要以下端口

- UDP: 9987
- TCP: 10011
- TCP: 30033

可以在 `iptables` 中添加

```bash
iptables -A INPUT -p udp --destination-port 9987 -j ACCEPT
iptables -A INPUT -p tcp --dport 10011 -j ACCEPT
iptables -A INPUT -p tcp --dport 30033 -j ACCEPT
```


i3的配置文件中写：

```bash
bindsym $mod+Return exec GLFW_IM_MODULE=ibus kitty
```

如果不是i3环境:

1. 临时：执行`GLFW_IM_MODULE=fcitx5`这会临时设置环境变量，让当前终端可以输入中文，但关闭当前终端后就会失效，适合临时使用
2. 永久：编辑`/etc/environment`文件，在文件中添加`GLFW_IM_MODULE=ibus`,重启电脑就行了

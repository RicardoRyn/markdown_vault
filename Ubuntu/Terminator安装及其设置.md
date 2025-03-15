# Terminator

```bash
sudo apt-get install terminator
```

刚安装完的Terminator没有配置文件，需要自己手动新建，或者在Terminator里的preference随便设置一点东西就会自动生成

`~/.config/terminator/config`里会生成这个layout的配置文件，更改内容如下：

```bash
[global_config]
  geometry_hinting = True
  suppress_multiple_term_dialog = True
  title_transmit_bg_color = "#107c41"  # 更改titlebar颜色为绿色
  #window_state = maximise  # 窗口最大化
[keybindings]
[layouts]
  [[default]]
    [[[child1]]]
      parent = window0
	  profile = default
      type = Terminal
    [[[window0]]]
      parent = ""
      type = Window
[plugins]
[profiles]
  [[default]]
    background_color = "#380c2a"
    background_darkness = 0.85
    background_image = None
    background_type = transparent
	show_titlebar = True
    copy_on_selection = True
    cursor_color = "#e0f0f1"
    font = Ubuntu Mono 12
    foreground_color = "#e0f0f1"
    use_system_font = False
```

此时终端里的部分内容依旧没有不同颜色标识，需要修改`~/.bashrc`里的内容，具体如下：

```bash
# changed by RJX on 2022/11/23 (Terminator)
if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '  # 这一行注掉，添加下一行
    PS1='${debian_chroot:+($debian_chroot)}\w\$ '
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '  # 这一行注掉，添加下一行
    PS1='${debian_chroot:+($debian_chroot)}\w\$ '
fi
unset color_prompt force_color_prompt

# changed by RJX on 2022/11/23 (Terminator)
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    #PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"  # 这一行注掉，添加下一行
    PS1="\[\e[32;36m\]\u\[\e[37;33m\]@\h \[\e[36;32m\]\w\[\e[0m\]\\$ "
    ;;
*)
    ;;
esac
```

---

常用`ctrl + shift + e`  # 垂直分割窗口

常用`ctrl + shift + 方向键`  # 移动窗口分割线

常用`ctrl + shift + o`  # 水平分割窗口

`ctrl + shift + x`  # 将当前子终端全屏

`ctrl + shift + z`  # 退回到多窗口子终端模式

---

`ctrl + tab 或者 ctrl + shift + n`  # 切换下一个窗口

`ctrl + shift + tab 或者 ctrl + shift + p`  # 切换上一个窗口

常用`alt + 方向键`  # 切换到对应位置的窗口

`ctrl + shift + q`  # 关闭所有窗口

`F11`  # 全屏/退出全屏

---

`ctrl + -`  # 缩小字体

`ctrl + shift + =`  # 放大字体，也就是`ctrl + +`

`ctrl + 0`  # 恢复字体大小

`ctrl + shift + f`  # 在终端中查找

`ctrl + shift + s`  # 显示/隐藏滚动条



## 在文档管理器中的任意位置打开Terminator

主要方法是通过安装**nautilus-actions**这个软件来定制鼠标右键功能

> 仅适用于ubuntu16.04对于Ubuntu18.04/20.04系统，已经取消了`nautilus-actions`这个软件，取而代之的是`filemanager-actions`这个软件

安装**nautilus-actions**

```bash
sudo apt-get install nautilus-actions
# 如果是ubuntu20系统则
sudo apt-get install nautilus-actions filemanager-actions
```

如果安装过程中出现`无法定位该软件`的错误

可能是ubuntu16.04默认没有添加该软件源，需要在`设置`的`软件和更新`中勾选`universe`源

安装完打开`nautilus-actions`软件

```bash
nautilus-actions-config-tool
# 如果是ubuntu20系统则
fma-config-tool
```

1. 新建动作

   ![img](https://img-blog.csdnimg.cn/2019042016271279.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5naG0xOTk1,size_16,color_FFFFFF,t_70)

   `Context label`可以写：Open in terminator by RJX

   `工具提示`可以写：open in terminator by RJX

2. `命令`中

   ![img](https://img-blog.csdnimg.cn/2019042016285735.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5naG0xOTk1,size_16,color_FFFFFF,t_70)

   `路径`可以写：`/usr/bin/terminator`

   `参数`可以写：`--working-directory=%d/%b`

   `工作目录`可以写：`%d`

3. 设置nautilus的首选项

   ![img](https://img-blog.csdnimg.cn/20190420163110374.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3poYW5naG0xOTk1,size_16,color_FFFFFF,t_70)

   取消勾选`Create a root ‘Nautilus-Actions’ menu`，避免右键菜单中需要先点击`Nautilux菜单`，才能再打开Terminator，多一步很麻烦

4. 保存

   ctrl + s

5. 重启电脑，或者，终端键入：

   ```bash
   nautilux -q
   ```


## 在文档管理器中使用快捷键打开Terminator

```bash
sudo apt-get install xdotool xclip
```

新建脚本：

```bash
sudo vim /usr/bin/open_Terminator_by_RJX.sh
```

```bash
#!/bin/bash

#record the current ClipBoard
#clipboard_current=$(xclip -o)
pid_list=`xdotool search --class "nautilus"`

#loop for the right window
for i in $pid_list
do
name=`xdotool getwindowname "$i"`
name_lower=$(echo $name | tr [a-z] [A-Z])
if echo "$name_lower" | grep -qwi ".*desktop*";then
echo "desktop window"
elif echo "$name_lower" | grep -qwi ".*nautilus*";then
echo "nautilus window"
else
id=$i
fi
done

#get the current working directory
wait=`xdotool windowfocus $id`
sleep 0.2
wait=`xdotool key Ctrl+l`
sleep 0.2
wait=`xdotool key Ctrl+c`
sleep 0.1
path=$(xclip -o)
wait=`xdotool key Escape`
sleep 0.1
#gnome-terminal --working-directory ${path}
terminator --working-directory ${path}
```

将这个脚本添加执行权限

```bash
sudo chmod +x /usr/bin/open_Terminator_by_RJX.sh
```

然后在`设置`的`键盘`里的`快捷键`里的`自定义快捷键`中新建一个`Open_Terminator_by_RJX`

名称就填`Open_Terminator_by_RJX`

命令填写`open_Terminator_by_RJX.sh`

快捷键设置为`ctrl + alt + g`

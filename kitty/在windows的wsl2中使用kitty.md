[参考网页](https://github.com/kovidgoyal/kitty/discussions/7054)

在wsl中下载kitty，链接到/usr/local/bin中，然后执行。

如果报以下错：

```bash
[080 07:47:20.913752] [glfw error 65544]: Wayland: Failed to connect to display
GLFW initialization failed
```

就在bash shell（不要用nushell）中运行：

```bash
ln -sf /mnt/wslg/runtime-dir/wayland-* $XDG_RUNTIME_DIR/
```

可以在桌名上新建快捷方式，然后指向：

```bash
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -WorkingDirectory ~ -WindowStyle Hidden -Command C:\Windows\System32\wsl.exe --cd ~ -e bash -c kitty
```

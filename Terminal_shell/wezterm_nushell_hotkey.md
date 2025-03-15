# Windows wezterm中定义:
- `super`: `alt`
- `super_rev`: `ctrl alt`
- `leader`: `super_rev space`

# Wezterm中快捷键：
特殊模式：
- `F1`: copy模式
- `leader f`: resize-font模式，其中jk可以调整font大小，r重置，q离开
- `leader p`: resize-panel模式，其中jk可以调整panel大小，r重置，q离开

特殊快捷键：
- `F2`: shell命令面板
- `F3`: shell启动面板
- `F4`: 已启动tab面板
- `F5`: workspace启动面板
- `F11`: 全屏切换选项
- `F12`: wezterm debug界面

常用快捷键：
- `super f`: search模式，可用于查找字符
- `super_rev u`: 显示可用url并随机赋字符，按字符可跳转网页
- `super LeftArrow`: 光标定位行首
- `super RightArrow`: 光标定位行尾
- `super Backspace`: 光标位于行尾时，删除整行
-- 
- `ctrl shift c`: 复制到剪贴板
- `ctrl shift v`: 复制到剪贴板
--
- `super t`: 新建tab，默认shell
- `super_rev t`: 新建tab，wsl:ubuntu
- `super ,`: 跳转到下一个tab
- `super .`: 跳转到上一个tab
- `super_rev ,`: 将当前tab后移一位
- `super_rev .`: 将当前tab前移一位
- `super 0`: 重命名当前tab
- `super_rev 0`: 重置当前tab名字
- `super 9`: 切换显示tab_title
--
- `super n`: 新建window，默认shell
- `super w`: 关闭当前window
- `super -`: 缩小当前window
- `super =`: 扩大当前window
--
- `super b`: 使用/关闭壁纸面板
- `super [`: 向前切换终端背景
- `super ]`: 向后切换终端背景
- `super /`: 随机切换终端背景
- `super_rev /`: 背景选择面板
--
- `super \`: vertical，垂直向下去新建一个panel
- `super_rev \`: horizontal，水平向右去新建panel
- `super w`: 关闭当前panel，类似部分shell的`ctrl d`，并且在pwsh中也生效
- `super_rev p`: 提示panel编号，按编号跳转
- `super_rev h`: 向左切换panel
- `super_rev j`: 向下切换panel
- `super_rev k`: 向上切换panel
- `super_rev l`: 向右切换panel
--
- `super d`: 向下翻找终端显示内容
- `super u`: 向上翻找终端显示内容
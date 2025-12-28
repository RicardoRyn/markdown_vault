# tmux

默认`prefix`键：`ctrl+b`

## 在tmux外运行

`tmux ls`: 显示所有session
`tmux a -t <session-id>`: 进入指定session, a表示attach
`tmux a`: 在只有一个session的时候进入该session

`tmux kill-session`: 关闭上一次打开的session
`tmux kill-session -t <session-id>`: 关闭指定session
`tmux kill-server`: 关闭所有session

`tmux new`: 创建新的session
`tmux new -s <name>`: 创建新的session并指定名字

## tmux中运行
`prefix + ?`: 查，都可以查

`prefix + :`: 输入tmux命令（省去tmux不写）
`prefix + <S-I>`: 安装插件

`prefix + c`: 新建窗口
`prefix + %`: 新建垂直分屏
`prefix + "`: 新建水平分屏
`prefix + x`: 关闭pane/windows
`prefix + !`: 将pane转换成window

`prefix + w`: 选择窗口
`prefix + s`: 选择session
`prefix + <num>`: 选择指定窗口
`prefix + q`: 显示pane信息
`prefix + z`: 放大pane
`prefix + [`: vim模式选择信息

# FSL大坑

FSL 为了保证自己的脚本能跑，会强制把它的 bin 目录加到 PATH 的最前面，
导致它自带的各种阉割版的库屏蔽了 Ubuntu 中原来的库。
有时写在 `.bashrc` 中，有时写在 `.profile` 中。

这个时候最好的办法就是先注释掉FSL相关的内容，然后执行操作（比如下载，编译之类的），完成后再恢复FSL的环境变量。

比如我需要`cargo install alacritty`。
编译过程中需要用到`pkg-config`这个库，
但是该库被FSL污染，导致无法下载编译alacritty，所以需要去`.profile`中将FSL的环境变量注释掉。
等到alacritty安装完成后，再将FSL的环境变量恢复。

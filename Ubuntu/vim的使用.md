# 一. 常用操作

`vim rjx.txt +10`  # 用vim进入rjx.txt文件，并将光标定位到第10行

如果使用vim编辑文件，但是没有正常退出，会保存一个.swp文件（隐藏交换文件`.rjx.txt.swp`）；一般情况下vim正常关闭，这个.swp文件都会正常删除。

3个模式：

1. **命令模式/一般模式**

   刚进入vim默认是命令模式，只能接收命令，不能输入内容

   只有 命令模式 和 底线命令模式 下才能退出vim

   `shift + z + z`  # 保存退出

   `shift + z + q`  # 不保存退出

   `dd`  # 用来删除一行数据

   `daw`  # 删除这个单词

   `d4j`  # 删除向下的4行

   `10dd`  # 用来删除10行数据，从光标所在行开始计算

   `u`  # 撤销

   `ctrl + r`  **# 反撤销**

   `yy`  # 复制光标所在行

   `yaw`  # 复制光标所在的整个单词

   `y4j`  # 复制包括光标所在行的下4行内容（等价于`4yy`）

   `10yy`  # 复制10行，从光标所在行开始计算

   `1215,1998y`  # 复制1215行到1998行 

   `p`  # 粘贴，无论光标在头尾还是中间，都会直接复制一行，不会从中间插入式

   的复制

   `G`  # 定位到最后一行

   `gg`  # 定位到第一行

   `gg=G`  **# 格式化代码（对齐）**

   `1998gg` # 定位到第1998行（等价于在底线命令模式中输入`:1998`）

   `$`  # 定位到光标所在行的末尾（类似正则表达式）

   `^`  # 定位到光标所在行的开头（类似正则表达式）

   `0`  # 定位到光标所在行的开头

   `k j h l`  # 上下左右移动光标

   `ctrl + f`  # 下翻一页

   `ctrl + d`  #  下翻半页

   `ctrl + y`  # 下滚一行

   `ctrl + b`  # 上翻一页

   `ctrl + u`  # 上翻半页

   `ctrl + e`  # 上滚一行

   `ctrl + l `  # 重绘屏幕

   `x`  # 删除光标右边的文字

   `5 x`  # 删除光标右边5个数据

   `X`  # 删除光标左边的文字

   `5 `X  # 删除光标左边的5个文字

   `f后跟一个字母`  # 跳转到最近的对应字母处

   `c`  # 改变当前字母并进入输入模式

   `cc`  # 改变当前一整行并进入输入模式

   `caw`  # 改变当前整个单词并进入输入模式

   `yf跟一个字母`  # 复制光标到最近的对应字母的全部内容

   `v`  # 字符选择

   `ctrl + v`  # 块选择

   `.`  **# 上一次修改操作（常用）**

2. **插入模式**
   `i`  # 进入插入模式

   `esc`  # 返回到命令模式

   `I`  # 在光标所在行的第一个非空字符前进入插入模式

   `a`  # 在光标的下一个字符插入

   `A`  # 在行尾插入

   `s`  # 删除光标所在字符（即光标右边的字符），并进入输入模式

   `S`  # 删除光标所在行，并进入输入模式

   `o`  # 在光标所在行新建下一行并插入

   `O`  # 在光标所在行新建上一行并插入

3. **底线命令模式**

   **粘贴到底线命令行**： 在命令模式下，输入 `:` 进入底线命令行，然后按 `Ctrl+R`，接着输入 `"` 以粘贴默认寄存器的内容。

   `shift + ;`  # 进入底线命令模式，即`:`，以下命令前本该有`:`以示为底线命令模式，在此省略

   `w`  # 保存

   `q`  # 退出，如果改完内容必须保存才能退出

   `wq`  # 保存退出

   `q!`  # 不保存强制退出

   `wq!`  # 保存并强制退出，可以用这个来修改sudoers后强制保存退出

   `e!`  # 放弃之前的修改，但是不退出

   `w rjx.txt`  # 另存为rjx.txt

   `set nu`  # 打开行号

   `set nonu`  # 隐藏行号

   `1998`  # 光标定位到1998行，如果没有1998行，就会跳到最后一行

   `1215,1998d`  # 删除1215行到1998行的内容

   `/student`  # 查找“student”，按n查找下一个，按N查找上一个

   `/student\C`  # 由于.vimrc里的设置，在搜索关键词中有大写字母的时候，默认会区分大小写，而没有大写字母的时候，不会区分大小写。如果全是小写字母，并且还想区分大小写，就可以在末尾加\C，表示大小写敏感，加\c表示大小写不敏感

   `s/原内容/新内容`  # 当前行替换

   `%s/原内容/新内容`  # 全文替换，默认只会替换每一行的第一个对应内容替换

   `%s/原内容/新内容/g`  # 全文替换，默认会替换所有对应内容

   `1215,1998s/原内容/新内容`  # 默认只会替换从1215行到1998行的第一个对应

   内容（包括1215和1998行）

   `1215,1998s/原内容/新内容/g`  # 默认会替换1215行到1998行所有的对应内容（包括1215和1998行）

   **vim的多文件**

   `vim rm_rjx1.txt rm_rjx2.txt`  # 同时打开2个文件

   `files`  # 显示所有文件名字

   `n`  # 跳转到下一个文件

   `N`  # 跳转到上一个文件

   **vim的多窗口**

   `sp` # 分割当前文件

   `sp rm_rjx2.txt`  # 下半窗口打开名为“rm_rjx2.txt”的文件

   `ctrl + w，松开，j`  # 光标定位到下一个文件内

   `ctrl + w，松开，k`  # 光标定位到上一个文件内

4. `.vimrc`配置文件中的一些设置
    `imap j; <Esc>`  # 表示用“j;”键代替“Esc”键，可快速从插入模式返回到命令模式
    `nmpa <space>` :  # 表示用“空格”键代替“:”键，可以快速从命令模式进入底线命令模式

vim默认主题颜色

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190812111547200.png)



# 二. 配置文件.vimrc

```bash
syntax on  # 语法高亮
colorscheme ron
set nocompatible  # 不要兼容模式，即不需要兼容成vi
set cursorline  # 显示行线
set ruler  # 
set shiftwidth=4  # 用于程序中自动缩进所使用的空白长度
set softtabstop=4  # 
set tabstop=4  # 
set nobackup  # 取消vim的自动备份功能
set autochdir  # 自动换到当前文档目录
set backupcopy=yes
set ignorecase smartcase  # 如果搜索时无大写字母，则大小写不敏感；如果含大写字母，则大小写敏感
set nowrapscanm  # 只搜索一次
set incsearch  # 输入关键字的时候高亮显示
set hlsearch  # 搜索关键字的时候高亮显示
set noerrorbells  # 关闭错误信息响铃
set novisualbell  # 关闭屏幕闪烁？
set t_vb=  # 既不想要鸣叫也不想要屏幕闪烁，那么可以使用以下设置
set showmatch  # 在vi中输入)或者}时，光标会暂时的回到相匹配的(或者{  
set matchtime=2  # 短暂跳转到匹配括号的时间
set magic  # vim默认设置为magic模式，表示在搜索文档时是否启用正则表达式。总共有4个等级：very magic、magic、nomagic、very nomagic。分别用\v,\m,\M,\V来表示。例如在底线输入“/Ricardo”，默认以magic模式查找，输入“/Ricardo \M”，则用nomagic模式查找。
set hidden  # 允许在有未保存的修改时切换缓冲区，此时的修改由 vim 负责保存
set guioptions-=T  # 隐藏工具栏
set guioptions-=m  # 隐藏菜单栏
set smartindent  # 启用smartindent缩进结构
set backspace=indent,eol,start  # 和删除字符以及缩进有关
set cmdheight=1  # 设定命令行的行数为 1
set laststatus=2  # 显示状态栏 (默认值为 1, 无法显示状态栏)
set showcmd  # 输入的命令显示出来

imap j; <Esc>  # 表示用“j;”键代替“Esc”键，可快速从插入模式返回到命令模式
nmap <space> :  # 表示用“空格”键代替“:”键，可以快速从命令模式进入底线命令模式
map <silent> <C-e> :NERDTreeToggle<CR>
 
call plug#begin()
Plug 'scrooloose/nerdtree'
call plug#end()
```



# 三. vim中检索替换相关的正则表达式

| 无需转移符号`\`使用的元字符     | 说明                                                         |
| ------------------------------- | ------------------------------------------------------------ |
| `.`                             | 匹配任意一个字符                                             |
| `*`                             | 匹配0~任意个                                                 |
| `[abc]`                         | 匹配方括号中的任意一个字符。可以使用-表示字符范围，如`[a-z0-9]`匹配小写字母和阿拉伯数字。 |
| `[^abc]`                        | 在方括号内开头使用**^**符号，表示匹配除方括号中字符之外的任意字符。 |
| `^`                             | 匹配行首                                                     |
| `$`                             | 匹配行尾                                                     |
| **需要转移符号`\`使用的元字符** | **说明**                                                     |
| `\+`                            | 匹配1~任意个                                                 |
| `\?`                            | 匹配0~1个                                                    |
| `\{n}`                          | 匹配n个                                                      |
| `\{n,}`                         | 匹配n~任意个                                                 |
| `\{,m}`                         | 匹配0~m个                                                    |
| `\{n,m}`                        | 匹配n~m个                                                    |
| `\<`                            | 匹配单词词首                                                 |
| `\>`                            | 匹配单词词尾                                                 |
| `\(`和`\)`                      | 分组，通过`\0`，`\1`，`\2`来获取对应部分                     |
| `\d`                            | 匹配阿拉伯数字，等同于`[0-9]`                                |
| `\D`                            | 匹配阿拉伯数字之外的任意字符，等同于`[^0-9]`                 |
| `\s`                            | 匹配空白字符，等同于`[ \t]`                                  |
| `\S`                            | 匹配非空白字符，等同于`[^ \t]`                               |
| `\w`                            | 匹配单词字母，等同于`[0-9A-Za-z_]`                           |
| `\W`                            | 匹配单词字母之外的任意字符，等同于`[^0-9A-Za-z_]`            |
| `\x`                            | 匹配十六进制数字，等同于`[0-9A-Fa-f]`                        |
| `\X`                            | 匹配十六进制数字之外的任意字符，等同于`[^0-9A-Fa-f]`         |
| `\n`                            | 换行                                                         |
| `\t`                            | 制表符                                                       |



# 四. vim常用插件

## 0. 插件管理软件

下载vundle插件，有了它就可以更为方便地管理所要安装的插件，包括安装，更新，清理等功能

```bash
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

配置Vundle

为了使用Vundle你还需要在vim的配置文件中添加如下配置，并且将你想通过Vundle管理的插件都添加在`call vundle#begin()`和`call vundle#end()`块中：

```bash
" 在.vimrc中，"才是注释符
"====== vundle configuration ======
set nocompatible                " be iMproved
filetype off                    " required!
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
 
" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'
 
" My Plugin
Plugin 'preservim/nerdtree'
Plugin 'luochen1990/rainbow'
 
call vundle#end()                                                                                                 
filetype plugin indent on   " requeired
"====== vundle configuration ======

```

## 1. vim-conmmentary 一个用于批量注释的插件

### (1). 安装

确保`.vimrc`中包含：

```bash
filetype plugin indent on
```

然后终端键入：

```bash
mkdir -p ~/.vim/pack/tpope/start
cd ~/.vim/pack/tpope/start
git clone https://tpope.io/vim/commentary.git
vim -u NONE -c "helptags commentary/doc" -c q
```

### (2). 使用

```
gcc  # 注释当前行
gcap  # 注释本段
:1215,1998Commentary  # 注释1215到1998行
gc  # 先通过可视模式选中行，然后注释
```

## 2. NERDTree 用于列出目录树

### (1). 安装

在`.vimrc`中键入：

```bash
call plug#begin()                             
Plug 'preservim/nerdtree'
call plug#end()
```

然后进入一个vim文本，在底线命令行中输入：

```bash
PlugInstall
```

然后再进入`.vimrc`，键入：

```bash
map<F2> :NERDTreeToggle<CR>  # 目的是使用F2键快速打开目录树
```

### (2). 使用

```bash
在vim文本中
F2  # 打开目录树
ctrl+ww  # 在目录树窗口和编辑器窗口之间切换

当位于目录树窗口时
o  # 打开该文件，并将光标定位到该文本中
go  # 打开该文件，但是光标依旧留在NERDTree中
s  # 垂直打开该文件，并将光标定位到该文本中
gs  # 垂直打开该文件，但是光标依旧留在NERDTree中
i  # 水平打开该文件，并将光标定位到该文本中
gi  # 水平打开该文件，但是光标依旧留在NERDTree中

C  # 将根目录设置为光标所在文件位置
u  # 设置父目录为根路径
U  # 设置副目录为根路径，并保持原来目录打开的状态

J  # 跳转到该文件夹下最后面一个文件
K  # 跳转到该文件夹下最上面一个文件

p  # NERDTree中打开多个文件树的时候，跳转到光标所在上一级路径
P  # NERDTree中打开多个文件树的时候，跳转到根路径

r  # 刷新光标所在目录
R  # 刷新根目录

I  # 显示/关闭隐藏文件
A  # 全屏显示/关闭 NERDTree
```






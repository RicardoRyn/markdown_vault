# 5大区

![[ccef1b1009501335af7db8e0656ec44e.jpg]]
工作区 (workspace) 中的文件一般是未追踪状态，即`Untracked/Unstage`

暂存区 (index) 中的文件一般是，已经追踪状态`Stage`

本地仓库 (local repository)

远端仓库 (remote repository)

贮藏区 (stash)，可将工作区域中的变更，贮藏起来，必要时候再取出来用。

# 常规设置

```bash
git config --global user.name "Ricardo_MI" # 如果用户名中没有空格，可以不使用双引号
git config --global user.email "ricardoryn1317@gmail.com"

git config --global init.defaultBranch main # 设置默认分支名字为main
git config --global credential.helper store # 为了防止git push的时候老师需要用户名和密码，可以加上这个设置

# 可选
# git config --global http.sslverify false  # 防止git clone出现server certificate verification failed. CAfile: none CRLfile: none的问题

# 查看config文件
cat ~/.gitconfig
```

# SSH免密登录

```bash
cd  # 等同于cd ~
# 由于之前配置vscode的远程连接，所以已经有了名为.ssh的文件夹
ssh-keygen -t rsa -C ricardoryn1317@gmail.com
# 敲完回车，终端会显示：
Generating public/private rsa key pair.
Enter file in which to save the key (/c/Users/Layne/.ssh/id_rsa):
# 自己指定文件保存地点：
/c/Users/RicardoRyn/.ssh/git_ssh_key
# 后面回车，终端问你需不需要输入密码，不需要就继续回车，最后终端显示：
Your identification has been saved in /c/Users/RicardoRyn/.ssh/git_ssh_key
Your public key has been saved in /c/Users/RicardoRyn/.ssh/git_ssh_key.pub.
# 完成
```

复制`git_ssh_key.pup`里的内容，登录GitHub，在`Setting`里`SSH and GPG keys`中新增SSH key, title命名为`ricardo_github`，然后把复制内容粘贴保存。

## 更多关于ssh (可以免密登录服务器)

```bash
ssh-keygen -t rsa -b 4096 -C ricardoryn1317@gmail.com # -t表示对应的加密算法，-b表示生成密钥的长度为4096，-C则是为添加的公钥增加注释
ssh-copy-id aaa@xxx.xxx.xxx.xxx                       # 将本地的ssh公钥复制到远程机器的`~/.ssh/authorized_keys`文件中，这样就可以通过ssh密钥认证的方式，免去输入密码
```

# 常用命令

```bash
git status

git add .

git commit  # 进入vim，写较长的修改日志
git commit -m "<message>"
git commit -a -m "<message>"  # -a即--amend，更改上一次提交的修改日志

git checkout <branch name>  # 切换到新的 A branch，据说新版本的Git中是switch
git checkout -b <branch name>  # 创建并切换到新的 A branch

git branch  # 列出所有的branch
git branch <branch name>  # 创建新的 A branch，但是不会切换成新的branch
git branch -d <branch name>  # 删除A branch，如果A branch未合并，可以使用-D强行删除
git branch -M <branch name>  # -M表示move/rename到一个已经存在的branch

git switch <branch name>  # 切换到A分支
git switch -c <branch name>  # 新版本中，创建并切换到新的 A branch

```

# 同步

## 本地推送到远端

```bash
git remote add origin https://github.com/RicardoRyn/Plot_fig.git
git remote -vk

git push  # 输入用户名，token
git push -u origin main
git push --tags  # 将所有tag push上去

## 远端拉取到本地
# 假设远程仓库已经被修改，与本地不同
git fetch  # 本地文件暂时不会发生变化，只是拉到了本地仓库（不是工作区）
git diff origin/main

# 确认没有问题，再将远程仓库pull到工作区
git pull
```

# 工作流

参考视频：[十分钟学会正确的github工作流，和开源作者们使用同一套流程-哔哩哔哩](https://b22.tv/vR4P09H)

`main`, `relsease`, `dev`, `feature`, `hotfix` 5大分支

![[956fcdc1c739c1c33f3d964795d2063d.jpg]]

参考视频：[十分钟学会正确的github工作流，和开源作者们使用同一套流程-哔哩哔哩](https://www.bilibili.com/video/BV19e4y1q7JJ/))

# 重置本地库

使用 `git reset` 和 `git clean` 命令将本地库重置为与远程库完全一致。
请注意，这些操作会丢失你本地未提交的更改，所以请确保你已经备份或提交了所有重要的更改。

```bash
# 重置当前分支到远程分支
git checkout main            # 切换到主分支
git reset --hard origin/main # 重置本地分支到远程分支
git clean -fd                # 删除所有未跟踪的文件和目录
```

# 使用bare仓库管理各个文件夹中的配置文件 (已弃用)

```bash
mkdir ~/.rjx_dotfiles
git init --bare ~/.rjx_dotfiles

# 自定义命令“rjxgit”
# 注意当前系统以及shell，比如windows的nushell中写成“$env.USERPROFILE”
echo "alias rjxgit='git --git-dir=$HOME/.rjx_dotfiles/ --work-tree=$HOME'" >>$HOME/.bashrc
```

在`~`中新建`.gitignore`文件，然后添加：

```txt
#-------[ ignore all ] --------
*
#-------[ consider list ]-------
!.gitignore
!.bashrc
!.zshrc
!.vimrc
!.config\starship.toml
!AppData\Roaming\Code\User\settings.json
!AppData\Roaming\Code\User\keybindings.json
```

添加远程仓库即可push：

```bash
rjxgit remote add origin https://github.com/RicardoRyn/rjx_dotfiles.git
rjxgit push -u origin main
```

想要增加/移除文件，可以先修改`.gitignore`文件，然后键入：

```bash
rjxgit add -f <file>  # 强制追踪
rjxgit rm --cached <file>  # 强制删除文件
rjxgit rm -r --cached <file>  # 强制文件夹
```

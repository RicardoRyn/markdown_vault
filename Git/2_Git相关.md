工作区中的文件一般是未追踪状态，即`Untracked/Unstage`

暂存区中的文件一般是，已经追踪状态`Stage`

使用`pull`命令会将远程仓库中的文件直接更新到工作区，覆盖正在更改的文件，需要注意。
- 所以可以先使用`fetch`将内容更新到本地仓库，然后再用`diff`对比文件差异
- 如果没有问题，可以再使用`???`合并过来

# 设置用户
```bash
git config --global user.name "Ricardo_MI"  # 如果用户名中没有空格，可以不使用双引号
git config --global user.email ricardoryn1317@gmail.com
git config --global init.defaultBranch main
git config --global credential.helper store  # 为了防止git push的时候老师需要用户名和密码，可以加上这个设置
git config --global http.sslverify false  # 防止git clone出现server certificate verification failed. CAfile: none CRLfile: none的问题
```

# git常用命令
```bash
git status  # 查看当前位置信息，包括分支。根据文件是否 Untracked，可以判断文件在“工作区”还是“暂存区”
```

# 初始化本地仓库
```bash
git init
```

是应该先创建本地仓库，还是应该先创建远程仓库？

如果是先在github里远程仓库，再clone到本地，大部分事情都比较简单。

但是如果是先在本地创建仓库，再上传到远程仓库，则会出现很多麻烦。

```bash
git pull  # 因为本地仓库有自己的各种历史版本commit，远程仓库也有自己各种历史版本的commit。在这种情况下想将远程仓库直接拉取到本地是会报错的。
git pull -rebase origin main  # 这样会将远程仓库的commit默认为老的commit，本地仓库的commit默认为新的commit
git log
```
> Tip：本地文件夹名字和远程仓库文件夹名字不一致也可以push
> `git checkout <hash code>`可以返回到对应的commit
> 输入`git checkout main`可以再返回

创建文件
```bash
echo "版本1" > README.md
git add README.md
git commit -m "第 1 次 commit"
```

如果暂存区中已经存在tracked文件，尚未commit，而工作区中又更改了这个文件。此时使用`git status`，则会显示2个该文件即被tracked，又被untracked。此时应该：
```
将工作区中untracked的文件再次add，加入tracked的暂存区中。
```

```bash
git log  # 显示每一次commit的记录
```

> Tips：如果有一些文件不想提交，也不想泄漏到远程仓库，可以让git忽略调这些文件
> 只需要创建.gitignore文件，然后在该文件中写入忽略的文件名

# 分支
```bash
git branch new_branch  # 创建新分支，但是不会进入新分支
git branch  # 显示所有分支
git checkout new_branch  # 切换到新分支上
rm -rf *
git commit -a -m "删库跑路"  # -a 选项可以直接跳过git add步骤

git checkout main  # 除了.gitignore中记录的文件，其他文件依然存在
git branch -d new_branch  # 删除分支，一般会报错，因为该分支与主分支不同
git branch -D new_branch  # 只有非常确定需要删除该分支的时候，才会用到-D选项，强制删除
```
> Tips：为了创建main分支，可以使用`git branch -m main`，如果创建不了，可以使用`git branch -M main`来强制创建。为了防止本地仓库默认创建`master`。可以将`git config --global init.defaultBranch main`写入配置

```bash
git checkout -b temp  # 创建并切换到新的分支上
echo "版本2" > README.md  # 在temp分支上进行修改，此时并没有影响到主分支

git checkout main
git merge temp  # 把指定分支合并到当前分支上
```
> Tips：经常遇到的情况是，在两个分支中的某个文件存在冲突，这时候就需要手动修改文件，直到不冲突。

# 本地同步到远程仓库
```bash
# 如果是先git clone的别的仓库，自动同步远程仓库
# 否则
git remote add origin https://github.com/RicardoRyn/Plot_figu；jkkkre.git
git remote -v 
git push  # 输入用户名，token
# 或者
git push -u origin main
# 如果经常需要键入用户名和密码，可以添加设置
git config --global credential.helper store
```

# 远程仓库同步到本地
```bash
# 假设远程仓库已经被修改，与本地不同
git fetch  # 本地文件暂时不会发生变化，只是拉到了本地仓库（不是工作区）
git diff origin/main
# 确认没有问题，再将远程仓库pull到工作区
git pull
git log
```

# 使用bare仓库管理各个文件夹中的配置文件

```bash
mkdir ~/.rjx_dotfiles
git init --bare ~/.rjx_dotfiles

# 自定义命令“rjxgit”
# 注意当前系统以及shell，比如windows的nushell中写成“$env.USERPROFILE”
echo "alias rjxgit='git --git-dir=$HOME/.rjx_dotfiles/ --work-tree=$HOME'" >> $HOME/.bashrc
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


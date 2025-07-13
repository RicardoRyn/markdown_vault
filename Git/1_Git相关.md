![img](https://pic2.zhimg.com/80/v2-4f61dac0b425ebe34efc88d11a68f27b_720w.webp)

# 一、上传代码到Github

# 1. 准备工作

## 1.1 安装Git

官网地址： [Git](https://git-scm.com/)

除了安装地址以外全默认

## 1.2 在Git中设置用户名（签名信息）

右击鼠标打开Git bash，键入：

```bash
git config --global user.name Ricardo
git config --global user.email ricardoryn1317@gmail.com

# 查看config文件
cat ~/.gitconfig
```

Git使用用户名将commit与身份关联，Git用户名与GitHub用户名不同。作用是区分不同操作者的身份，用户的签名信息在每一个版本中的commit中都能够看到，一次确定是谁commit的。

可以为每个repository设置一个Git用户名与邮箱

```bash
git config user.name "Ricardo"
```

### 1.3 SSH免密登录

首先需要创建SSH密钥

进入到用户家目录进行操作：

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

### 1.3.1 关于ssh

```bash
ssh-keygen -t rsa -b 4096 -C ricardoryn1317@gmail.com 
ssh-copy-id aaa@xxx.xxx.xxx.xxx
```

上面的代码中，-t表示对应的加密算法，-b表示生成密钥的长度为4096，-C则是为添加的公钥增加注释

然后通过`ssh-copy-id`命令，能够将本地的ssh公钥复制到远程机器的`~/.ssh/authorized_keys`文件中，这样就可以通过ssh密钥认证的方式，免去输入密码

### 1.4 GitHub创建一个新的库

从网页上创建一个新的repository，仅输入`Repository name`其他默认，不勾选`Add a README.md`，后面自己手动添加


# 2. 上传项目

## 2.1 初始化本地库

进入到需要上传到文件的文件夹中

```bash
cd /e/jupyter_notebook/jupyter_notebook_code/git_repositories/Plot_figure
# 初始化本地库
git init
# 会在当前文件夹下创建一个隐藏文件 .git
ll -a  # 出现 .git 文件夹则说明成功
```

### 2.2 添加远程仓库到本地

之前 [1.4 GitHub创建一个新的库](# 14 GitHub创建一个新的库 ) 中有创建一个新的repository（远程仓库），复制其对应的url

```bash
# 添加这个远程仓库到本地，并取一个别名为“origin”
git remote add origin https://github.com/RicardoRyn/Plot_figure.git
# 查看是否添加成功，键入：
git remote -v
# 终端打印：
origin  https://github.com/RicardoRyn/Plot_figure.git (fetch)
origin  https://github.com/RicardoRyn/Plot_figure.git (push)
```

至此`origin`表示远程仓库

### 2.3 查看本地库状态

注意，本地库是本地库，远程仓库是远程仓库，两者不是同一个库，只是互相可以通讯

假设本地库中只有2个文件`plot_figure.py`和`README.md`

一般流程是，将想要上传的文件add到暂存区，最后commit，上传到指定的远程库

首先查看本地库状态：

```bash
git status
# 终端显示：
On branch master 

No commits yet 
 
nothing to commit (create/copy files and use "git add" to track)
```

如果想要修改`branch`的名称，可以键入：

```bash
git branch  # 列出所有的branch
git branch A  # 创建新的 A branch，但是不会切换成新的branch
git checkout A  # 切换到新的 A branch，据说新版本的Git中是switch
git checkout -b A  # 创建并切换到新的 A branch
git switch -c A  # 新版本中，创建并切换到新的 A branch
git merge B  # 将 B branch中的修改合并到当前branch
git branch -d A  # 删除A branch，如果A branch未合并，可以使用-D强行删除
```

以前的主版本branch名为`master`，现在改成了`main`，网页中新建的repository也是使用的`main`，建议统一使用`main`，键入：

```bash
git branch -M main  # -M表示move/rename到一个已经存在的branch
```

### 2.4 将修改文件add到暂存区，并最终commit

修改一下`plot_figure.py`或`README.md`文件，然后将它们add到暂存区

```bash
git add .  # 添加该文件夹下的 plot_figure.py 和 README.md 文件到暂存区
# 查看本地库状态
git add *


git status
# 终端显示：
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

`git add .`（常用）

- **用途**：添加当前**目录及其所有子目录中的所有文件和目录**到暂存区。
- **特点**：**包括隐藏文件和文件夹**（以 `.` 开头的文件和文件夹）。
- **适用场景**：适用于你想要添加当前目录中的所有更改，包括新建、修改和删除的文件。

`git add *`

- **用途**：添加当前目录中的所有文件和目录到暂存区，但**不包括隐藏文件和文件夹**。
- **特点**：不会包括以 `.` 开头的文件和文件夹，也不会递归添加子目录中的文件。
- **适用场景**：适用于你只想添加当前目录中的非隐藏文件和目录，不需要递归添加子目录中的文件。

---

然后commit

```bash
git commit  # 进入vim，写较长的修改日志
git commit -m "Add something for README.md" *  # 必须添加修改日志，告诉别人你commit
git commit -a -m "Add something for README.md"
git commit --amend -m "Corrected commit message"  # 更改上一次提交的修改日志
```

`-a` ：自动添加所有已跟踪的文件（已被 `git add` 过的文件）的更改，然后提交

`--amend` ：修改上一次提交，允许你更改提交信息或添加遗漏的更改。

---

再次查看本地库的状态：

```bash
git status
# 终端打印：
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

nothing to commit, working tree clean
# commit成功
```

### 2.5 上传至远程仓库

确认无误后上传至远程仓库：

```bash
git push -u origin main  # 上传至 origin 远程库的 main branch
```

在网页端查看是否更新，更新则表示完成。

如果老是需要密码，键入：

```bash
git config --global credential.helper store
```

## 3. 重置本地库

使用 `git reset` 和 `git clean` 命令将本地库重置为与远程库完全一致。请注意，这些操作会丢失你本地未提交的更改，所以请确保你已经备份或提交了所有重要的更改。

#### 重置当前分支到远程分支

假设你正在处理 `main` 分支（或 `master` 分支），你可以使用以下命令：

```bash
git checkout main  # 切换到主分支
git reset --hard origin/main  # 重置本地分支到远程分支
git clean -fd  # 删除所有未跟踪的文件和目录
```



# 二、GitHub工作流

参考视频：[十分钟学会正确的github工作流，和开源作者们使用同一套流程-哔哩哔哩](https://b23.tv/vR4P09H)

假设在Github上有一个`repository`，主分支为`main`，主分支main上只有1个commit——`init`（实际上有若干个也无所谓）

> repository ==> branch ==> commit
>
> 每个repository上可以有很多的branch
>
> 每个branch上又可以有很多的commit

当我们想要修改或者贡献代码的时候，第一步就是复制remote仓库到本地。完成`Remote`到`Local`与`Disk`

```bash
git clone https://github.com/RicardoRyn/Plot_figure.git
cd /e/jupyter_notebook/jupyter_notebook_code/git_repositories/working_space/Plot_figure 
```

> 本地仓库由Local和Disk共同组成：
>
> 1. Local是本地的git仓库，拥有所有你告诉git的信息，
> 2. Disk是我们的源文件真正在磁盘中的样子，也是我们用编辑器打开源文件的时候的状态
>
> 在刚刚clone之后，Remote、Local、Disk都是一样的

在我们要修改代码的时候，第一件事就是新建一个新的branch，我们命名为`my_feature`：

```bash
git checkout -b my_feature  # 防止main不能工作，并且有利于多人合作
# 这个命令会复制一份当前的branch到新的branch上
# 目前为止，在我们的Local上，有2个branches，一个是main，一个就是my_feature
# 但是Disk是不知道源文件来自于哪个branch的，它只知道源文件长成什么样子
# 当我们使用checkout命令之后，git会把这个branch（my_feature）上的源文件同步给disk，也就是disk中保存的源代码会是这个branch里的代码
```

注意此时我们的Local git就有2个branch：

1. **main branch，只有一个commit，名为Init**
2. **my_feature branch，只有一个commit，名为Init**

接下来就可以修改源文件，例如增加一些对`README.md`的描述。

当修改完成之后，硬盘上保存的文件是有变化的，但是git对此一无所知

在进行下一步之前，先用`git diff`查看自己进行的修改

当我们决定把修改的文件告知git时，键入：

```bash
git add README.md  # 将修改过的文件置于暂存区
# 至此，git知道了你有一些代码想要commit
```

接下来，使用`git commit`来将所有的修改放入git中

```bash
git commit -m "Add something for README.md" README.md
```

至此，我们的my_feature branch就会新增一个commit，我们的Local git中的2个branch已经不一样了：

1. **main branch。只有一个commit，名为Init**
2. **my_feature branch。有2个commit，第1个名为Init，第2个姑且称为f_commit**

此时，Github remote还什么都不知道，现在需要把我们的修改告知Github，键入：

```bash
git push origin my_feature
```

完成后，Github remote上也保存了代码的改动，它也拥有2个branch：

1. **main branch。只有一个commit，名为Init**
2. **my_feature branch。有2个commit，第1个名为Init，第2个姑且称为f_commit**

我们非常常见的情况是，在我们修改代码的时候，Github remote上的代码又有更新了，此时remote上的2个branch为：

1. **main branch。有2个commit，第1个名为Init，第2个姑且称为update**
2. **my_feature branch。有2个commit，第1个名为Init，第2个姑且称为f_commit**

但是我们Local里的2个branch却是：

1. **main branch。只有一个commit，名为Init**
2. **my_feature branch。有2个commit，第1个名为Init，第2个姑且称为f_commit**

我们需要测试修改的代码是否能在update下运行，我们首先要更新Local git中的main branch。应该切换回main branch中来操作：

```bash
git checkout main
```

此时，硬盘里的源代码就是我们init状态，而不是我们之前修改完的状态

可以通过查看`README.md`文件，发现之前的修改消失了，来确认这一点

然后我们需要把remote上的update同步到我们Local上的main branch上，键入：

```bash
git pull origin main
```

此时，Local中的branch就和remote上的branch都是一样的了：

1. **main branch。有2个commit，第1个名为Init，第2个姑且称为update**
2. **my_feature branch。有2个commit，第1个名为Init，第2个姑且称为f_commit**

然后再回到my_feature branch，键入：

```bash
git checkout my_feature
```

可以通过查看`README.md`文件，发现修改又回来了，来确认这一点

为了同步main的变化，键入：

```bash
git rebase main  # 意思是把我的修改都放一边，先把最新的main拿过来，再把修改尝试放进去
# 在这个过程中可能会有rebase conflict，这时候只有手动选择需要哪一段代码
```

这个时候，我们的Local branch为：

1. **main branch。有2个commit，第1个名为Init，第2个姑且称为update**
2. **my_feature branch。有3个commit，第1个名为Init，第2个姑且称为update，第3个姑且称为f_commit**

这也是使用rebase而不是merge的好处，merge会导致原main branch混乱

然后发现my_feature无误，可以再次push到remote上，键入：

```bash
git push -f origin my_feature  # 由于我们rebase过，所以需要加-f
```

最后，就是把remote上的my_feature合并到main上，即“求拉 new pull request”

我们一般认为，主分支（main）属于项目，而不属于个人。而功能分支（my_feature）属于个人。

pull request的意思是“要求request”项目的主人，把我这个新的分支的改变给pull到项目里去

在项目主任审查完代码之后，确定可以pull，一般使用squash and merge来合并。

因为my_feature可能不止一个commit，在更多的情况下，功能分支（my_feature）上的commit是比较乱的，需要整合所有的commit变成一个commit

squash and merge意思就是把这个一个分支上的所有改变，合并成一个改变，然后把这一个commit，放入main branch中，构成了main branch上的update2

1. **main branch。有3个commit，第1个名为Init，第2个姑且称为update，第3个姑且称为update2（即我们修改的内容）**
2. **my_feature branch。有3个commit，第1个名为Init，第2个姑且称为update，第3个姑且称为f_commit**

在完成squash and merge之后，可以选择把remote上的my_feature branch安全删掉，此时remote上的branch为：

1. **main branch。有3个commit，第1个名为Init，第2个姑且称为update，第3个姑且称为update2（即我们修改的内容）**

最后，远端remote上的修改基本完成，但是本地Local的修改还没有完成，branch为：

1. **main branch。有2个commit，第1个名为Init，第2个姑且称为update**
2. **my_feature branch。有3个commit，第1个名为Init，第2个姑且称为update，第3个姑且称为f_commit**

这个时候需要切换到main branch上：

```bash
git checkout main
```

删除my_feature branch：

```bash
git branch -D my_feature
```

此时Local的branch为：

1. **main branch。有2个commit，第1个名为Init，第2个姑且称为update**

最后再将remote上的更新再pull到Local里：

```bash
git pull origin main
```

则Local中的branch更新为：

1. **main branch。有3个commit，第1个名为Init，第2个姑且称为update，第3个姑且称为update2（即我们修改的内容）**



# 三、vscode中同步gitee

解决 VSCode 每次 git pull/push 时都需要输入账号和密码的问题：

```bash
# 在vscode的终端中输入
git config --global credential.helper store
```


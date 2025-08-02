# 本地操作

`jj git init`， 初始化代码库

`jj st`， 查看仓库当前状态

`jj config set --user user.name "Ricardo_T8"`，设置用户名
`jj config set --user user.email "RicardoRyn1317@gmail.com"`，设置用户邮箱

`jj describe -m "<message>"`，创建/修改新的commit
`jj describe`，使用默认编辑器创建/修改commit

`jj commit -m "<message>"`，为当前change进行commit，生成并跳转到其新的子分支上

`jj new`，创建新的change
`jj new -m "<message>"`，创建新的change，并直接添加commit
`jj new -B @ -m "<message>"`，在当前change之前创建change
`jj new <prefix of change ID> -m "<message>"` ，在指定的change后创建新的change分支
`jj new <prefix of change ID1> <prefix of change ID2> -m "<message>"` ，合并change1和change2成为新的change
`jj new -m "<message> --no-edit"`，创建新的子change但是不移动到它上面去

`jj log` ，查看change链
`jj log -r "heads(all())"`，查看所有分支头
`jj log -r ::<prefix of change ID>`，查看指定change的祖先
`jj log -r <prefix of change ID>::`，查看指定change的子孙
`jj log --limit 5`，查看最新的5条change
`jj log -r "ancestors(main, 2)"`
`jj log -p`，log的同时还展示出patch，方便看到每条commit的变动

`jj squash`，将当前change中的修改，合并到上一个change中
`jj squash -i`，交互式界面。`space`选择，`f`折叠，`c`确认

`jj abandon`，移除当前change，但是会重新创建一个change，其实就是清除所有改动的文件
`jj abandon <prefix of change ID>`，移除指定的change（比如空change）

`jj edit <prefix of change ID>`，跳转到指定的change
`jj next --edit`，跳转到下一个存在的change
`jj prev --edit`，跳转到上一个change

`jj rebase -r <change ID1> -d <change ID2>`， 将`<change ID1>`所指的这个commit rebase到`<change ID2>`所指的这个commit上来
`jj rebase -s <change ID1> -d <change ID2>`， 将`<change ID1>`所指的这个commit以及其所有子changes rebase到`<change ID2>`所指的这个commit上来

`jj op log`，查看所有操作
`jj undo`，撤销操作
`jj undo <op ID>`，撤销到指定操作

`jj file untrack <path>`，移除对某个文件的追踪

`jj evolog`，查看change中的commit变化记录
`jj evolog -p`，查看指定的change中，每个commit的变化内容，`p`即patch

`jj split -i`，将指定change中的修改拆分成2个部分，选中的为留下的部分，剩下的将会作为一个子change

`jj restore -f <commit ID> -t <change ID> --restore-descendants`，将指定change恢复到其某个曾经的commit，然后把剩下的commit存进下一个change中

# 远端操作

`jj git init --colocate`，在一个已经有git仓库的文件夹中插入jj仓库，同时使用git和jj

`jj bookmark create <branch name>`，创建新的命名分支（书签）
`jj bookmark set <existed branch name> -r @`，将分支名设置到当前change上，要求显示指定change
`jj bookmark set <existed branch name> -r @ --allow-backwards`，危险操作，相当于回退某个分支的commit

`jj git remote add origin git@github.com:<User name>/<repository name>.git`
`jj git remote list`

`jj git fetch`，`jj`没有`pull`命令。这条命令会将远端最新的分支拉取到本地，但是是作为一个新的change（并自动更新书签所在位置）

`jj git push --allow-new`，将一个新的书签（也就是分支）推送到github上
`jj git push -c @`，将当前change push到github并创建名为`push-<change ID>`的分支
`jj git push -b <branch name>`，能够推送指定分支

# 一些修订集表达式

`heads()`
`all()`
`mine()`
`remote_bookmarks()`
`bookmarks()`
`connected()`


# 解决冲突

当我们知道某个commit有冲突的时候。最好的做法就是在新建其子change。
```bash
$ jj log
@  qzvqqupx martinvonz@google.com 2023-02-12 15:08:33 1978b534 conflict
│  C
×  puqltutt martinvonz@google.com 2023-02-12 15:08:33 f7fb5943 conflict
│  B2
│ ○  ovknlmro martinvonz@google.com 2023-02-12 15:07:24 7d7c6e6b
├─╯  B1
○  nuvyytnq martinvonz@google.com 2023-02-12 15:07:05 5dda2f09
│  A
│ ○  kntqzsqt martinvonz@google.com 2023-02-12 14:56:59 5d39e19d
├─╯  Say goodbye
◆  orrkosyo octocat@nowhere.com 2012-03-06 15:06:50 master 7fd1a60b
│  (empty) Merge pull request #6 from Spaceghost/patch-1
~
```
例如上面最好的做法就该是`jj new puqltutt`。只要我们在这个子change中解决了冲突，就可以把整个commit squash到`puqltutt`中。
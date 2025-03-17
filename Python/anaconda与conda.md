# 一、Anaconda安装后基本配置

Anaconda默认自带python解释器（最新版），可以不用下载python

anaconda安装好了以后，终端前面就会有一个`(base)`的东西，表示现在的环境名字叫做base

默认安装其他的包都是在国外的网址上下载的，可能会比较慢，所以我们可以加一些国内的镜像网址（例如清华的），键入：

```powershell
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
conda config --set show_channel_urls yes  # 以后下载包用来显示从哪个url里下载
# 设置乱了，可以用以下代码恢复设置
conda config --remove-key channels
# 展示自己用的哪些channels
conda config --show channels
```

这些文本会写到家目录（默认位置）的`.condarc`文件中

`.condarc`文本里有一行默认的`- defaults`，我们可以去掉这一行，避免从国外网址下载包，就比较慢
```
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

---

1. **显示当前所有虚拟环境：**

~~~powershell
conda env list  # 查看已经创建的虚拟环境，此时应该有base、rjx和rjx1
conda info --env  # 也可以显示创建的虚拟环境
~~~

2. **创建/移除一个虚拟环境：**

~~~powershell
conda create --name rjx python=2.7
# 它会在本地检查是否有python2.7版本，如果有就拿过来，没有就安装python2.7我们将python版本换成2.7，它也会把相应的包进行更改，这就是它好用的原因
conda create --name rjx1 python=2.7 requests  #再创建一个虚拟环境叫“rjx1”，依赖的python版本是2.7，还需要requests包（这个包是和爬虫有关的包）

# 在指定路径下创建虚拟环境
conda create -p G:\rm_rjx\rm_rjx1 python=3.9
conda create -prefix=G:\rm_rjx\rm_rjx1 python=3.9

# 移除虚拟环境
conda remove -n rjx --all  # 删除名为“rjx”的虚拟环境

# 给虚拟环境换名字（即创建新名字的环境，然后克隆旧环境所有包到新环境，然后删除旧环境）
conda create --name new_env --clone old_env
conda remove --name old_env --all
~~~

3. **切换虚拟环境：**

~~~powershell
conda activate rjx  # 进入到rjx这个虚拟环境中，终端最前面显示的应该由(base)变成(rjx)
conda activate base  # 相当于也是退回到主库 (base)
conda deactivate  # 退回到主库 (base)
python --version  # 显示当前python版本

# Linux下可以使用以下命令查看python版本
which python  # 查看当前使用的哪里的python（哪个路径下的python）
~~~

4. **虚拟环境管理**

~~~powershell
conda search --name opencv  # 假如我们知道有一个虚拟环境（对，虚拟环境！不是包）叫“opencv“，但是它有很多的版本，我们可以通过这行命令来查询它有哪些版本
conda list --revisions  # 查看历史，获取对应的rev_num数值，可以重置回对应的历史；0一般表示第一次安装，1及之后的数值表示之后的
conda install --revision rev_num

# 不建议使用pip里的requirement.txt，因为只会导出你使用pip安装的依赖包，不会导出虚拟环境所依赖的包，并不适用于虚拟环境的迁移的应用场景。
# pip版本
pip freeze > requirement.txt
pip install -r requirement.txt
# conda版本
conda list --export > requirement.txt  # 生成的requirement.txt文件需要用手动用UTF-8编码打开，否则会报错
conda install --yes --file requirements.txt

# 虚拟环境之间复制和迁移包建议使用以下命令
# --clone以复制一模一样的虚拟环境
conda create --name rm_rjx_new --clone rm_rjx_old

# 跨平台/操作系统创建一模一样的虚拟环境
# 进入A环境，然后导出环境文件
conda env export > environment.yml
# 在另一个平台/操作系统创建和A一模一样环境
conda env create -f environment.yml
~~~

5. **利用conda管理python版本以及下载管理包（不同于pip）**

```bash
conda install python=3.9  # 如果当前python版本是2.7然后我们重新下载其他版本的python，则会覆盖掉原来的2.7版本；覆盖原来的python2.7；如果这里不指定3.9，则会默认下载最新版本

# 利用conda管理python包，和pip安装的包位置不一样
conda install numpy  # 安装numpy这个包，会自动安装numpy包所需要的依赖，比如mkl
# 移除包
```

安装的这些环境会在`anaconda3/env`文件夹中，你在哪个虚拟环境下安装的包，就会在哪个文件夹中

例如：如果你是在“rjx1”这个虚拟环境中安装的`numpy`，就会在`anaconda3/env/rjx1/bin`中找到对应的可执行文件

# 二、Windows PowerShell不显示环境名称

如果没有特殊说明，“终端”指代“Windows PowerShell”

在window中下载完Anaconda后，终端前并不显示`(base)`

解决办法，

以管理员运行的身份打开PowerShell，在PowerShell 添加环境变量：

```
conda init powershell
```

重新打开终端，如果显示`(base)`则成功

如果显示红色如下警告提示：

无法加载文件C:\XXX\WindowsPowerShell\profile.ps1，[因为在此系统上禁止运行脚本]

则在终端中键入：

```
get-ExecutionPolicy
```

终端显示`Restricted`

键入：

```
set-ExecutionPolicy RemoteSigned
```

重新打开终端，成功显示`(base)`

# 三、conda环境安装指定位置的虚拟环境

使用conda创建新的虚拟环境时指定位置

在`G:\rm_rjx\`文件夹下新建一个名为`rm_rjx1` 的虚拟环境

```powershell
conda create -p G:\rm_rjx\rm_rjx1 python=3.9
# 或者
conda create -prefigx=G:\rm_rjx\rm_rjx1 python=3.9
```

显示所有虚拟环境

```powershell
conda env list
# 或者
conda info --envs
```

终端显示：

```powershell
base                  *  D:\Anaconda
                 		 G:\rm_rjx\rm_rjx1  # 该虚拟环境没有名字
```

新建的虚拟环境没有名字的话，其实用绝对路径当作名字也可以

```powershell
conda activate G:\rm_rjx\rm_rjx1
```

但是激活太麻烦了！！！

查看所有虚拟环境文件夹，键入

```powershell
conda config --show envs_dirs
```

终端显示：

```powershell
envs_dirs:
  - D:\Anaconda\envs
  - C:\Users\91009\.conda\envs
  - C:\Users\91009\AppData\Local\conda\conda\envs
```

并没有我们指定的文件夹

所以我们添加之前指定的文件夹到envs_dirs中，键入：

```powershell
conda config --append envs_dirs G:\rm_rjx  # 注意！！！！！！！！！这里是rm_rjx，不是rm_rjx1
# 删除则为
conda config --remove envs_dirs G:\rm_rjx  # 注意！！！！！！！！！这里是rm_rjx，不是rm_rjx1
```

可以发现：

```powershell
base                  *  D:\Anaconda
rm_rjx1                  G:\rm_rjx\rm_rjx1  # 虚拟环境有了名字

envs_dirs:
  - G:\rm_rjx
  - D:\Anaconda\envs
  - C:\Users\91009\.conda\envs
  - C:\Users\91009\AppData\Local\conda\conda\envs
```

现在可以直接激活该虚拟环境，键入：

```powershell
conda activate rm_rjx1
```

# 四、在虚拟环境中配置jupyter notebook

1. **新建完虚拟环境，想要用vscode写jupyter notebook，则还需要添加jupyter kernel（VScode已经不支持python3.6）**

在终端中进入虚拟环境，键入：

```powershell
conda activate rm_rjx1
```

在虚拟环境中默认是没有办法使用当前虚拟环境的kernel的，需要额外配置

在该虚拟环境中需要下载`ipykernel`

```powershell
conda install ipykernel
# 或者
conda install -n RJX ipykernel --update-deps --force-reinstall
```

2. **如果不用vscode，使用普通浏览器运行jupyter notebook，则还需要以下步骤**

将当前环境写入jupyter notebook的kernel中，键入：

```powershell
python -m ipykernel install --user --name rm_rjx1 --display-name rm_rjx1_display_name
# display-name将在jupyter中显示，这里是为了展示更清楚而选择使用不一样的名字，实际使用过程中建议使用与虚拟环境相同的名字
```

打开jupyter notebook在`Kernel`选项中的`Change kernel`选择`rm_rjx1_display_name`即可

此后下载的包将自动安装在对应的虚拟环境的安装包指定位置中

在终端中可以显示jupyter kernel列表，键入：

```powershell
jupyter kernelspec list
```

也可以移除对应的kernel，键入：

```powershell
jupyter kernelspec remove rm_rjx1
```

# 五、环境备份及恢复

备份：

```powershell
conda activate RJX  # 进入RJX环境
conda env export > environment.yml  # 创建名为environment.yml的文件，包含所有虚拟环境的配置信息
```

恢复：

```powershell
conda env create --name new_RJX --file environment.yml  # 将备份文件写入新环境中
```

> 注意：两台机器配置不一样可能回出错，跟cuda版本有关。
>
> 个别包可能依旧没有下载，例如`mne-base`


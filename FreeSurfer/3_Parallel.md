FreeSurfer每个被试大概需要跑16到24个小时，所以处理一个数据集可能需要几天

所以一个方法就是并行（Parallel）跑不同被试数据

基本原理就是现代计算机一般都有几个cores来进行处理，所以每个核都可以处理一个被试

而每次运行recon-all时只会使用一个核心（core），而通过一个名为`parallel`的命令，每个`recon-all`都可以分配给不同的core

物理核心：4

逻辑核心：8（逻辑核心才是你能同时跑的`recon-all`的单独数量）

---

***原文针对mac系统中 `parallel` 命令的下载***

Ubuntu中，在终端键入：

```bash
parallel -help
```

根据提示再键入：

```bash
sudo apt install parallel
```

完成后再次键入：

```bash
parallel -help
```

如果终端打印出帮助文档，则parallel安装成功

最后，`parallel`只能在bash中运行

---

例如，最后想要同时跑所有被试的数据可以键入：

```bash
ls *.nii | parallel --jobs 8 recon-all -s {.} -i {} -all -qcache
```

>“{.}”中的“{}”表示填入管道前的输出
>
>“.”表示移除通配符表征以外的部分，即只显示被试ID而不显示“.nii”

---

在本例中，定位到`Cannabis`文件夹中，然后新建文件夹命名为`FS`，并定位到该文件夹中，打开bash终端，键入：

```bash
ls .. | grep sub- > subjList.txt  # 原文中“sub-”前有个“^”，即“^sub-”，很奇怪，我删了

# 手动用gedit打开.txt文件会发现里面不止被试编号，首尾还有看不懂的字符，这个应该表示不同类型文件在经过ls命令输出后具有不同颜色，很难搞，需要删除
# 不知道怎么删除，手动用gedit替换删掉了

for sub in `cat subjList.txt`; do
cp ../${sub}/ses-BL/anat/*.gz .
done

gunzip *.gz  # 这一步不会生成新的文件，而是将.nii.gz文件转换成.nii文件

SUBJECTS_DIR=`pwd`  # 这一步修改FreeSurfer默认被试文件夹为当前文件夹

ls *.nii | parallel --jobs 8 recon-all -s {.} -i {} -all -qcache  # 一个人大概十几个小时，8核心，共42个被试，大概36个小时，星期五下午3点开始跑，星期天中午应该能跑完(实际上跑了3天，星期一中午1点才跑完= =+)

rm *.nii

# for sub in `cat subjList.txt`; do
# mv ${sub}_ses-BL_T1w.nii ${sub}
# done
```


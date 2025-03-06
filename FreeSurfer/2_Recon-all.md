本例中用到的是 [dataset from openneuro.org](https://openneuro.org/datasets/ds000174/versions/1.0.1) ，下载后将文件夹名字更改为`Cannabis`

```bash
mv ds000174-1.0.1 Cannabis
```

纵向研究（longitudinal study），2个时间点：

1. 一个基线扫描
2. 一个随访扫描（follow-up scan）

本例中有20名大麻吸食者，22名controls

被试ID中1开头的属于cannabis，2或者3开头的属于controls

每个被试文件夹下都有2个文件夹：

1. `ses-BL`表示baseline session
2. `ses-FU`表示Follow-Up session

每个文件夹下都有一个`anat`文件夹

# Recon-all

FreeSurfer有一大堆程序来处理单个被试，每个被试可能需要好个小时的处理时间，一整个数据集可能要跑几天，但还好操作起来很简单

FreeSurfer自带一条命令`recon-all`，能够自动处理所有单个被试最繁琐的部分

---

在学习如何使用`recon-all`之前，先看一下这条命令都生成了哪些文件，有哪些output

`recon-all`首先去除颅骨，生成一个`brainmask.mgz`文件（`.mgz`表示Massachusetts General Hospital文件，`z`表示zipped，压缩文件，这是FreeSurfer才能识别的文件）

任何3D文件都储存在名为`mri`的文件夹中

`recon-all`然后估计两半球的**白质和灰质边界**，存在`lh.orig`和`rh.orig`文件中（分别表示左半球和右半球）

这些初始估计（initial estimate）被精炼（refine）出来，存在名为`lh.white`和`rh.white`的文件中。这些边界（boundary）作为基础，被`recon-all`用来寻找灰质的边缘

当到达灰质边缘时，创建`lh.pial`和`rh.pial`文件，这两个文件表征pial surface，就像一层塑料膜包裹在灰质的边缘

以上生成的所有文件都可以当作一个2D的surface看，也可以当作3D的volume看，键入：

```bash
freeview -v ./mri/brainmask.mgz -f surf/lh.orig:edgecolor=yellow  # :edgecolor=yellow也可以不加，默认是黄色
```

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/03_Orig_White_Pial.png" alt="../../_images/03_Orig_White_Pial.png" style="zoom: 50%;" />

> 黄线表示白质和灰质的边界估计，黄线被精炼为更精确的蓝线，蓝线为基础，被用来检测灰质的边界，即红线
>
> 这些文件都能在Freeview中看，Freeview是FreeSurfer自带的查看器

FreeSurfer还能创建`lh.inflated`和`rh.infated`，来进一步扩展surface数据集

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/03_Pial_Inflated.png" alt="../../_images/03_Pial_Inflated.png" style="zoom: 25%;" />

>An illustration of converting the `lh.pial` file into `lh.inflated`.

这个图像并不是用来使结果可视化的，这是一个名为`fsaverage`的标准化模板（normalized ），是40个被试的平均

当个体被试的大脑配准到这个标准模板之后，就可以分区（parcellate）；FreeSurfer会根据2个atlas来分区：

1. The Desikan-Killiany atlas
2. The Destrieux atlas（分区更多）

至于用哪个取决于你的分析的细粒度（how fine-grained an analysis you wish to perform）

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/03_FreeSurfer_Atlases.png" alt="../../_images/03_FreeSurfer_Atlases.png" style="zoom: 25%;" />

---

开始实操

只需要T1加权结构像

定位到sub-101的结构文件夹下，然后跑`recon-all`命令

```bash
cd sub-101/ses-BL/anat
recon-all -s sub-101 -i sub-101_ses-BL_T1w.nii.gz -all  # -s表示被试的名字；-i表示input，即结构像的名字；-all表示会跑所有的预处理步骤，建议除了在编辑数据之后重新跑recon-all命令之外，都加上该选项
```

命令运行时，output默认会存在`$SUBJECTS_DIR`中，而`$SUBJECTS_DIR`是个变量，指的是`$FREESURFER_HOME/subjects`而`$FREESURFER_HOME`也是个变量，指的是FreeSurfer安装的文件夹，即`/usr/local/freesurfer`，换句话说，`recon-all`的命令将会默认保存在`/usr/local/freesurfer/subjects`中

> 如果报permission error，可以键入`Sudo chmod -R a+w $SUBJECTS_DIR`，然后重跑`recon-all`命令；这是修改文件权限的

**跑完记得将默认文件夹中的被试文件夹移动到数据盘中**

或者在跑之前使用命令：

```bash
SUBJECTS_DIR=`pwd`  # 先将被试文件夹路径定义到当前路径下
```

作者建议加上`-qcache`选项，因为这可以在不同level下平滑数据，并存在被试的output文件夹下。组分析中很有用

如果你已经跑完了`recon-all`的预处理，可以用下面这行命令跑`qcache`，大概每个被试10min

```bash
recon-all -s <subjectName> -qcache
```


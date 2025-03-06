全脑分析/探索性分析（whole-brainor exploratory analysis）

验证性分析（confirmatory analysis）

全脑分析有可能掩饰掉我们想要研究的内容的一些细节现象，所以需要ROI分析来更精确的进行研究

# 使用Atlases创建ROI

打开fsleyes，在顶部的菜单栏中选择`Settings`，点击`Ortho View 1`，找到`Atlases`，点击后下方出现Atlases面板

默认使用

- **Harvard-Oxford Cortical Structural Atlas**
- **Harvard-Oxford Subcortical Structural Atlas** 

可以通过右边的`Show/Hide`来显示或者隐藏图集，下面会显示十字交叉点位置对应图集位置的概率（underlay是MNI标准模板）

![../_images/ROI_Analysis_Atlas_Example.png](https://andysbrainbook.readthedocs.io/en/latest/_images/ROI_Analysis_Atlas_Example.png)

本例中，我们关注Paracingulate Gyrus，并将其作为一个mask，点击Atlases面板中的`Paracingulate Gyrus`右边的`Show/Hide`，将该区域显示在underlay上，如下图，然后点击`Overlay list`面板中右边的“软盘”图标，将其存在`Flanker`文件夹中，命名为`PCG.nii`

> 注意：fMRI数据分析的结果的分辨率和normalization时用的模板的分辨率相同（本例中用的是MNI_152_T1_2mm_brain），而通过图集创建mask（ROI）时，其分辨率与underlay的分辨率相同，所以为了让data和mask的分辨率相同，避免后续报错，利用图集创建mask时就应该使用数据分析时相同的模板，所以应该使用MNI_152_T1_2mm_brain的模板

## 提取mask中的数据

实际上，我们需要从2nd-level analysis提取数据，而不是3rd-level analysis

因为3rd-level analysis里只有一张image，每个voxel只有一个值；但是在ROI分析中，我们的目的是提取每个被试的cope

本例中，我们想要提取Incongruent-Congruent的cope，能在`Flanker_2ndLevel.gfeat/cope3.feat/stats`中找到每个被试的data，这些数据包括：

- t-statistic maps（作者推荐这个，因为这些数据已经转换成正态分布的形式，并且更容易绘制和解释）
- cope images
- variance images

---

为了使ROI分析更加容易，需要将所有的z-statistic maps合并到一个dataset

定位到`Flanker_2ndLevel.gfeat/cope3.feat/stats`，键入：

```bash
fslmerge -t allZstats.nii.gz `ls zstat* | sort -V`  # 这行代码可能会报错，原因未知，报错的话只有手动写个脚本，将所有的zstat文件按顺序排好然后再跑了
```

上面一条命令会将所有z-statistic images沿着时间维度（`-t`选项）合并到名为`allZstats.nii.gz`的文件中

然后利用fslmeants命令提取PCG mask里的数据，键入：

```bash
fslmeants -i allZstats.nii.gz -m PCG.nii.gz
```

终端中会打印26个值，分别对应26名被试的mask上的平均cope

![../_images/ROI_Analysis_FSLmeants_output.png](https://andysbrainbook.readthedocs.io/en/latest/_images/ROI_Analysis_FSLmeants_output.png)

然后利用其他的统计学软件来研究这些值之间的统计学性质

# 使用球形ROI

其实上面利用anatomical mask做出的结果并不显著，可能原因是PCG太大了

spherical ROI的划分需要x，y，z轴坐标，然后是球体的范围

其中坐标往往是根据前人研究得到的峰值的坐标来的，不用担心循环论证的问题，这依旧是一项独立的分析，因为你的数据是一种完全单独的study

例如根据Jahn et al., 2016研究，得到坐标0，20，44；

打开fsleyes，打开`MNI152_T1_2mm_brain.nii.gz`模板文件，然后在Coordinates: MNI152的坐标窗口里输入前人研究坐标0，20，44；**记住右侧`Voxel location`为45，73，58**

---

然后定位到`Flanker`文件夹下，键入：

```bash
fslmaths $FSLDIR/data/standard/MNI152_T1_2mm.nii.gz -mul 0 -add 1 -roi 45 1 73 1 58 1 0 1 Jahn_ROI_dmPFC_0_20_44.nii.gz -odt float
```

**记住上面一行代码中的45，73，58的位置，以后做ROI分析时只需要更改这个就好**（还有各种输入输出的名字）

这一行代码的输出就是上述坐标的单个voxel

---

接下来键入：

```bash
fslmaths Jahn_ROI_dmPFC_0_20_44.nii.gz -kernel sphere 5 -fmean Jahn_Sphere_dmPFC_0_20_44.nii.gz -odt float
```

记住上一行代码中的5，及以那个voxel为中心，半径为5mm画球，最后得到名为`Jahn_Sphere_dmPFC_0_20_44.nii.gz`的文件

这一行代码的输出就是那个voxel为中心，半径为5mm内的所有体素，即我们想要的球

---

最后键入：

```bash
fslmaths Jahn_Sphere_dmPFC_0_20_44.nii.gz -bin Jahn_Sphere_bin_dmPFC_0_20_44.nii.gz
```

将球做成二值mask，名为`Jahn_Sphere_bin_dmPFC_0_20_44.nii.gz`

---

最后键入：

```bash
fslmeants -i allZstats.nii.gz -m Jahn_Sphere_bin_dmPFC_0_20_44.nii.gz
```

用来提取这个球型ROI中的值


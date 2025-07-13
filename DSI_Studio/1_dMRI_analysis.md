# 一. 怎么使用dsi_studio分析dMRI

![image](https://user-images.githubusercontent.com/275569/182761132-9bd68015-509a-4e11-9b11-c1f4c63ddcd6.png)

# 二. 从原始DICOM或者NIFTI文件中创建SRC文件

# 三. SRC文件质量控制

# 四. 利用GQI（个体空间）或者QSDR（模板空间）从SRC文件中重构FIB文件

# 五. 分析方法决策树

![image](https://user-images.githubusercontent.com/275569/147861653-6f86b49c-143f-4297-a304-6b28680c1691.png)

## 六. 使用GUI

## [[Step T1\] Generate SRC file](https://dsi-studio.labsolver.org/doc/gui_t1.html)

## [[Step T2\] Reconstruction](https://dsi-studio.labsolver.org/doc/gui_t2.html)

## [[Step T3\] Whole Brain Tracking & Connectivity Matrix](https://dsi-studio.labsolver.org/doc/gui_t3_whole_brain.html)

打开主窗口并点击`[Step T3: Fiber Tracking]`，选择一个FIB文件，然后会弹出一个tracking窗口

在tracking窗口中找到`[Step T3d:tracts]`面板中的`[Fiber Tracking]`按钮，点击后就会自动进行全脑tracking

在`[Step T3d: Options]`面板中，有`[Tracking Parameters]`选项，里面可以调整track过程的参数

为了tracking质量更高，可以修改例如`[Tracking Threshold]，[Min Length]，[Terminate if]`等

### 手动编辑Track

在`[Edit]`的菜单栏中选中`[Select]`或者直接按`ctrl + s`

#### Track Cutting

例如以胼胝体为中心，把tracts分割成左右2部分。然后只需要选中其中一部分进行后续分析就行。

#### Track Painting

使用`ctrl + p`给不同tracks分配颜色

#### 快捷键

ctrl + s：在3D窗口中选择tracts

ctrl + d：在3D窗口中删除tracts

ctrl + p：在3D窗口中给tracts分配颜色

ctrl + x：在3D窗口中cut掉tracks（点击-拖动-释放）（**不能撤销**）

ctrl + t：修剪tracks（相当于topology-informed pruning）

ctrl + z：撤销

ctrl + y：重做

### 保存tracks

dsi_studio默认会把tracks保存到“**个体弥散体素空间b**”，并旋转成“**LPS**”，这个体素空间从(0,0,0)开始，也就是最**左/前/底**，方向是**(+右,+后,+顶)**，例如**(1,2,3)=[最左边的第1个体素,最前边的第2个体素,最底边的第3个体素]**

> DSI Studio saves tracks in the native diffusion voxel space rotated to “LPS”. The coordinates are voxel coordinates started from (0,0,0) at the most left/anterior/bottom point of the image volume. The orientation is (+right,+posterior, +top). For example, (1,2,3) = [the left most 1st voxel, the most anterior second voxel, the bottom 3rd voxel].

### 连接矩阵

1. 首先要生成全脑tracking，至少要1,000,000条tracks，才能达到统计量
2. 点击`[Step T3a]`面板里的`[Atlas]`可以增加想要研究的ROI
3. 点击菜单栏中的`[Tracts]`中的`[Connectivity matrix]`，dsi_studio会自动执行空间标准化保证内置分区配准到个体上

生成的.mat文件也可以通过一下命令放到python里读取

```bash
from scipy.io.matlab import loadmat


m = loadmat("connectivity.mat")  # 所有的.mat格式文件通过这种读取方式放到python里都是字典
names = "".join(m["name"].view("S4")[``0]).split("\n")  # 这条命令会报错，原因未知
```

### 图论相关

未完待续！！！！！！！！！

## [[Step T3\] AutoTrack & Tractometry](https://dsi-studio.labsolver.org/doc/gui_t3_atk.html)

自动纤维tracking旨在map出一个目标通路（例如一些常见的纤维束），适用于TOI（tract-of-interest）分析

dsi_studio使用一个tractography atlas（HCP tractography atlas (Yeh 2018) ，也是一种图集，但是这是白质的图集），来顾虑掉假阳性的tracks和不相关的tracks，dsi_studio具体操作如下：

1. 把个体文件配准到MNI空间
2. 把seed区放在某个tract上
3. 每根通过seed区生成的streamline会与白质图集上的streamline进行比较，使用的指标是Hausdorff distances
4. 目的是确定生成的streamline中，哪些与图集中的streamline最匹配，从而进行保留，其他的可能会被剔除

点击`[Step T3d:Tracts]`里的`[Enable auto track]`选项，dsi_studio就会自动根据白质图集识别

也可以选择TOI来研究

未完待续！！！！！！！

## [[Step T3\] ROI-based Tracking](https://dsi-studio.labsolver.org/doc/gui_t3_roi_tracking.html)

首先在主窗口选择FIB文件

左上角的面板用来加载脑区，`[Step T3a: Assign Regions]`

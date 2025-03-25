# Brain Imaging Data Structure (BIDS)

[Brain Imaging Data Structure (neuroimaging.io)](https://bids.neuroimaging.io/index.html)

大脑成像数据结构

格式化数据结构有助于更好的分析以及交流

![image-20210803213218611.png](https://i.loli.net/2021/11/01/xeUF6Q1WLBgjAru.png)

# 检查结构像

## Gibbs Ringing Artifacts

吉布斯振铃效应

![image-20210803221033571.png](https://i.loli.net/2021/11/01/9JIA3itGRLjxCoD.png)

原因可能是MR信号重建时错误或者被试头动过多导致的

如果伪影过多，可能会导致预处理中的brain extraction或normalization失败

## 灰质或白质内的异常强度差异

可能是aneurysms（动脉瘤）或cavernomas（海绵体瘤）等病理原因造成的，应该劝被试去找放射科医生检查

[Brain - MRI SHARK](http://www.mrishark.com/brain1.html)

> 病理状况下的大脑成像图库

# 检查功能像

学会用afni图形界面中的`Read`和`Switch`切换文件夹

就不用反复打开文件夹或使用多个终端

QC文件夹即：quality checks 

1. 小心灰质或白质中特别亮/暗的点
2. 小心异常拉伸和卷曲
3. 大脑的眶额叶总有些许扭曲（属fMRI的缺陷）
4. 查看功能像随时间变化是否发生过度头动（在afni界面的`Graph`中按`v`，按`空格`停止。By the way，`a`键 的功能是：automatic scaling）

# afni的快捷键和键盘命令

[AFNI Tips (nih.gov)](https://afni.nimh.nih.gov/pub/dist/src/html/afnigui.html)

> afni的快捷键和键盘命令

1. 按`done`两次可以退出afni；或者先点击afni主界面，按住`shift`然后再点击主界面的`done`就可以一键关闭afni所有窗口
2. 按下`Bhelp`后再按任何按键都会弹出help提示
3. 右键`Image`会将指定图像窗口定位到光标处，用来快速定位被一堆窗口掩埋的图像
4. 右键`DataDir`将会显示过时的`Define Masker`按钮
5. 右键脑片图上的`Disp`按键会将主afni窗口置顶
6. 在脑片图上按住左键不放水平方向拖动调亮度，垂直方向拖动调对比度（能够同时更改3个脑片图的参数）
7. afni里image viewer窗口里的快捷键（使用`Bhelp`按键后点脑片图也可以显示）：
   `a` 恢复窗口纵横比
   `c` 裁剪模式；`shift+方向键` 移动裁剪区；`ctrl+方向键` 缩放裁剪区
   `i` 缩小窗口；`I` 放大窗口
   `l` 左右镜像
   `o` 显示/关闭Overlay
   `q` 关闭当前脑片图
   `r` 类似于v的移动，但是到边后会反弹；`R` 反向
   `v` 循环移动；`V` 反向
   `s` 锐化Underlay
   `S` 保存
   `u` 互换Underlay和Overlay
   `z` 缩小图像；`Z` 放大图像
   `[` 向左移动index；`]` 向右移动index
   `{` 缩小阈值；`}` 放大阈值
   `<` 向前移动脑切片；`>` 向后移动脑切片
   `#` 切换棋盘模式；`3` 关闭棋盘模式
   `4` 弹出滑块以水平擦除；`5` 垂直擦除
   `6` 弹出滑块显示Underlay和Overlay的重合度
8. afni里graph viewer窗口里的快捷键（使用`Bhelp`按键后点脑片图也可以显示）
   `a` 自动定标图像（一次）；`A` 自动定标图像（每次）
   `b` 改变图像基准线
   `B` 在框图和线图之间切换
   `g` 缩小垂直网格间距；`G` 放大垂直网格间距（具体间距见Grid值）
   `i` 减小图像“忽略”等级；`I` 放大图像“忽略”等级（具体忽略等级见Ignore值）
   `l` 移动到最后一个时间点；`1` 移动到第一个时间点
   `<` 向前移动一个时间点；`>` 向后移动一个时间点
   `L` 关闭afni的logo
   `m` 缩小体素显示量；`M` 缩小体素显示量
   `q`离开此窗口
   `r` 类似于v的移动，但是到边后会反弹；`R` 反向
   `v` 循环移动；`V` 反向
   `S` 保存
   `t` 显示数值大小（而不是线形图）
   `z` 向下移动一张脑片图；`Z`向上移动一张脑片图
   `-` 缩小图形比例；`+` 放大图形比例
9. 通过快捷键调整阈值
   `home` 调至最小
   `end` 调至最大
   `pageUp` 向上粗调
   `pageDown` 向下粗调
   `上箭头` 向上细调
   `下箭头` 向下细调
10. afni窗口标题显示的[A]、[B]表示第一个、第二个主界面

# afni preprocess中的命令

## 3dSkullStrip

### -h

例如查看`3dSkullStrip`命令的help文档，键入：

```bash
3dSkullStrip -h  # 会在终端中打印对应命令的help文档
3dSkullStrip -h | less  # 表示|左边的命令会pipe到|的右边
```

在`less`命令导致的窗口里，`d`表示下一页，`u`表示上一页；输入`/`后再输入指定内容可进行查找

### -input

指定删除某个文件的头骨

```bash
3dSkullStrip -input sub-08_T1w.nii.gz  # 后面会生成skull_strip_out+orig文件
```

### -push_to_edge

在去除颅骨的过程中，宁愿在颅骨和硬脑膜的地方犯错，也不要在皮层处犯错

`-push_to_edge`就是避免切除任何皮层部分的命令，如下：

```bash
3dSkullStrip -push_to_edge -input sub-08_T1w.nii.gz -prefix anat_ss  # ss表示skull-stripped
```

### -no_avoid_eyes

`3dSkullStrip`默认avoid eyes，可以使用`-no_avoid_eyes`命令来强制不avoid eyes

### -use_skull

有时候由于强的shading aftifacts，不得不用外层skull来限制surface的扩张，这时候就用这条命令，防止呈现一种“泄露”状的image

## &

 `&`能让命令运行的同时，终端还能键入其他命令

另一种方法是先`Ctrl+z`暂停命令，然后在终端键入`bg`并回车，就会将正在运行的命令至于后台，显示出的终端可以用来键入其他命令

`uber_subject.py`中可以直接用`.nii`文件

## 3dTshift

### -tzero 0

做时间校正的时候将第一张slice作为参考（afni里0是第一个，然后才是1,2,3,4...）

### -quintic

resample 的算法，表示使用5th-degree polynomial对每张slice进行resample（也叫插值方式）

可以换成`-Fourier`

因为时间校正就是联系前后时间点的slice的信息，来提高精度

这样做确实影响了slice之间的相关性，后面会利用`3dREMLfit`命令来纠正这一相关性

## MNI152

是由152个健康成年人的大脑平均得到的标准模板，适用于大量研究

如果你的研究关注的是儿童或者老年人，可能需要使用其他模板

## 空间配准

将个体配准到标准空间的方法称为Affine Transformation

有4种线性变换，共12种维度（3种translation, 3种rotation, 3种zoom, 3种shear）

> 线性变换：沿轴在一个方向上应用的变换伴随着在相反方向上大小相等的变换。例如，向左平移一毫米意味着图像已经从右侧移动了一毫米
>
> 非线性变换：没有以上限制的变换称为非线性变换。例如，非线性变换可以在一个方向上放大图像，而在另一个方向上缩小图像，就像挤压海绵一样。

理论上我们需要将**功能像**往结构像上配准（即结构像保持不变，将功能像进行affine transform），但是由于功能像分辨率太低并不好变换，所以afni采用的是将**结构像**往**功能像**上配准

因为功能像和结构像是在一个session上扫描得到的，afni先将高分辨率的结构像和模板进行配准，并记录所需的变换，就可以利用相同的变换将功能像与模板进行配准

结构像与模板之间的配准称为aligning；而功能像与结构像的配准被称为registration，

**结构像（T1成像）上的dark区域**（例如脑脊液）在**功能像（T2成像）上却是bright**，这被称为mutual information。配准算法移动图像将一幅图像上的亮体素与另一幅图像上的暗体素进行匹配，然后又将暗体素与亮体素进行匹配，直到找到无法改进的匹配为止

## align_epi_anat.py

用来指定将要进行的registration的一些参数

### -epi

后跟variability最小的功能像作为参考

### -epi_strip

后跟的`3dAutomask`表示使用`3dAutomask`命令（`3dSkullStrip`的替代）来去除非脑组织

### -volreg off -tshift off

表示不希望在当前命令中包含头动校正和时间校正

## @auto_tlrc

用来指定你将要进行aligning的一些参数

### -base

后跟`MNI_avg152T1+tlrc`表示用于配准到的标准空间的模板

### -input

后跟你要配准的结构像（大部分情况下都是去除过颅骨的）

### -no_ss

表示该结构像已经去除了颅骨

## cat_matvec

为了将结构像配准到模板，需要进行一些线性变换，这条命令将会创建affine transformation matrix，记录这些变换，并写进`warp.anat.Xat.1D`文件里

## 头动校正

进行一种称为Rigid-body Transformations的变换

但是它只有2种线性变换，6个维度（3种translation, 3种rotation）。刚体总不可能进行zoom和shear吧

## 3dvolreg

指定一些关于头动校正的参数

### -base

后跟校正用的参考项，推荐使用具有最小头动的volume，这个是根据之前的`3dToutcount`计算出来的

### -1Dfile

后面跟的1D文件中记录了头动参数

### 1Dmatrix_save

后跟的affine matrix中记录了每个TR需要沿着每个维度“unwarped”多少才能配准

## cat_matvet 

将**空间配准**的affine transformation matrix和**头动校正**的affine transformation matrix连接到一起

## 3dAllineate

该命令使用上一步连接得到的affine matrix来创建一步完成头动校正和标准化的fMRI数据集

## 空间平滑

空间平滑的优点：减小噪音，放大信号

空间平滑的缺点：使图像更模糊，降低数据分辨率

## 3dmerge

### -1blur_fwhm

指定平滑处理的kernel（单位为mm），默认为4mm

### -doall

即do all，将该4mm应用于每个volume

## 掩码/蒙版

遮盖大脑皮层以外的区域

## 3dAutomask

该命令只需要input和output文件

=====mask=====block的剩余部分用来创建整个实验中所有individual fMRI datasets形成的masks union，然后计算结构像的mask，然后取fMRI和结构像masks的intersection

## 时间上的标准化

采用β权重表示的条件之间的信号强度对比度

## 检查预处理文件

`pb01`表示Processing Block 01

![../../../_images/04_07_Preprocessing_Directory.png](https://andysbrainbook.readthedocs.io/en/latest/_images/04_07_Preprocessing_Directory.png)

生成的`pb00.*.tcat`文件本身就没有什么用，但是留着它除了占一点内存外也没有什么问题

在Underlay菜单里有两条柱，左边一条是文件名，右边一条包含一些信息

- `epan`表示echo-planar image，即功能像
- `abuc`通常情况下和anat同义
- `epan`旁边的`3D+t:146`表示这是3维图像，有146个volume，即146个时间点
- +tlrc表示该图像已经标准化，并不是一定就在Talairach空间中，在新版本中为了代码能够正常运行而进行了保留

afni里有两种mask可以选用，`full_mask`和`mask_group`

- `full_mask`是个体所有独立的功能像的masks的联合，其中信号强度非常低的体素将不被认为是体素。可以注意到full_mask排除了眶额叶处的体素
- `mask_group`更liberal，`mask_group`更接近配准的标准模板

# First-level Analysis

一个volume就是一个TR，即一个整脑，所有整脑连接起来就是一个run

每个体素的值在run中随时间变化而变化，称之为time-series，即数据集中时间序列的数量等于体素的数量

> session：在SPM中，run被称为session

在刺激呈现之后，BOLD信号上升，在6秒左右到达顶峰，然后在接下来的几秒内回落到基线。这个形状可以用一个叫做γ分布（Gamma Distribution）的数学函数来建模。当这个模型能够最好拟合BOLD信号时，称之为HRF，即Hemodynamic Response Function，血液动力反应函数

---

一个regressor即一个回归因子，也即一个独立变量

GLM（一般显性回归）就是用多个regressor去拟合一个dependent variable（因变量）

每个regressor都有一个β值，表示它们在拟合中的权重

拟合出来的曲线和真实曲线之间的差异被称为残差

每个体素都有自己的时间序列，afni要做的就是拟合每个体素的时间序列，这被称为mass univariable analysis

---

一个汇总的时间刺激文件，即time files也被称为onset files，一般是.tsv格式；里面记录了onset time, duration和parametric modulation

.tsv格式文件需要被转换成.txt格式的文件（即我们在uber_subject.py中需要用到的文件）

> parametric modulation：之后再讨论，现在只需要知道它是必须的，且默认状况下值是1

这些时间刺激文件（.txt）后来会被timing_tool.py转换成每种条件下的time file，一般是.1D文件（也可以是.txt文件，但是格式要对），能够让afni进行阅读

![../../../_images/05_05_TimingFiles_Example.png](https://andysbrainbook.readthedocs.io/en/latest/_images/05_05_TimingFiles_Example.png)

> *The Run-1_events.tsv file on OpenNeuro.org (A). When we download it and look at it in the Terminal, it looks like the text in window (B). We then re-format the events file to create a timing file for each run with three columns: Onset time, duration, and parametric modulation (C), and use AFNI’s timing_tool.py to convert this to a timing format that AFNI understands (D).*

在uber_subject.py文件里输入时间刺激文件，后面的basis funcs选项里有：

-  `GAM`选项表示onset time用将用经典的HRF来convolve（卷积），后面只需要输入一个参数，即HRF的高度（大致对应神经激活的程度）
- `BLOCK`
- `TENT`选项表示在条件的onset之后特定的时间点激活
- `SPMG2`选项包含时间导数（and `SPMG2`, which includes a temporal derivative）

file types选项里有：

- `times`选项表示对时间文件中记录的所有时间点进行卷积，并拟合出一条对于**所有条件**来说最接近HRF的曲线
- `IM`选项会对**每个试次**estimate出一个单独的β值
- `AM1`和`AM2`选项是用于parametric modulation analyses的
- `files`选项表示不需要进行卷积（用于类似于头动之类的nuisance regressor）

---

Symbolic GLTs里

`label`表示标签，即简称，是一整个字符串，所以里面不用有空格

后面的`simbolic GLT`里，本例中的`incongruent -congruent`里表示incongruent的权重为+1，而congruent的权重为-1，两个值，所以中间要有空格

`0.5*incongruent +0.5*congruent`表示两者的平均

> As a general rule, contrast weights that compute a ***difference*** between conditions should ***sum to 0***, and contrast weights that take an ***average*** across conditions should ***sum to 1***. （差值和为0，平均和为1）

---

extra regress option里

`outlier censor limit`规定了异常值的大小，大于后面输入的参数的TR将会被去掉（默认为0.0，表示不会censor掉任何TR）；该outlier值由3dToupcount计算

`GOFORIT`会忽略3dDeconvolve检测出的任何矩阵设计中的warning（一般都不用，除非你觉得你矩阵设计中的警告都可以忽略不计）

`bandpass in regression`多用于静息态，对于任务态来说，**low-pass filtering**会移除任何**高频**信号，就有可能移除相关的活动信号，慎用

`Regress motion derivatives`会模拟头动回归的高阶导数，用于捕捉更加复杂的头动（适用于儿童和某些病患；或一个run过长，例如有着200个TR）

`run cluster simulation`会在移动阈值滑块的时候计算一个cluster是否具有统计学意义（一般在单个的被试预处理都不会用；在组分析中可能会用到）

`execute 3dREMLfit`与传统的3dDeconvolve相比，能够创建一个单独的统计数据集，可以更好的解释时间自相关（temporal autocorrelation）；后面可以用该选项的输出内容更好地进行组分析（在`3dMEMA`里会用到）

---

![../../../_images/06_FirstLevel_Output.png](https://andysbrainbook.readthedocs.io/en/latest/_images/06_FirstLevel_Output.png)

`stats.sub_08+tlrc`文件是由传统的3dDeconvolve方法得到的

`stats.sub_08_REML+tlrc`文件则考虑了时间自相关

可以通过键入：

```bash
aiv X.jpg  # 来看design matrix
1dplot -sepscl X.xmat.1D  # For a different view, looking at all of the regressors in separate rows
```

1dplot查看的图顺时针旋转个90度就是jpg里的图，值越大，颜色越黑

在查看结果时，你应该保证通过高阈值（例如p = 0.001)的体素集中在灰质内，如果这种体素在脑室里（空洞），说明你的数据的质量有问题

---

先用`uber_subject.py`生成某个被试的`proc.sub_08`的脚本

然后进行如下操作（以Flanker实验为例）

```bash
cp sub-08/subject_results/group.Flanker/subj.sub_08/proc.sub_08 proc_Flanker.sh  # 将第一个被试的proc.sub_08脚本复制到包含所有被试的文件夹中（这里并没有显示），然后更名为proc_Flanker.sh
```

标准的`proc.sub_08`脚本开头会有这么一段：

```bash
# the user may specify a single subject to run with
if ( $#argv > 0 ) then  #即if the user provides an argument (i.e., an input), then set the variable “subj” to whatever the argument is.后面会看到
    set subj = $argv[1]
else
    set subj = sub_08
endif
```

要对一堆被试做预处理，前面应该用for循环：

```bash
for i in `cat subjList.txt`; do
  tcsh proc_Flanker.sh $i;  # 这里的i即对应上面的$#argv
  mv ${i}.results $i;
done
```

但是脚本中还是有些许地方是硬编码（hard-coded）sub-08，需要手动查找然后替换成变量

然后就是将一些绝对路径改成相对路径

例如将`/Users/ajahn/Desktop/Flanker`改成`${PWD}`（`${PWD}`作为一个变量表示当前工作目录）

---

为了加快预处理速度，建议在3dDeconvolve命令中加入-mask参数

例如：`3dDeconvolve -input pb04.$subj.r*.scale+tlrc.HEAD -mask mask_group+tlrc`

但是也有人反对这么做，他们认为大脑外（即mask外）也有系统性的变化，使用mask会忽略这些变化

# Second-level Analysis(Group Analysis)

## 3dttest++

有2种做组分析的方法：

- 3dttest：在显著性检验中仅使用对比度估计值（contrast estimate）
- 3dMEMA：既可以解释参数估计值之间的差异，也可以解释对比的变化（ the variability of that contrast），in order to give more weight to those subjects who have lower variability in their estimates。

第一行可以选择`3dttest`，也可以选择`3dMEMA`

组分析时的mask可以选用任意一个被试的`mask_group+tlrc`文件，因为各个被试的`mask_group+tlrc`文件都很similar

如果你很严谨，你可以使用3dmask_tool命令计算一个mask，命令如下：

```bash
3dmask_tool -input <path/to/masks/> -prefix mask_intersection+tlrc -union
```

## 校正

afni的cluster correction方法要求被试估计数据的平滑度，然后使用这些平滑度来规定重要cluster的阈值

首先需要3dFWHMx命令作用于被试的残差文件：

```bash
3dFWHMx -mask mask_group+tlrc -input errts.sub-01_REML+tlrc -acf
```

然后输出如下：

```bash
0.827124 2.9802 5.31313    7.16512
```

前3个参数是创建自相关函数（即给定体素与相邻体素的相关性模型）的

最后一个参数是estimate smoothness，单位毫米

然后这些参数会被3dClustSim命令使用：

```bash
3dClustSim -mask mask_group+tlrc -acf 0.827 2.980 5.313 -athr 0.05 -pthr 0.001
```

`-athr`表示全体α值（0.05），`-pthr`表示未校正的 体素团形式（cluster-forming）的p值（0.001）

结果输出是一个表，显示达到显著的cluster至少要达到的体素数量

![../../_images/3dClustSim_Table.png](https://andysbrainbook.readthedocs.io/en/latest/_images/3dClustSim_Table.png)

**上图显示：cluster定义的p值为0.001，至少需要8.6个体素（通常四舍五入到9个体素）**

相关的一些术语：

```bash
NN1 - Voxels are contiguous (i.e., part of the same cluster) if the faces touch
NN2 - Faces OR edges need to touch
NN3 - Faces OR edges OR corners need to touch

1-sided - Voxels are contiguous if they have the same sign (e.g., only looking at voxels where A>B)
2-sided - Voxels are contiguous if they are either positive or negative
bi-sided - Separate the clusters if the voxels have different signs
```

---

2019版本以后的afni拥有`-3dClusterSim`命令

可以在组分析的3dttest++命令后面插入，例如：

```bash
3dttest++ -3dClustSim -prefix $results_dir/Flanker-Inc-Con       \
        -mask $mask_dset                                         \
        -setA Inc-Con
```

这条命令的输出是一个z统计图像（一个.1D文件），里面说明了一个cluster至少要有多少体素才能显著。行表示α值（例如0.05），列表示体素团形式（cluster-forming）的p值（例如0.001）

```bash
# CLUSTER SIZE THRESHOLD(pthr,alpha) in Voxels
# -NN 3  | alpha = Prob(Cluster >= given size)
#  pthr  | .10000 .09000 .08000 .07000 .06000 .05000 .04000 .03000 .02000 .01000
# ------ | ------ ------ ------ ------ ------ ------ ------ ------ ------ ------
 0.100000    7659   8174   8664   9262   9840  10571  11286  12271  13609  15859
 0.090000    6325   6804   7356   8015   8596   9246  10045  10982  12266  14584
 0.080000    4753   5301   5845   6425   7182   7830   8580   9649  10974  13194
 0.070000    3283   3696   4184   4778   5439   6243   7172   8153   9453  11699
 0.060000    2000   2291   2666   3136   3676   4409   5324   6295   7808  10056
 0.050000    1160   1336   1542   1797   2187   2629   3289   4323   5621   8082
 0.040000     659    740    843   1005   1194   1469   1801   2281   3385   5796
 0.030000     351    383    427    496    578    696    887   1148   1533   2837
 0.020000     170    188    207    230    262    305    373    476    664   1097
 0.015000     116    125    137    151    167    189    227    290    400    616
 0.010000      72     77     82     90     99    113    129    158    195    283
 0.007000      50     53     57     61     67     74     84    100    123    177
 0.005000      36     38     41     44     48     53     60     69     83    117
 0.003000      24     26     27     29     31     34     37     44     53     69
 0.002000      18     19     20     22     23     25     28     31     37     48
 0.001500      15     16     17     18     19     20     22     25     30     39
 0.001000      12     13     13     14     15     16     17     19     22     29
```

> Going down the list to the row next to a cluster-forming threshold of p=0.001, we see that we would need a cluster size of 16 or greater in order to determine that the cluster is significant at the p=0.05 threshold.

## 3dMEMA

1. 将程序名从`3dttest++`改成`3dMEMA`
2. 使用的应该是`3dREMLfit`输出的结果，即`stats.sub-08_REML+tlrc`
3. `t-stat index/label (MEMA)`选择`stats.sub-08_REML+tlrc`中对应的t检验的sub-brick

## ROI分析

全脑分析又叫探索性分析；ROI分析又叫确认性分析

全脑分析或许会发现incongruent-congruent在某些脑区上有中重要影响，但是这种影响是incongruent大于congruent导致的，还是congruent小于incongruent导致的，又或者是两者相结合导致的，就需要ROI分析

---

选择ROI区域写成mask的一种方法

![../../_images/08_DrawDataSetWindow.png](https://andysbrainbook.readthedocs.io/en/latest/_images/08_DrawDataSetWindow.png)

![../../_images/08_AtlasMask.png](https://andysbrainbook.readthedocs.io/en/latest/_images/08_AtlasMask.png)

需要注意的是，statistics dataset的分辨率应该和afni模板的分辨率相同（MNI_avg152T1+tlrc模板的分辨率是2x2x2mm），最后生成ROI mask的分辨率也是2x2x2mm

可以使用`3dresample`命令来匹配mask数据集和statistics数据集的分辨率：

```bash
3dresample -master stats.sub-01+tlrc -input midACC+tlrc -prefix midACC_rs+tlrc  # rs表示re-sampled，重新采样分辨率
```

这条命令需要一个主数据集（master）和一个输入数据集（input），并将input的分辨率更改成master的分辨率

---

分别提取incongruent和congruent的β值，然后再比较这两者。只有这样，才能知道incongruent-congruent效应是由于incongruent更大还是congruent更小还是两者都有造成的

使用下面脚本，注意congruent条件的coef是sub-brick "#1，而incongruent的coef是sub-brick" "#4："

```bash
#!/bin/bash

for subj in `cat subjList.txt`; do

        3dbucket -aglueto Congruent_betas+tlrc.HEAD ${subj}/${subj}.results/stats.${subj}+tlrc'[1]'
        3dbucket -aglueto Congruent_betas+tlrc.HEAD ${subj}/${subj}.results/stats.${subj}+tlrc'[4]'

done
```

得到两个名为Congruent_betas+tlrc.和Congruent_betas+tlrc.的文件，每个被试都只有一个sub-brick，即提取出来的coef值，这两个文件包含了所有被试对应的的coef值

然后可以提取它们的β值，例如

```bash
3dmaskave -quiet -mask midACC_rs+tlrc Congruent_betas+tlrc  # 会将mask里的所有体素的β值提出来并求一个平均
# 后面可以跟 >> name.txt，将所有值写入一个txt文本中
```

---

创建球形ROI：

```bash
#!/bin/bash

# This script creates a 5mm sphere around a coordinate
# Change the x,y,z, coordinates on the left side to select a different peak
# Radius size can be changed with the -srad option

echo "0 20 44" | 3dUndump -orient LPI -srad 5 -master Incongruent_betas+tlrc -prefix ConflictROI+tlrc -xyz -
# -srad后跟球形半径，-master将创建与主数据集具有相同分辨率和体素大小的mask数据集。-xyz后面的“-”表示|左边的 参数 将会输出到这来
```

> afni默认的方向是RAI，但是文献中报道的坐标大都是LPI；所以需要`-orient`选项定义好坐标


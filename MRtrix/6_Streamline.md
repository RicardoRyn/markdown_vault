有了灰质和白质的边界图，接下来就可以**streamline分析**了，即画出steamline图（连接灰质上的不同脑区的线）

这些并不是人脑中真正存在的纤维束，而是对可能存在的纤维束的估计，在MRtrix中使用概率的**（probabilistic）**方法来实现

会在**灰质白质边界图**上的**每个voxel**都生成streamlines，然后剔除那些不需要的streamline，保留需要的streamline

# 结构像约束纤维束成像

**Anatomically Constrained Tractograph, ACT**

ACT不是一个独立的预处理部分，而是一个可以包含的选项，键入`tckgen`命令查看详情介绍（我猜是track generation的意思）

这是MRtirx特色之一，能够保留那些生物学上合理的streamline，例如有些终端在CSF里的streamline就需要排除

因为streamline起于灰质，往往也终于灰质，所以streamline只在白质中呈现

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/07_ACT_With_Without.png" alt="../../_images/07_ACT_With_Without.png" style="zoom:33%;" />

# 使用tckgen命令生成streamline图

MRtrix既可以做确定性**（deterministic）**纤维束成像，也可以做概率性**（probabilistic）**纤维束成像

**确定性纤维束成像**中，每个voxel处的streamline方向根据**主要纤维束方向（predominant fiber orientation）**而确定。也就是说每个voxel的streamline只由一个参数确定，MRtirx可以用多个选项来做，比如`FACT`或者`tensor_det`

**概率性纤维束成像**是MRtrix中默认的方法，每个voxel处的streamline方向也往往根据**主要纤维束方向（predominant fiber orientation）**来呈现，但是不总是这样；由于sample很多，也有一些streamline沿着其他方向，所以最后要看FOD，如果FOD在某一方向上很强，这种情况就不会发生

概率性纤维束成像的默认算法是**iFOD2**，其他算法参见 [this site](https://mrtrix.readthedocs.io/en/latest/reference/commands/tckgen.html)。本例中使用默认的iFOD2

# 生成多少streamline？

streamline越多，重建的白质束就越精确，所需时间就越多**（可能相当的长，a prohibitively long time）**，需要自己权衡

合适的数量学界还在讨论中，但至少要**1000万**以上，键入：

```bash
tckgen -act 5tt_coreg.mif -backtrack \
       -seed_gmwmi gmwmSeed_coreg.mif \
       -nthreads 8 -maxlength 250 -cutoff 0.06 -select 10000000 \
       wmfod_norm.mif \
       tracks_10M.tck
```

> `-act`选项后跟结构-分割图像（即配准了的、分割好的、T1像）
>
> `-backtrack`选项表示如果当前streamline在奇怪的位置终止（例如CSF），则当前streamline返回并再跑一遍
>
> `-seed_gmwmi`选项表示灰质白质边界文件（之前用`5tt2gmwmi`命令生成的，**由结构像生成的**）
>
> `-nthreads`指定需要多少核来跑数据，值越大越快（应该指的是逻辑核，一般都是8）
>
> `-maxlength`选项表示使用的最大的纤维束长度**（in voxel）**；默认是`100 × voxelsize`
>
> `-cutoff`选项指定了streamline的FOD，例如0.06表示streamline沿着的FOD不能低于0.06
>
> `-select`选项说明最后生成1000万条streamline；可以用速记，比如写成`10000k`
>
> 最后两个文件，`wmfod_norm.mif`表示输入**（由弥散像生成的）**，`tracks_10M.tck`表示输出（`10M`表示10 million）

如果想要可视化结果，作者建议使用更少的tracks，键入：

```bash
tckedit tracks_10M.tck -number 200k smallerTracks_200k.tck
```

查看文件键入：

```bash
mrview sub-02_den_preproc_unbiased.mif -tractography.load smallerTracks_200k.tck
```

> 我曾经直接使用1000万的streamline，直接未响应

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/07_Sifted_Streamlines.png" alt="../../_images/07_Sifted_Streamlines.png" style="zoom:50%;" />

检查图形，确保streamline没有终止在奇奇怪怪的地方

# 使用tcksift2优化streamlines

上面创建出的图被称为束图（tractogram），仍有一些问题，比如有些白质被过拟合（over-fitted），有些白质又欠拟合（under-fitted）。有些地方FOD更强，是因为它们都倾向于同一个方向，但是显示在图上给人感觉是纤维束数量更多，这是不对的

以上问题可以通过`tcksift2`命令解决。原理就是该命令会创建一个文本文件，其中包括每个大脑体素的权重，键入：

```bash
tcksift2 -act 5tt_coreg.mif \
         -out_mu sift_mu.txt \
         -out_coeffs sift_coeffs.txt \
         -nthreads 8 \
         tracks_10M.tck \
         wmfod_norm.mif \
         sift_1M.txt
```

> 这个命令的输出`sift_1M.txt`，能够用于`tck2connectome`命令，来创建一个矩阵，表明每个ROI能够多大程度的与其他ROI连接，即**connectome**，所以获得每个ROI的权重


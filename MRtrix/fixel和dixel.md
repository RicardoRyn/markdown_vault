# “Fixel”和“Dixel”

MRtrix作者创建了几个新的术语——fixel和dixel

**pixel**是**图像元素（picture element）**的缩写；**voxel**是**体积元素（volume element）**的缩写

类似的，在dMRI中，我们也需要一种**图像体积基本元素（image volume element）**，来描述**方向信息（orientation information）**——**fixel/dixel**

# 'Fixel': Fibre bundle element

fixel指的是**特定体素（specific voxel）**中的**特定纤维束（specific fibre bundle）**

> 是不是意味一个体素（voxel）中会有多个纤维束（fibre bundle）？

所以fixel可以理解成纤维束（fibre bundle）中最小的离散成分（smallest discrete component）

fixel是其所在的voxel的参数化表示，用来估计该voxel中fibre的平均方向（mean orientation），最终贡献于整个bundle、fibre density（or partial volume fraction）

在过去，MRtrix组习惯于处理FODs（这是一个球面上的连续函数），而不是处理离散的voxel里的纤维方向（fibre directions）。如果任意分割FODs，分割出来的任意的离散的部分FOD的特征都可以被标记为fixel，因为每一个都代表在方向空间（orientation space）中形成了一个连续的束（coherent bundle）

随着有关fixel的统计方法的文献的出版，我们可以推断群体差异，而不仅仅是在体素水平上。也就是说：如果一个交叉纤维体素（crossing-fibre voxel）中只有一个纤维束（fibre bundle）受到影响，我们既能够确定是哪个纤维束（fibre bundle）受到影响，又能比较组水平上这个纤维束效应是否显著

# 'Dixel': Directional Element

dixel一般只在内部人员交流中使用，大部分情况下，可以与fixel混用

想象一个单体素图像，里面的数据实际上是一个球上函数（既有各种各样的方向），假如我们对其中一组方向进行采样， 得到的样本就被叫做一组dixel（即指定voxel中的方向元素）

dixel就是指其所在voxel的，沿着相关球形函数（spherical function）采样得到的方向，以及方向对应的强度（intensity）。dixel描述了**voxel位置**和**采样方向**的组合

如果对球形函数进行不同方向上的采样，就会得到不同值的dixel；同样的，如果是对不同voxel的相同方向进行采样，得到的也是具有不同值的dixel

一般来说：

- dixel习惯于表征沿着某个球形函数特定方向采样的结果，其中该方向属于稠密的基方向（就是大部分都指向这个方向）
- fixel用于描述一个voxel内有一组纤维，这些纤维在方向上十分相似，彼此难于区分，用来表征一个纤维”束“

`mrview`里的”ODF overlay“工具能够加载”Dixel ODFs“。可以用来显示球形上的基方向（direction-based samples on the sphere）；也可以用来可视化指定b-value shell的弥散信号。因为它们都是是球面上的一组方向，每个方向都有**强度/振幅（ ‘intensity’ / ‘amplitude’）**

在AFD（）中，统计分析就可以是一个voxel上的200个方向进行t检验，然后在位置和方向空间（position & orientation space）上检测连接簇（connected clusters）

在FOD分割方法中，使用`fod2fixel`命令，这个算法会从1281个方向对FOD进行采样。相当于从SH（球谐）表征到FOD，再到dixel，最后到fixel表征

# Fixel 图像（文件夹）格式

用于表示离散多纤维模型的图像（Images for representing discrete multi-fibre models）本质上是稀疏（sparse）的。不同的voxel可能有不同数量的纤维数（fibre populations），不同的模型的每个fixel还能有不同的参数要求，例如方向（orientation）、体积分数（volume fraction）、旋转角度（fanning angle）、张量（tensors）

fixel图像格式克服了传统存储4D图像方面的几个问题

这种新颖的格式考虑了以下要求：

1. 不同的voxel可能有不同数量的fixel，所以用4维图像方式存储效用很低，这样必须要向有着最多fixel的voxel看齐。所以硬盘上的稀疏表示效用更高
2. 易读，易写
3. 足够灵活，允许各种指定各种参数的模型，例如体积分数（volume fraction）、铺展?（fanning）等
4. 等等

将fixel格式数据存储在单个文件夹下，而不是单个文件，这样每个文件夹就相当于一个数据集（dataset）

该文件夹下的所有文件都是**NIfTI-2 format格式**或者**MRtrix图像格式**的，方便兼容其他软件

<img src="https://mrtrix.readthedocs.io/en/latest/_images/fixel_format.png" alt="../_images/fixel_format.png" style="zoom:25%;" />

# Fixel格式文件类型

## Index文件

4D图像（i x j x k x 2）

- 第4维度上的第1个3D volume储存每个voxel元素数量（the number of elements），即fixels的数量
- 第4维度上的第2个3D volume储存每个voxel第1个fixel的下标（index），剩下的fixel的index以此类推

index文件是必须要有的（`index.nii`或者`index.mif`）

## Fixel数据文件

3D图像（n x p x 1）

- n是整个图像的元素数量，即fixel的数量；p是每个元素参数的数量，例如方向p=3，体积分数p=1，张量p=6（见上图右下）

每个voxel的fixel的数据的存储必须遵守index

数据文件的类型很容易识别，因为第3维度固定为1

一个文件夹下可以保存任意多的数据文件

- 方向
- 体积分数
- 旋转角度（fanning angle）
- 张量（tensor）

除了方向数据文件（`direction.nii`或者`direction.mif`），其他数据文件都可以任意命名

> 因为全脑的fixel数目很大，一般大于10,0000，所以不能用NIfTI-1格式文件，因为它限制任意维度不能超过6,5535

## Fixel方向文件

所有基于fixel的模型（fixel-based DWI models）必须指定每个fixel的方向

必须命名为`direction.nii`或者`direction.mif`

可以看成是特殊fixel数据文件，3D（n x 3 x 1）

必须针对扫描仪坐标框架（scanner coordinate frame）来指定方向，笛卡尔坐标（cartesian coordinates）

# Fixel文件的使用

命令行中，如果需要使用Fixel文件，要么直接输入Fixel文件夹下指定文件，要么输入整个文件夹的路径

1. 文件夹的路径

   ```bash
   fod2fixel patient01/fod.mif patient01/fixel_directory -afd afd.mif -disp dispersion.mif
   ```

   > 通过FOD生成Fixel
   >
   > 输入为：`patient01/fod.mif`
   >
   > 输出为：`patient01/fixel_directory`；并在该文件夹下添加`afd.mif`和`dispersion.mif`文件（当然一定会有默认的`index.mif`和`direction.mif`）

2. 指定fixel文件
   ```bash
   fixel2voxel patient01/fixel_directory/afd.mif sum patient01/total_afd.mif
   ```

   > 计算每个体素的总表观纤维分布
   >
   > 输入为：`patient01/fixel_directory/afd.mif`
   >
   > 输出为：`patient01/total_afd.mif`

   ```bash
   mrthreshold patient01/fixel_directory/afd.mif -abs 0.1 patient01/fixel_directory/afd_mask.mif
   ```

   > 卡掉afd绝对值小于0.1的fixel
   >
   > 输入为：`patient01/fixel_directory/afd.mif`
   >
   > 输出为：`patient01/fixel_directory/afd_mask.mif`

   ```bash
   mrstats -output mean -mask patient01/fixel_directory/afd_mask.mif patient01/fixel_directory/dispersion.mif
   ```

   > 计算所有mask中所有fixel的平均分散（mean dispersion）
   >
   > 输入为：`patient01/fixel_directory/afd_mask.mif`和`patient01/fixel_directory/dispersion.mif`
   >
   > 终端会输出一个值（例如：1.00785）

# 在mrview中看fixel数据

首先用mrview打开underlay（例如`t1.mif`）

然后在`tool`中选择`Fixel plot`，最终都会将`index.mif`文件置于overlay，但是会用不同的文件来进行着色，例如用`direction.mif`、`afd.mif`、`dispersion.mif`上色
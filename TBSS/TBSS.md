# 1

创建文件夹`mytbss`，后面所有命令行都是在该路径下直接进行

```bash
mkdir mytbss
ls
  CON_N00300_dti_data_FA.nii.gz
  CON_N00302_dti_data_FA.nii.gz
  CON_N00499_dti_data_FA.nii.gz
  PAT_N00373_dti_data_FA.nii.gz
  PAT_N00422_dti_data_FA.nii.gz
  PAT_N03600_dti_data_FA.nii.gz
```

在这个例子中，有3个对照被试，3个病患被试

这些FA图像都是在个体空间上的，可以来自于FSL生成的`dti_FA.nii.gz`文件，也可以是MRtrix3生成的`FA.mif`文件（但是需要`mrconvet`成`.nii.gz`格式）

直接在该目录下运行：

```bash
tbss_1_preproc *.nii.gz
```

## 生成文件

最后会生成2个文件夹`FA`和`origdata`

在`FA`文件夹中，又有`slicesdir`文件夹，里面放了一堆.png格式的图片，用于快速判断这些FA文件是否质量过差。

此外，对于每个被试，生成了2个文件：

1. `*_FA.nii.gz`文件，就是后续用于处理的FA文件，
2. `*_FA_mask.nii.gz`，及根据FA文件得到的全脑零一mask文件。



# 2. 

这一步只是生成非线性配准需要的中间文件，并没有最终的配准完成的FA文件。

`tbss_2_reg`有3个选项：

1. `-T`：使用`FMRIB58_FA_1mm`作为target文件，然后把每个被试的FA文件配准上去（macaque肯定不能用这个）。会强行配准到 1x1x1mm 的标准空间，据说这样更有利于TBSS；
2. `-t <target>`：手动提供一个文件，然后FSL的非线性配准会将每个被试的FA文件配准上去；
3. `-n`：从当前所有被试中找到一个文件作为target文件，然后把每个被试FA文件配准上去（原则是计算average amount of warping，找到最小的那个被试的FA文件，然后以此为target文件。如果你合起来有6个被试，就要配准6x6次，以寻找最佳配准方案，所以相比与前2个选项，更花时间）。如果在猴子上使用这个参数，最后生成的结果稀烂

## 生成文件

首先在`FA`文件夹中生成`tbss_logs`文件夹，里面的文件都是空文件，不懂什么意思。

如果使用了`-T`选项，会生成一个`target.nii.gz`的FA文件，应该就是`FMRIB58_FA_1mm`。

然后对于每个被试，又生成了4个文件：

1. `*_FA_to_target.log`，记录了一些FSL非线性配准中的信息；
2. `*_FA_to_target.mat`，应该是FSL非线性配准用到的 线性配准矩阵；
3. `*_FA_to_target_warp.nii.gz`，应该是FSL非线性配准用到的 非线性配准矩阵（这个文件具有很奇怪的分辨率，接近1x1x1，但是又不是，而是各种小数）；
4. `*_FA_to_target_warp.msf`，应该也是FSL配准过程中需要的文件，但不知道是什么。

如果使用了`-n`选项，会把每个被试配准到另外一个被试上面，每配准一次就会生成上面4个文件。



# 3. 

不管怎么样，`tbss_3_postreg`都会将文件配准到1x1x1mm 的标准MNI空间上，所以导致在afni中看图像会非常小，如果要改，可能需要去动源代码

`tbss_3_postreg`有2个选项：

1. `-S`：生成`mean_FA`以及`mean_FA_skeleton`文件，根据所有被试来生成（根据`tbss_2_reg -n`中生成的各种非线性配准文件来寻找最佳target文件）；
2. `-T`：使用`FMRIB58_FA`作为模板。

## 生成文件

会将每个被试的FA文件，配准到target上，生成一个`*_to_target.nii.gz`文件。

如果在`tbss_2_reg`中使用的是`-n`选项，则会新生成`target.nii.gz`文件。

并生成一些`.msf`文件，这些文件可能记录了哪个被试被选为target文件。

还生成了一写转换过程文件。

在`mytbss`下，生成了`stats`文件夹，包括：

1. `all_FA.nii.gz`，一个4维文件，最后一维表示所有被试；
2. `mean_FA.nii.gz`，将所有被试FA平均之后的文件；
3. `mean_FA_mask.nii.gz`，根据平均FA得到的全脑mask文件；
4. `mean_FA_skeleton.nii.gz`，一个骨架mask，根据平均FA文件，计算出的骨架文件，每个值表示该voxel的平均FA。



# 4.

`tbss_4_prestats 0.2`，根据设定的阈值，

## 生成文件

`stats`文件夹中：

1. `mean_FA_skeleton_mask.nii.gz`文件，根据所设置的阈值，生成骨架的零一mask文件。
2. `thresh.txt`文件，记录了设置的阈值。
3. `mean_FA_skeleton_mask_dst.nii.gz`，应该是一个“distance map”，应该是用于记录其他voxel到骨架有多远，值越大，越远。
4. `all_FA_skeletonised.nii.gz`，一个4维文件，最后一维是被试数量。



# 5.

```bash
cd stats
design_ttest2 design 3 3  # 自动生成相关的 设计矩阵（design.mat）和对比矩阵（design.con）

randomise -i all_FA_skeletonised.nii.gz -o rm_rjx_tbss -m mean_FA_skeleton_mask.nii.gz -d design.mat -t design.con -n 500 --T2

```




# FSL实用命令

```bash
imglob *_FA.*  # 显示所有.nii/.nii.gz结尾的文件的名字(不包括“.nii.gz/.nii”)
fslmerge -t all_FA.nii.gz `imglob *_FA_to_target.*`  # 很容易将一堆.nii.gz文件沿着第四维组合起来
randomise  # 体素水平上的统计，我猜是AFNI里面的FWE思想，或者就是Permutation思想

```


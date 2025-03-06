参考https://fsl.fmrib.ox.ac.uk/fslcourse/2019_Beijing/lectures/FDT/fdt1.html#pipeline网址

# FSL DWI Tools，简称FDT

大致步骤：

1. TOPUP： 校正磁敏感扭曲（ Correct for susceptibility-induced distortions）
2. EDDY：校正涡流扭曲，被试头动（Correct for eddy currents and subject movement）
3. DTIFIT：张量拟合（Tensor fitting）
4. FLIRT and FNIRT：配准到标准空间（Registration to standard space）
5. TBSS and RANDOMISE：假说验证（Hypothesis testing）

查看dwi每个shell的信息会发现b值可能不会是正整数，就像b=500可能会写成b=499，这是因为：转换过程考虑到了成像（即，非弥散编码）梯度的影响

> That is because, when extracting the b-values from DICOM files, the converter takes into account the effects of the imaging (i.e., non-diffusion encoding) gradients.

对于dwi图像，一张slice就能看到的扭曲就是**磁敏感扭曲**，如下图：

<img src="https://fsl.fmrib.ox.ac.uk/fslcourse/2019_Beijing/lectures/FDT/FSL%20Diffusion%20Toolbox%20Practical_files/susceptibility_artefact.png" alt="Susceptibilty induced distortions" style="zoom:25%;" />

在不同全脑间切换看出来的变化就是**涡流扭曲**；因为不同的全脑有不同的弥散梯度，所以导致了不同的全脑图像。

dwi数据在沿着梯度方向的方向上值更低，表现得更暗。

# topup

dwi数据要做topup，必须要2个自旋回波（spin-echo）EPI图像（se_epi），并且它们的PE（phase-encoding，相位编码方向）相反，例如A-P和P-A，L-R和R-L。而且这2个图像必须是一个dwi序列中扫描得到的，期间被试不能离开扫描仪，也不能进行匀场（re-shimming）

首先把正相b0图像和反相b0图像合并到一个图像中，然后创建一个文本文件，记录了PE方向、AP全脑信号、PA全脑信号、一些时间信息，在这个教程中已经有了一个文件`acqparams.txt`，其中包含了

```
0 -1 0 0.0759
0  1 0 0.0759
```

每一行的前3个数字表示方向，

例如第1行的`0 -1 0`表示正相b0图像的PE沿着y轴，-1表示A到P

第2行的`0 1 0`表示反相b0图像的PE沿着y轴，1表示P到A

`0.0759`表示**总读出时间（total readout time）单位s**，表示第一个回波的中心到最后一个回波的中心的间隔

命令`topup`（需要花上一段时间来跑）：

```bash
topup --imain=AP_PA_b0 \  # 输入，正反相合并文件
      --datain=acqparams.txt \  # 输入，PE方向，PE次数
      --config=b02b0.cnf \  # 输入，指定命令行参数
      --out=topup_AP_PA_b0 \  # 输出，输出文件的基础名字，outputs: spline coefficients (Hz) and movement parameters
      --iout=topup_AP_PA_b0_iout \  # 输出，unwarped的图像
      --fout=topup_AP_PA_b0_fout  # 输出，场文件，file with field (Hz)

```

最后结果有4个文件：

`topup_AP_PA_b0_fieldcoef.nii.gz`：包含了非共振场（off-resonance field），看上去是一个低分辨率的场图，还包含了topup估计的场的spline coefficients

`topup_AP_PA_b0_movpar.txt`：指定了`nodif`和`nodif_PA`中的任何头动（movement）

`topup_AP_PA_b0_fout`： 实际的场

`topup_AP_PA_b0_iout`：对比这个文件和输入文件`AP_PA_b0.nii.gz`的2个全脑，可以看出topup有没有好好工作

---

额外内容

命令`applytopup`

```bash
# applytopup can be used to apply the field calculated by topup to one or more different image volumes, thereby correcting the susceptibility distortions in those images. For example, we could use it to inspect how well topup managed to correct our b0 data by running:
# applytopup命令可用于“将 topup 计算的场应用到一个或多个不同的全脑图像”，从而校正这些图像中的磁敏感失真，我们可以用它来检查topup如何校正我们的 b0 数据
applytopup --imain=nodif,nodif_PA \
           --topup=topup_AP_PA_b0 \
           --datain=acqparams.txt \
           --inindex=1,2 \
           --out=hifi_nodif
# This will generate a file named hifi_nodif.nii.gz where both input images have been combined into a single distortion-corrected image.
# 结果会生成一个名为 hifi_nodif.nii.gz 的文件，这个文件就是输入文件结合成的单个校正了失真的图像文件
```

---

后面需要生成校正完的b0图像的大脑mask：

```bash
# 首先计算校正完的b0全脑的平均值，输出文件命名为hifi_nodif
fslmaths topup_AP_PA_b0_iout -Tmean hifi_nodif

# 然后剥头皮
bet hifi_nodif hifi_nodif_brain -m -f 0.2
```

跑`eddy`：

```bash
eddy --imain=dwidata \  # 输入，输入图像列表，包括b0图像，也包括所有正相图像
     --mask=hifi_nodif_brain_mask \  # 输入，mask文件
     --index=index.txt \  # 输入，所有全脑的indices，所有的全脑都是使用acqparams.txt 中第一行指定的参数获取的
     --acqp=acqparams.txt \  # 输入，扫描参数文件
     --bvecs=bvecs \  # 输入
     --bvals=bvals \  # 输入
     --fwhm=0 \  # 输入，平滑参数为0,不做平滑
     --topup=topup_AP_PA_b0 \  # 输入，从topup来的文件，输入名字后会自动查找topup_AP_PA_b0_fieldcoef.nii.gz文件和topup_AP_PA_b0_movpar.txt，所以它们的名字需要对应
     --flm=quadratic \  # 输入，指定为EC 场的二次模型a quadratic model for the EC-fields
     --out=eddy_unwarped_images \  # 输出，输出文件名字
     --data_is_shelled  # 输入，避免自动检查数据是否已使用多 shell 协议获取（因为我们已经知道它是multi-shell的了）
```

最后生成3个文件：

`eddy_unwarped_images.nii.gz`：主要结果，进行完了topup校正、eddy校正、头动校正的结果

`eddy_unwarped_images.rotated_bvecs`

`eddy_unwarped_images.eddy_parameter.`

---

额外内容

```bash
gps --ndir=64 --optws --out=rjx.bvecs
# 将会创建一个名为rjx.bvecs的文件，里面是一个具有最佳扩散方向的文本文件，方向在球体上均匀分布
```



# BEDPOSTX

跑`bedpostx_datacheck`来检查是否有必要的文件

必要的文件：

- **data**: A 4D series of data volumes. This will include diffusion-weighted volumes and volume(s) with no diffusion weighting. 名字就叫`data.nii.gz`
- nodif_brain_mask: 3D binary brain mask volume derived from running [bet](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET) on nodif (i.e. on a volume with no diffusion weighting). 名字就叫`nodif_brain_mask.nii.gz`
- bvecs (**with no file extension**): An ASCII text file containing a list of gradient directions applied during diffusion weighted volumes. 名字就叫`bvecs`
- bvals (**with no file extension**): An ASCII text file containing a list of bvalues applied during each volume acquisition. 名字就叫`bvals`

## 高级选项

- Fibres: Number of fibres modelled per voxel.
- Weight: Multiplicative factor for the prior on the additional modelled fibres. A smaller factor means more weighting for the additional fibres. 其他模拟纤维的先验乘性因子。较小的系数意味着额外纤维的权重更大
- Burnin: Number of iterations before starting the sampling. These might be increased if the data are noisy, and the MCMC needs more iterations to converge. 开始采样之前的迭代次数。如果数据有噪声，这些可能会增加，MCMC需要更多迭代才能收敛

Additionally, the following alternative models are available in the advanced options:

- Single-Shell Model : Use this option if the data contains only a single non-zero bvalue. This will revert the model to use the one described in [Behrens et al, NeuroImage 2007](http://www.ncbi.nlm.nih.gov/pubmed/17070705) rather than in [Jbabdi et al. MRM 2012](http://www.ncbi.nlm.nih.gov/pubmed/22334356) (i.e., the the diffusion coefficient is modelled as a single value rather than using a Gamma distribution). Command line argument: `--model=1`. 如果数据仅包含一个非零B值，请使用此选项。即，扩散系数建模为单个值，而不是使用伽马分布
- Model Noise Floor : Use this option if (part of) the data is operating close to the noise floor. This will fit one extra parameter f0 that captures the noise floor. This is also described in [Jbabdi et al. MRM 2012](http://www.ncbi.nlm.nih.gov/pubmed/22334356). This option will output the posterior mean of the noise floor parameter `mean_f0samples`. Command line argument: `--f0 --ardf0`. 如果（部分）数据在噪声基底附近运行，请使用此选项。这将适合捕获噪声基底的一个额外参数f0。此选项将输出噪波基底参数`mean_f0samples`的后验平均值
- Rician Noise : Use this option to replace the default Gaussian noise assumption with Rician noise. This will output the posterior mean of a noise precision (i.e. inverse of variance) parameter `mean_tausamples`. Command line argument: `--rician`. 使用此选项将默认的高斯噪声假设替换为Rician噪声。这将输出噪声精度（即方差倒数）参数`mean_tausamples`的后验平均值

##  命令行

```bash
Usage: bedpostx <subject directory> [options]

 expects to find bvals and bvecs in subject directory
 expects to find data and nodif_brain_mask in subject directory
 expects to find grad_dev in subject directory, if -g is set

 options (old syntax)
  -n (number of fibres per voxel, default 3)
  -w (ARD weight, more weight means less secondary fibres per voxel, default 1)
  -b (burnin period, default 1000)
  -j (number of jumps, default 1250)
  -s (sample every, default 25)
  -model (Deconvolution model. 1: with sticks, 2: with sticks with a range of diffusivities (default), 3: with zeppelins)
  -g (consider gradient nonlinearities, default off)

 ALTERNATIVELY: you can pass on xfibres options directly to bedpostx
  For example:  bedpostx <subject directory> --noard --cnonlinear
  Type 'xfibres --help' for a list of available options
  Default options will be bedpostx default (see above), and not xfibres default.

 Note: Use EITHER old OR new syntax.
```

## 输出文件

`<i>`表示第i个fibre，可以在`Adcanced Option`里面设置，默认是3

``` bash
# merged开头的文件
# θ和φ共同代表球面极坐标中的主要扩散方向
merged_th<i>samples - 4D volume θ上分布的样本
merged_ph<i>samples - 4D volume - φ分布中的样本
merged_f<i>samples - 4D volume - 各向异性体积分数（FA）分布的样本

# mean开头的文件
mean_th<i>samples - 3D Volume - θ上的分布平均值
mean_ph<i>samples - 3D Volume - φ上的分布平均值
mean_f<i>samples - 3D Volume - 各向异性（FA）分布平均值  # 每个体素中，fibre按照平均FA值递减排序
mean_dsamples - 3D Volume - 扩散率分布平均值d
mean_d_stdsamples - 3D Volume - 扩散率方差参数（d_std）的分布平均值 (--model=1下没有这个文件)
mean_S0samples - 3D Volume - T2w baseline信号强度S0的分布平均值

# dyads开头的文件
dyads<i> - 矢量形式PDD分布的平均值。请注意，此文件可以加载到FSLeyes中，以便于查看扩散方向
dyads<i>_dispersion - 3D Volume - 估计纤维方向的不确定性。描述各个PDD周围方向分布的宽度
nodif_brain_mask - 由nodif_brain创建的二进制mask文件（nodif就是b=0的意思）
```

# 用FDT配准

如果想要概率纤维束成像结果在 弥散空间 以外的空间里，就需要配准

可以用FLIRT的线性配准，或者FNIRT的非线性配准

在GUI里只能先bedpostX，然后再配准，但是在命令行里可以换顺序

- 弥散像空间：使用bedpostX文件夹里的`nodif_brain`图像
-  结构像空间：
- 标准空间：

# PROBTRACKX

键入`Fdt`打开GUI（mac则用`fdt_gui`）

GUI只能运行probtrackx2，probtrackx只能通过命令行来运行

```bash
probtrackx2_gpu 
	-x ./lh_MST.nii.gz \  # seed区
	-l \  # loopcheck，应该是防止从seed播种又回到seed的这种path出现；更慢，但是允许较低的弯曲阈值
	--onewaycondition \  # Apply waypoint conditions to each half tract separately
	-c 0.2 \  # 弯曲阈值，默认0.2
	-S 2000 \  # 每一次sample的step的数量，默认2000
	--steplength=0.5 \  # 默认0.5mm
	-P 5000 \  # sample的数量，默认5000
	--fibthresh=0.01 \  # Volume fraction before subsidary fibre orientations are considered - default=0.01
	--distthresh=0.0 \  # sample长度低于这个长度mm的会被舍弃
	--sampvox=0.0 \  # 从seed体素的中心算x mm的半径，在这个球中随机sample，默认半径为0mm
	--waypoints=./lh_PG.nii.gz \
	--avoid=./right_mask.nii.gz \
	--forcedir \  # 使用实际给定的文件夹名字，不会创建新的文件夹
	--opd \  # 默认有，生成path的分布
	-s ./orig.bedpostX/merged \
	-m ./orig.bedpostX/nodif_brain_mask \
	--dir=./probtrackx_lh_MST
```

```bash
probtrackx2 -x ./lh_V1.nii.gz 				\
	-l 										\
	--onewaycondition 						\
	--omatrix1 								\  # 生成矩阵1
	--omatrix2 								\  # 生成矩阵2
	--target2=./lh_MST.nii.gz 				\
	-c 0.2 									\
	-S 2000 								\
	--steplength=0.5 						\
	-P 5000 								\
	--fibthresh=0.01 						\
	--distthresh=0.0 						\
	--sampvox=0.0 							\
	--avoid=./right_mask.nii.gz 			\
	--forcedir 								\
	--opd 									\
	-s ./orig.bedpostX/merged 				\
	-m ./orig.bedpostX/nodif_brain_mask 	\
	--dir=./rm_rjx_2 						\
	--targetmasks=./rm_rjx_2/targets.txt 	\  # targets mask list（事先生成）
	--os2t 
```

`probtrackx2 --help`

必要bedpostX文件夹，里面包括：

- `merged_th<i>samples`
- `merged_ph<i>samples`
- `merged_f<i>samples`
- `nodif_brain_mask`

# 概率纤维束成像引导

绝大部分文件，都需要在一个space下，如果用的surface文件，也要有相同约束（convention）

## Seed specification

3种指定种子区方式：

1. 单个体素

   命令行中需要提供带有坐标信息的text文件（`-x,--seed`和`--simple`）

2. 单个mask

   可以是volumetric文件（例如NIFTI格式），或者surface文件。命令行中通过传递相应文件给`-x,--seed ` flag

3. 多个mask

   可以用于从volumetric和surface生成streamlines或者用于生成ROI×ROI连接矩阵

   mask需要位于同一空间，surface需要使用相同编码（encoding）

如果种子区是单个体素或者surface，就需要一个参考图像（`--seedref`）

从每个体素画的streamline数量默认是5000（可以通过`-P/--nsamples`修改）

streamline默认从体素的中心初始化，可以设置成体素中心周围的位置（`--sampvox`）

## Waypoint mask

如果设置了waypoing mask，只有通过这个mask的streamline才会被计数，并保存到probtrackX的各种输出中（`--waypoint`）

如果添加多个waypoint mask，默认必须要全部通过的streamline才视为有效（AND），可以通过`--waycond`改成OR

多个waypoint mask可传输对应文件名列表的ASCII file给`--waypoints`

`--wayorder`可以严格要求通过waypoint的顺序，需要传递text file，只能在AND情况下使用

## Exclusion mask

`--avoid`

## Termination mask

`--stop`一旦到达termination mask，就结束

termination和exclusion的差别在于，碰到termination mask的streamline视为有效，但是碰到exclusion mask的streamline视为无效

`--wtstop`完全离开termination mask，才算结束

## 一些termination和exclusion的原则

1. 设置了termination或者exclusion mask
2. The streamline leaves the `nodif_brain_mask` in the input `bedpostX` directory.
3. 走了2000 steps，默认是2000 steps，一个step是0.5mm。2000可以通过`-S,--nsteps`来更改
4. streamline不能弯得太厉害（弯曲角度），`-c,--cthr`
5. 兜兜转转又回到自己的位置（不合理，该删），`-l,--loopcheck`
6. FA可以影响概率性纤维束成像的结果（`merged_f<i>samples`的文件中），`-f,--usef`，如果各向异性太低，就会停止追踪
7. 根据streamline的长度来筛选，`-disttrhresh`

## mask也可以不在弥散空间

默认情况下，probtrackX的结果是弥散空间，但是各种mask也可以不在弥散空间，`--xfm,--invxfm`

例如，在结构空间中分析：

- Linear: `xfms/str2diff.mat`
- Nonlinear: `xfms/str2diff_warp and xfms/diff2str_warp`

# 调整streamline路径

- 使用修改的Euler流线（`--modeuler`）：使用改进的Euler积分计算streamline，更精确，更慢
- 步长（`-S,--nsteps`; default 0.5mm）：在婴儿和动物上，可以适当调整
- 纤维体积分数阈值（`--fibthresh`; default=0.01）：辅助纤维体积分数的阈值。体积分数低于该阈值的纤维（`mean_f<i>samples`，区别于`merged_f<i>samples`）在纤维束描记过程中被丢弃

# ProbtrackX的输出文件

1. `probtrackx.log`文件：记录所使用的命令
2. `fdt.log`文件：保存使用的FDT GUI，可以通过命令`Fdt fdt.log`恢复成生成该文件的GUI
3. `waytotal`文件：保存了streamline信息

所有的probtrackX的输出文件都以某种方式记录了streamline的数量，`--pd`校正了离seed mask越远连接分布下降的问题；如果这个选项被选择（checked）了，连接分布，就是预期路径长度乘以每个穿过每个体素的样本数

除了计算streamline的数量，通过`--ompl`，可以设置以下输出：

## Streamline density map

如果使用GUI跑的，这是默认输出之一，`--opd`

结果是一个3D文件`fdt_paths`，这个文件可以被认为是量化了的seed区的连接性（connectivity）

XTRACK就是利用probtrackX和一组仔细设计过的mask重新构建了主要的白质纤维束

## ROI和ROI之间的连接矩阵

结果文件为`fdt_network_matrix`

命令行依旧需要添加`--network`来生成 N×N 的矩阵

如果那些两端没有同时连在某个ROI上的streamline就不会被计数

## voxel和ROI之间的连接矩阵

计算指定seed区里的每个voxel，与指定ROI之间的连接强度

指定一个text file，里面列出了ROI（包括路径），传递给`--targetmasks`或者`--os2t`

输出的结果文件夹中包含了每个ROI（即设定了几个ROI就有几个文件），名字是`seeds_to_{target}`，target对应了相关的target mask，每个文件是一个图像，在指定的seed区有值，其他地方的值是0，这个值代表了这个voxel与这个ROI之间的streamline的数量

有一些命令可以对这些输出文件进行操作：

```bash
proj_thresh -  # 为一些输出卡个阈值
find_the_bigggest -  # 为输出的结果执行硬分类（hard segmentation），如下图
```

![quantitative targets](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide?action=AttachFile&do=get&target=fdt_seeds2targets_thal.gif)

## voxel和voxel之间的结构连接

`--matrix1/2/3`，键入`probtrackx2 --help`查看更多内容

1. 所有的seed point与其他seed point之间的连接
2. 所有的seed point与其他target mask里的point之间的连接
3. 一个target mask（或者target mask对）里的所有所有point对之间的连接

Matrix1和Matrix2用来储存samples的数量，Matrix3用来储存taget masks之间每一points对之间的samples数量，见下图

matlab里可以查看：

```matlab
x=load('fdt_matrix1.dot');
M=spconvert(x);
```



![MatrixOptions.png](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide?action=AttachFile&do=get&target=MatrixOptions.png)

典型的矩阵输出：

- Matrix1：seed mask表征灰质，所以可以是所有GM和GM的连接
- Matrix2：seed可以是lh_MST，mask2是剩下的脑区（就是指除了lh_MST之外的灰质，这个可以有更低的分辨率，上采样到5mm），这个结果后面可以用于分类
- Matrix3：target mask可以是整个GM，这个选项可以更敏感地重建gray-to-gray之间的连接，因为路径是从所有maks位置seed，而不是像Matrix1里的仅仅从end-point中seed

### 用Matrix2进行聚类

Matrix2可以用来盲分类（ blind (i.e. hypothesis-free) classification），在跑porbtrackx的时候用了`--omatrix2`选项，设置了target mask到全脑brain mask（一般这个mask的分辨率 都要低于seed mask），这个Matrix2的结果可以放到matlab里执行“kmeans”分类

```matlab
% Load Matrix2
x=load('fdt_matrix2.dot');  % 加载一个包含了“稀疏矩阵”信息的文件
M=full(spconvert(x));  % “spconvert“用来将x转换成“稀疏矩阵sp（sparse double格式的）”，”full“用来将稀疏矩阵转换成满储存格式

% Calculate cross-correlation
CC  = 1+corrcoef(M');  % 因为matlab里的“corrcoef”是列与列之间做相关，所以需要把M先转置一下；相关系数可能是负数，所以需要加上1，确保所有的值都是正数。

% Do kmeans with k clusters
idx = kmeans(CC,k);   % k is the number of clusters

% Load coordinate information to save results
addpath([getenv('FSLDIR') '/etc/matlab']);
[mask,~,scales] = read_avw('fdt_paths');
mask = 0*mask;
coord = load('coords_for_fdt_matrix2')+1;
ind   = sub2ind(size(mask),coord(:,1),coord(:,2),coord(:,3));
[~,~,j] = unique(idx);
mask(ind) = j;
save_avw(mask,'clusters','i',scales);
!fslcpgeom fdt_paths clusters  # 最后会在当前文件夹下生成名为cluster.nii.gz的文件
```

# 使用surface文件

probtrackx里可以使用surface文件，需要是GIFTI格式（`.gii`）

surface文件一般都用mm为单位描述vertex，**但是不同的软件，使用不同的协议（convention），将mm转化成体素坐标**

probtrackx使用以下协议：

- freesurfer
- caret
- first
- voxel（这个可以简单理解成mm和voxel坐标是一样的）

在probtrackx里，所有的surface文件都需要使用相同的协议（convention）

fsl也提供了`surf2surf`命令来转化不同的协议

```bash
surf2surf - conversions between surface formats and/or conventions

Usage:
Usage: surf2surf -i <inputSurface> -o <outputSurface> [options]

Compulsory arguments (You MUST set one or more of):
        -i,--surfin     input surface
        -o,--surfout    output surface

Optional arguments (You may optionally specify one or more of):
        --convin        input convention [default=caret] - only used if output convention is different
        --convout       output convention [default=same as input]
        --volin         input ref volume - Must set this if changing conventions
        --volout        output ref volume [default=same as input]
        --xfm           in-to-out ascii matrix or out-to-in warpfield [default=identity]
        --outputtype    output type: ASCII, VTK, GIFTI_ASCII, GIFTI_BIN, GIFTI_BIN_GZ (default)
```

## 在surface上投射纤维束

有时候经常需要将3D数据投射到皮质surface上展示，fsl提供了`surf_proj`命令行来执行这一操作：

```bash
Usage: surf_proj [options]

Compulsory arguments (You MUST set one or more of):
        --data  data to project onto surface
        --surf  surface file
        --out   output file

Optional arguments (You may optionally specify one or more of):
        --meshref       surface volume ref (default=same as data)
        --xfm   data2surf transform (default=Identity)
        --meshspace     meshspace (default='caret')
        --step  average over step (mm - default=1)
        --direction     if>0 goes towards brain (default=0 ie both directions)
        --operation     what to do with values: 'mean' (default), 'max', 'median', 'last'
        --surfout       output surface file, not ascii matrix (valid only for scalars)
```

## 使用FreeSurfer生成的surface

需要加入以下命令行：

```bash
--meshspace=freesurfer --seedref=orig.nii.gz
```

事先需要用freesurfer的mri_convert命令将`orig.mgz`转换成`orig.nii.gz`

此外还需要一些直指定的步骤：

### FreeSurfer Registration

freesurfer的文件都使用一个一致的空间（称为conformed space），但是这个空间有别于最初接收的结构像的空间，所以在probtrackx中使用FreeSurfer的surface的时候，需要提供conformed sapce和我们概率纤维束成像用的弥散空间之间的转换过程（也就是这2个空间需要配准）

首先假设已经跑了`dtifit`，得到了FA map（`dti_FA.nii.gz`）（建议使用FA map来配准一下T1结构像），然后假设recon-all的输入是`struct.nii.gz`（这个`struct.nii.gz`应该是带头皮的）

接下来就需要得到`fa<===>struct<===>freesurfer`之间的转换，并把中间的2步转换合并，得到`fa<===>freesurfer`的转换，假设被试叫做john，如下：

```bash
tkregister2 --mov $SUBJECTS_DIR/john/mri/orig.mgz --targ $SUBJECTS_DIR/john/mri/rawavg.mgz --regheader --reg junk --fslregout freesurfer2struct.mat --noedit  # 得到了freesurfer到struct的转换freesurfer2struct.mat

convert_xfm -omat struct2freesurfer.mat -inverse freesurfer2struct.mat  # 把矩阵逆一下，就是struct到freesurfer的矩阵struct2freesurfer.mat

flirt -in dti_FA -ref struct_brain -omat fa2struct.mat  # 得到fa到struct的转换，fa2struct.mat
convert_xfm -omat struct2fa.mat -inverse fa2struct.mat  # 把矩阵逆一下，得到struct到fa的转换struct2fa.mat

convert_xfm -omat fa2freesurfer.mat -concat struct2freesurfer.mat fa2struct.mat  # 合并两个矩阵，得到fa到freesurfer的矩阵
convert_xfm -omat freesurfer2fa.mat -inverse fa2freesurfer.mat  # 把矩阵逆一下，得到freesurfer到fa的矩阵


#如果想要逆非线性变换，可以参考“invwarp --ref=my_struct --warp=warps_into_MNI_space --out=warps_into_my_struct_space”
```

### Label文件

为了在probtrackx的surface上使用label文件，首先也需要转化它们，使用`label2surf`命令

假设，想要研究`lh.white`文件的`BA44/45`脑区，需要把对应的label转化成相应的fsl可读的文件格式（ASCII、VTK、GIFTI）然后使用`label2surf`将label文件转换成surface：

```bash
mris_convert lh.white lh.white.gii
echo lh.BA44.label lh.BA45.label > listOfAreas.txt  # 这行代码真的有用吗，这样输入listOfAreas.txt里面只有会“lh.BA44.label lh.BA45.label”吧？有用，需要ASCII编码
label2surf -s lh.white.gii -o lh.BA44.gii -l listOfAreas.txt
```

`label2surf`的全套参数如下：

```bash
label2surf
         Transforms a group of labels into a surface

Usage:
label2surf -s <surface> -o <outputsurface> -l <labels>

Compulsory arguments (You MUST set one or more of):
        -s,--surf       input surface
        -o,--out        output surface
        -l,--labels     ascii list of label files

Optional arguments (You may optionally specify one or more of):
        -v,--verbose    switch on diagnostic messages
        -h,--help       display this message
```

# 其他实用命令

## proj_thresh

提供一种在基于连接性分类中表示连接概率的可选方法

```bash
proj_thresh <list of volumes/surfaces> threshold
```

> <list of volumes/surfaces>是基于连接性分类的输出，即之前提到的`seeds_to_{target}`文件
>
> threshold的值表示sample的数量。对于seed区里的每个voxel，至少有与一个target之间的值高于阈值，
>
> 条命令就是算到达每个target mask高于阈值的sample占整个sample的比例（概率）
>
> 输出：每个指定的target mask都有对应的一个volume文件
>
> Where the list of volumes is the outputs of **Connectivity-based seed classification** (i.e., files named seeds_to_target1 etc etc) and threshold is expressed as a number of samples For each voxel in the seeds mask that has a value above threshold for at least one target mask, `proj_thresh` calculates the number of samples reaching each target mask as a proportion of the total number of samples reaching any target mask. The output of `proj_thresh` is a single volume for each target mask.

## find_the_biggest

 根据与target mask之间的连接概率来分类

```bash
find_the_biggest <list of volumes/surfaces> <output>
```

## vecreg - 向量图像的配准

跑完dtifit或者bedpostX之后，经常需要将向量文件（vector data）配准到另一个空间

例如想要比较被试1、被试2直到被试100的初级视觉皮层（V1）的差异，就需要用`vecreg`来配准不同被试的V1

**向量文件不能通过应用转换矩阵来实现配准每个voxel的坐标**，对应的向量需要进行重定向，`vecreg`就是用来执行重定向的

如下图，左边是原向量文件，右边是重定向过的，中间是简单应用转换的

![vector registration](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FDT/UserGuide?action=AttachFile&do=get&target=fdt_vecreg.gif)

也就是有2步骤：

1. 转换
2. 重定向

`vecreg`不会自己计算转换，需要指定转换，例如FLIRT计算的线性转换和FNIRT计算的非线性转换

```bash
vecreg -i <input4D> -o <output4D> -r <refvol> [-t <transform>]


Compulsory arguments (You MUST set one or more of):
        -i,--input      filename for input vector or tensor field
        -o,--output     filename for output registered vector or tensor field
        -r,--ref        filename for reference (target) volume

Optional arguments (You may optionally specify one or more of):
        -v,--verbose    switch on diagnostic messages
        -h,--help       display this message
        -t,--affine     filename for affine transformation matrix
        -w,--warpfield  filename for 4D warp field for nonlinear registration
        --rotmat        filename for secondary affine matrix
                        if set, this will be used for the rotation of the vector/tensor field
        --rotwarp       filename for secondary warp field
                        if set, this will be used for the rotation of the vector/tensor field
        --interp        interpolation method : nearestneighbour, trilinear (default), sinc or spline
        -m,--mask       brain mask in input space
        --refmask       brain mask in output space (useful for speed up of nonlinear reg)
```

## qboot

用来计算弥散想的ODF和纤维方向，它的输出可以作为probtrackX的输入

通过残差自助法（residual bootstrap）来推断ODF的形状和方向并且获得纤维方向分布

`qboot`允许重构q-ball ODFs及其变体，用的是拉普拉斯锐化（Laplacian sharpening）和拉普拉斯-贝尔特拉米正则化（Laplace-Beltrami regularization）

**重构的ODFs的球谐函数系数**和**纤维分布估计**都会返回为输出

qboot的输入和ditfit或者bedpostx相似，有：

- 4D文件
- 二进制mask文件
- bvecs和bvals文件

```bash
qboot -k data_file -m nodif_brain_mask -r bvecs -b bvals

Compulsory arguments (You MUST set one or more of):
        -k,--data       Data file
        -m,--mask       Mask file
        -r,--bvecs      b vectors file
        -b,--bvals      b values file

Optional arguments (You may optionally specify one or more of):
        --ld,--logdir   Output directory (default is logdir)
        --forcedir      Use the actual directory name given - i.e. don't add + to make a new directory
        --q             File provided with multi-shell data. Indicates the number of directions for each shell
        --model         Which model to use. 1=Tuch's ODFs, 2=CSA ODFs (default), 3=multi-shell CSA ODFs
        --lmax          Maximum spherical harmonic order employed (must be even, default=4)
        --npeaks        Maximum number of ODF peaks to be detected (default 2)
        --thr           Minimum threshold for a local maxima to be considered an ODF peak.
                        Expressed as a fraction of the maximum ODF value (default 0.4)
        --ns,--nsamples Number of bootstrap samples (default is 50)
        --lambda        Laplace-Beltrami regularization parameter (default is 0)
        --delta         Signal attenuation regularization parameter for model=2 (default is 0.01)
        --alpha         Laplacian sharpening parameter for model=1 (default is 0, should be smaller than 1)
        --seed          Seed for pseudo-random number generator
        --gfa           Compute a generalised FA, using the mean ODF in each voxel
        --savecoeff     Save the ODF coefficients instead of the peaks.
        --savemeancoeff Save the mean ODF coefficients across all samples
        -V,--verbose    Switch on diagnostic messages
```

和bedpostx类似，如果在支持SGE的系统上运行，qboot可以并行化，用`qboot_parallel`脚本

默认情况下，每个shell下采集的数据点（datapoints）的数量相同（包括b=0），如果不是这样，需要`--q=qshells.txt`来说明，`qshell.txt`文件里的内容应该是`N1 N2 N3`形式，每个数字表示datapoints的数量（包括b=0），对应了每个shell

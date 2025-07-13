# 一、dMRI数据预处理

假设数据如下：

20名control和20名patient

```
study/subjects/001_control/dwi.mif
study/subjects/002_control/dwi.mif
...
study/subjects/020_control/dwi.mif
study/subjects/021_patient/dwi.mif
...
study/subjects/040_patient/dwi.mif
```

cd到`subjects`文件夹下，该目录下有40个子文件夹，分别代表40名被试

```bash
cd subjects
```

## 1. 去噪，去Gibbs伪影

如果数据需要进行“去噪”和“去Gibbs伪影”操作，则必须任何其他处理步骤之前进行。

原因是，大多数后续处理步骤，尤其是那些涉及数据插值（interpolation）的步骤，会破坏原始图像数据的特性，而这些特性正是去噪`dwidenoise`和去除吉布斯伪影`mrdegibbs`方法所依赖的。

如果在这些步骤之后执行去噪和去除吉布斯伪影，可能会导致结果出现错误。

```bash
for_each * : dwidenoise IN/dwi.mif IN/dwi_denoised.mif
for_each * : mrdegibbs IN/dwi_denoised.mif IN/dwi_denoised_unringed.mif -axes 0,1
```

> `mrdegibbs`命令中的 `-axes` 选项用于指定切片采集的平面。举例来说，`-axes 0,1` 表示在 x-y 平面上，这适用于由一堆轴向（axial）切片组成的数据（假设使用的是典型的人类扫描仪和被试）。对于典型的人类数据，如果数据是冠状面（coronal）切片，则应将选项改为 `-axes 0,2`；如果数据是矢状面（sagittal）切片，则应将选项改为 `-axes 1,2`。

## 2. 头动校正，失真校正，涡流校正

调用`FSL`进行预处理，最简单的代码如下图所示，具体数据需具体对待

```bash
for_each * : dwifslpreproc IN/dwi_denoised_unringed.mif IN/dwi_denoised_unringed_preproc.mif -rpe_none -pe_dir AP
```

## 3. 偏置场校正（可选）

**multi-tissue FBA**流程在后期的`mtnormalise`步骤中还会进行**偏置场（bias fields）校正**，并且同时进行**全局强度归一化（global intensity normalisation）**。

当前进行的“ **偏置场校正**”`dwibiascorrect`相对不太稳健和准确，目的是接下来使用`dwi2mask`可以获得更好的大脑mask。然而，有些案例报告称，在这一阶段运行`dwibiascorrect`会导致后续的大脑掩模估计更差，尤其是当数据中偏置场不强时。

***所以需要强调的是，当前运行的`dwibiascorrect`，主要影响的是大脑mask的估计结果，而对最终的偏置场校正`mtnormalise`效果并没有实质性影响。***

如果需要做当前决定要做偏置场校正（如果你有很好的大脑maks也就不需要做了），首先会从DWI b=0图像数据中估计偏置场，然后将该偏置场应用于校正所有的DWI体积。这一过程通过使用MRtrix3中的`dwibiascorrect`脚本中的**ANTS**算法来完成，并且是一个单独的步骤。脚本使用了在ANTS（Advanced Normalization Tools）工具包中的N4算法进行偏置场校正。

**需要注意的是，在基于fixel的分析管道中，不应使用FSL算法进行偏置场校正。**（但是没有解释为什么）

> Don’t use the `fsl` algorithm with this script in this fixel-based analysis pipeline. 

```bash
for_each * : dwibiascorrect ants IN/dwi_denoised_unringed_preproc.mif IN/dwi_denoised_unringed_preproc_unbiased.mif
```



# 二、基于fixel的分析 FBA

## 4. 计算（平均）组织响应函数

首先生成每个被试各自的响应函数

```bash
for_each * : dwi2response dhollander IN/dwi_denoised_unringed_preproc_unbiased_normalised.mif IN/response_wm.txt IN/response_gm.txt IN/response_csf.txt
```

***！！！重要！！！***：

*在进行**基于fixel的分析**时，必须仅使用一组唯一的响应函数（response functions）来执行三组织（3-tissue）球面反卷积（spherical deconvolution），并应用于所有被试。原因是，反卷积的结果会以这组响应函数为基础进行表达，因此，这些响应函数可以从抽象的角度看作是最终**表观纤维密度（AFD, apparent fibre density）度量**和模型中其他估计区域（compartments）的“**单位**”。*

生成组平均响应函数：

```bash
responsemean */response_wm.txt ../group_average_response_wm.txt
responsemean */response_gm.txt ../group_average_response_gm.txt
responsemean */response_csf.txt ../group_average_response_csf.txt
```

最终的响应函数集合不一定严格要求是所有被试的响应函数的平均值（对于每种组织类型）。并没有硬性规定必须使用所有被试的平均响应函数。例如某个病患的病理因素影响了全脑范围的结果，那么排除这个被试可能是更明智的选择。

## 5. 上采样DW图像（可选）

在计算**FODs（纤维方向分布函数，Fibre Orientation Distributions）**之前，对DWI（扩散加权成像）数据进行上采样（upsampling）能够增加解剖对比度，并改善后续步骤中的模板构建、配准、纤维追踪和统计分析。

对于人类大脑，推荐将图像上采样到1.25 mm的各向同性（isotropic）体素大小（如果你的原始分辨率已经更高，可以跳过这一步）。

```bash
for_each * : mrgrid IN/dwi_denoised_unringed_preproc_unbiased_normalised.mif regrid -vox 1.25 IN/dwi_denoised_unringed_preproc_unbiased_normalised_upsampled.mif
```

## 6. 生成dwi的mask（可选）

如果你已经有了更好的大脑mask，可以跳过这一步（注意mask的分辨率应和dMRI数据相同）

```bash
for_each * : dwi2mask IN/dwi_denoised_unringed_preproc_unbiased_normalised_upsampled.mif IN/dwi_mask_upsampled.mif
```

> 需要**检查每个被试的脑掩模（mask）是否覆盖所有需要分析的脑区**。因为纤维方向分布（FODs）的计算仅限于这些掩模内的区域，而且在后续步骤中（例如模板空间中的分析），分析mask将被限制为**所有被试mask的交集**。如果某个被试的mask没有包括某个脑区，那么这个脑区就会在整个分析中被排除。
>
> 如果mask过于宽松或包含了一些非脑组织的区域，这通常不会对这一阶段的分析造成问题。因此，**在不确定的情况下，建议宁可多包括一些区域（即“宁多勿少”）**，以避免遗漏感兴趣的脑区。
>
> 前面提到的`dwibiascorrect`也许可以优化这里生成的大脑mask的质量，也许不能，看情况考虑。

## 7. 估计FOD（multi-tissue球形反卷积）

执行球形反卷积时，应该使用**组平均的响应函数**

```bash
for_each * : dwi2fod msmt_csd \
                     IN/dwi_denoised_unringed_preproc_unbiased_normalised_upsampled.mif \
                     ../group_average_response_wm.txt IN/wmfod.mif \
                     ../group_average_response_gm.txt IN/gm.mif  \
                     ../group_average_response_csf.txt IN/csf.mif \
                     -mask IN/dwi_mask_upsampled.mif
```

每个被试，都用同一组响应函数（`response.txt`），来生成各自的`fod.mif`文件

## 8. 偏置场校正加强度标准化

使用`mtnormalise`对每个被试的多组织分量参数（multi-tissue compartment parameters）进行**联合偏置场校正（bias field correction）**和**全局强度归一化（global intensity normalisation）**

这个归一化是**组织之间**的归一化，上面提到的平均响应函数可以理解成是**被试之间**的归一化

```bash
for_each * : mtnormalise IN/wmfod.mif IN/wmfod_norm.mif \
                         IN/gm.mif IN/gm_norm.mif \
                         IN/csf.mif IN/csf_norm.mif \
                         -mask IN/dwi_mask_upsampled.mif
```

> mtnormalise对包含非脑区域的mask敏感，`mtnormalise`算法会尝试将这些区域的组织体积总和调整为统一值（即归一化为1），尽管这些区域并不包含脑组织。这种调整可能会导致错误的偏置场校正，特别是当这些非脑区域的体素数量较多时。
>
> 所以不希望用太大的mask（和第6步相反），所以明确这一步需要更为保守的mask。

这一步是整个**基于fixel分析**流程中的至关重要的步骤。

即使在早期已经使用`dwibiascorrect`进行了偏置场校正，`mtnormalise`仍然是必要的，因为`dwibiascorrect`无法纠正被试之间的全局强度差异，而这是`mtnormalise`的功能之一。

在前期如果已经运行过`dwibiascorrect`，对`mtnormalise`的效果也没有显著影响。如果前面已经进行了偏置场校正，`mtnormalise`将进一步校正残余的强度不均匀性。

## 9. 生成study-specific unbiased FOD模板

生成population template很耗时，特别是被试特别多的时候，所以可以选择其中有代表性的被试来做（30~40个）

首先需要创建组平均文件夹：

```bash
mkdir -p ../template/fod_input
mkdir ../template/mask_input
```

把原来的文件链接过来，就不需要重新复制，节省空间：

```bash
for_each * : ln -sr IN/wmfod_norm.mif ../template/fod_input/PRE.mif
for_each * : ln -sr IN/dwi_mask_upsampled.mif ../template/mask_input/PRE.mif
```

>`-s`表示软链接，符号链接是一种特殊类型的文件，它指向另一个文件或目录。与硬链接不同，符号链接可以跨文件系统，且可以指向目录。
>
>`-r`表示相对路径，即符号链接中的路径是相对于链接所在位置的路径，而不是绝对路径。
>
>**软链接：**
>
>1.软链接，以路径的形式存在。类似于Windows操作系统中的快捷方式
>2.软链接可以 跨文件系统 ，硬链接不可以
>3.软链接可以对一个不存在的文件名进行链接
>4.软链接可以对目录进行链接
>
>**硬链接:**
>
>1.硬链接，以文件副本的形式存在。但不占用实际空间。
>2.不允许给目录创建硬链接
>3.硬链接只有在同一个文件系统中才能创建
>
>第一，`ln`命令会保持每一处链接文件的同步性，也就是说，不论你改动了哪一处，其它的文件都会发生相同的变化；
>第二，`ln`的链接又分软链接和硬链接两种，软链接就是`ln –s` 源文件 目标文件，它只会在你选定的位置上生成一个文件的镜像，不会占用磁盘空间，硬链接 `ln` 源文件 目标文件，没有参数`-s`， 它会在你选定的位置上生成一个和源文件大小相同的文件，无论是软链接还是硬链接，文件都保持同步变化。

构建FOD的population template文件：

```bash
population_template ../template/fod_input \
                    -mask_dir ../template/mask_input \
                    ../template/wmfod_template.mif \
                    -voxel_size 1.25
```

> 这里输入有：
>
> 1. `fod_input`文件夹（有几个被试就有几个`wmfod_norm.mif`文件）
> 2. `mask_input`文件夹（有几个被试就有几个`mask.mif`文件）
>
> 输出为`wmfod_template.mif`文件
>
> 所以是用所有被试各自的fod文件，生成了一个组平均的fod文件（***这是怎么做到的，不配准的吗？***）
>
> 答：是要配准的，`population_template`命令内部先做一个线性配准，然后再非线性配准来优化结果（“First a template is optimised with linear registration (rigid and/or affine, both by default), then non-linear registration is used to optimise the template further.”）

## 10. 把个体的FOD配准到组平均FOD上

```bash
for_each * : mrregister IN/wmfod_norm.mif \
                        -mask1 IN/dwi_mask_upsampled.mif \
                        ../template/wmfod_template.mif \
                        -nl_warp IN/subject2template_warp.mif \
                        IN/template2subject_warp.mif
```

> 默认是先进行仿射（affine），再进行非线性变换
>
> 输入有：
>
> 1. `wmfod_norm.mif`文件
> 2. `mask.mif`文件
> 3. 需要配准的`wmfod_template.mif`文件
>
> 输出有：
>
> 1. `subject2template_warp.mif`
> 2. `template2subject_warp.mif`

## 11. 计算模板mask

所有被试的mask转到模板空间上再做交集。

> 这里的模板空间是指组平均得到的空间

```bash
# 转换到模板空间
for_each * : mrtransform IN/dwi_mask_upsampled.mif \
                         -warp IN/subject2template_warp.mif \
                         -interp nearest -datatype bit \
                         IN/dwi_mask_in_template_space.mif
# 取交集
mrmath */dwi_mask_in_template_space.mif \
       min \
       ../template/template_mask.mif \
       -datatype bit
```

> 建议检查maks是否包含所有计划分析的脑区。并可以考虑删除那些不属于大脑的部分（如果之间使用的mask很大的话）。

## 12. 计算白质模板分析fixel的mask

在这一阶段，从FOD模板中**分割出fixel**。最终的结果是生成一个**fixel mask**.

该mask定义了后续统计分析将在哪些fixel上进行（即哪些fixel将参与统计分析）。

同时，这也意味着哪些fixel的统计结果可以通过**基于连接性的fixel增强（Connectivity-based Fixel Enhancement，CFE）**机制来支持其他fixel的统计结果，这种机制在[Raffelt2015](https://www.sciencedirect.com/science/article/pii/S1053811915004218)中有详细描述。

```bash
fod2fixel -mask ../template/template_mask.mif \
          -fmls_peak_value 0.06 \
          ../template/wmfod_template.mif \
          ../template/fixel_mask
```

> 输入：
>
> 1. 组平均mask文件
> 2. 组平均fod文件
>
> 输出：
>
> 1. 组平均`fixel_mask`文件夹（**注意输出的是一个文件夹**）

从这一步开始，管道中将使用**fixel图像**。fixel图像是使用一种特殊的Fixel图像格式来存储的，这种格式将与单个fixel相关的所有数据存储在一个目录（文件夹）中。

这一步骤**决定了统计分析将在哪些fixel区域进行**，因此也确定了哪些fixel的统计结果能够通过**连接性增强机制（CFE）**为其他fixel提供支持，因此它对最终结果有很大影响。

> `-fmls_peak_value`指定的阈值非常关键。如果这个阈值设置得过高，可能会排除掉一些**真实的白质fixel**，从而对结果产生不利影响。这个风险在**包含交叉纤维的体素**中尤为突出，尤其是当一个体素中有多个纤维交叉时，问题更为严重。
>
> 虽然在使用3组织球面解卷积（3-tissue CSD）生成的人群模板中，`0.06`作为默认值通常是比较合适的，但仍然强烈建议使用`mrview`工具来**可视化输出的fixel掩模**，检查掩模是否准确。具体方法是打开位于`../template/fixel_mask`中的`index.mif`文件，并使用fixel plot工具进行检查。
>
> 如果根据已知的正常解剖结构发现某些fixel区域缺失（特别是在交叉纤维区域），建议通过减小`-fmls_peak_value`的值重新生成掩模。但需要注意的是，**不要将该值调得过低**，因为过低的阈值可能会引入过多的**虚假或噪声fixel**，反而对分析结果不利。
>
> 对于一个成人大脑模板，并使用1.25mm的等轴模板体素大小，预计在fixel掩模中会有**数十万到数百万个fixel**。你可以通过运行`mrinfo -size ../template/fixel_mask/directions.mif`来检查fixel掩模的大小，并查看图像在第一维度上的大小，从而了解fixel的数量。

## 13. 把FOD文件配准到模板空间上

在此步骤中，我们将**FOD图像**变换到**模板空间**，但并不进行**FOD的重定向（reorientation）**。

这是因为FOD重定向将会在后续的一个独立步骤中进行，具体是在**fixel分割**之后。

```bash
for_each * : mrtransform IN/wmfod_norm.mif \
                         -warp IN/subject2template_warp.mif \
                         -reorient_fod no \
                         IN/fod_in_template_space_NOT_REORIENTED.mif
```

## 14. 分割FOD图像以估计fixels的Fibre Density，FD

对每个FOD（纤维方向分布）的lobes进行分割，以确定每个体素中fixel的数量和方向。

FOD图像包含多个lobes（即纤维方向的多个峰值，每个峰值代表大脑中不同方向的纤维）。通过分割FOD中的每个lobe，我们能够**识别每个体素中的fixel数量**（例如，如果一个体素包含多个纤维方向，则该体素会有多个fixel）以及每个fixel的**方向**（即这些纤维的主要方向）。

**Fixel的数量和方向**：通过分割FOD的lobes，可以明确每个体素中有多少个fixel，每个fixel代表一个特定方向的纤维群体。这个过程是基于FOD的方向信息来识别和定义fixel。

每个fixel的**表观纤维密度AFD**是通过**FOD lobe的积分**来估计的。FOD的lobe表示的是纤维在某个方向上的分布强度，积分的过程相当于计算该方向的纤维强度或密度。通过这个计算，AFD值提供了每个fixel所代表的纤维密度的定量估计。

```bash
for_each * : fod2fixel -mask ../template/template_mask.mif \
                       IN/fod_in_template_space_NOT_REORIENTED.mif \
                       IN/fixel_in_template_space_NOT_REORIENTED \
                       -afd fd.mif
```

> **FD（fibre density）和AFD（apparent fibre density）在这里表示同一样东西，只是FD这个说法更加通用**
>
> 输入：
>
> 1. 组平均的`template_mask.mif`文件
> 2. 被试各自的`fod_in_template_space_NOT_REORIENTED.mif`文件
>
> 输出：
>
> 1. `fixel_in_template_space_NOT_REORIENTED`文件夹
> 2. 这个文件夹里除了默认的`index.mif`和`directions.mif`，还有`fd.mif`

## 15. 重定向fixels

根据之前使用的**配准变换**，**重新定向（reorient）所有被试在模板空间中的fixel方向**。

这一过程是基于每个体素中局部的变换来实现的。

```bash
for_each * : fixelreorient IN/fixel_in_template_space_NOT_REORIENTED \
                           IN/subject2template_warp.mif \
                           IN/fixel_in_template_space
```

> 输入：
>
> 1. `fixel_in_template_space_NOT_REORIENTED`文件夹
> 2. `subject2template_warp.mif`文件
>
> 输出：
>
> 1. `fixel_in_template_space`文件夹
>
> 这一步做完就可以把`fixel_in_template_space_NOT_REORIENTED`文件夹删掉了；也就是说那个文件夹中的`FD.mif`文件没有用是吗？

## 16. 把被试fixels分配到组模板fixels中

虽然每个被试的数据已经通过空间配准（warping）到共同的模板空间，并且被试的fixel方向也已经进行了重新定向，但至此尚未指定每个fixel在不同被试间的对应关系，或者它们如何与模板空间中的fixel匹配。

这一步的目标就是确定这些对应关系，具体通过将每个被试的fixel与模板空间中唯一的一组模板fixel进行匹配，从而明确它们在不同被试之间的对应关系。

```bash
for_each * : fixelcorrespondence IN/fixel_in_template_space/fd.mif \
                                 ../template/fixel_mask \
                                 ../template/fd \
                                 PRE.mif
```

> 输入：
>
> 1. 每个被试的`fd.mif`
> 2. 组平均的`fixel_mask`文件夹
>
> 输出：
>
> 1. 组平均下的`fd`文件夹
> 2. 以及该文件夹下有各个被试的`fd`文件，以被试名字命名`<name>.mif`

输出的**fixel目录** `../template/fd` 对所有被试来说是相同的。这是有道理的，因为在完成上述操作后，最终只剩下一个统一的**fixel集合**（即模板fixel），而每个被试的**表观纤维密度（FD）值将根据该模板fixel集合进行分配。

因此，`../template/fd`目录现在存储了每个被试的fixel数据文件，这些文件都对应着同一组模板fixel。

## 17. 计算fibe cross-section(FC)度量

**表观纤维密度（AFD，或者用通称fibre density, FD）**是直接映射到模板空间的，但没有进行任何调制，它主要反映的是每个体素内纤维的原始密度，即纤维的数量或局部纤维分布。

简单来说，FD只关注**局部纤维的密集程度**，而不考虑**纤维束的整体横截面尺寸**。

换句话说，它忽略了束的横截面大小这一属性，而横截面大小会影响整个纤维束在其横截面上的总容积，从而影响其携带信息的总能力。

例如，纤维束可能在某些区域因萎缩或病变而变窄，但这些变化不会影响FD值，因为FD只反映了局部的纤维密度，而不考虑束的横截面大小。在纤维束中，横截面大小影响着其**总信息承载能力**。即便纤维密度保持不变，若纤维束变细，束的总容量（承载信息的能力）也可能会受到影响。

所以需要考虑**fibe cross-section, FC**度量。这个度量的信息完全来自于在配准过程中生成的**变换（warps）**。

```bash
for_each * : warp2metric IN/subject2template_warp.mif \
                         -fc \
                         ../template/fixel_mask \
                         ../template/fc \
                         IN.mif
```

> 输入：
>
> 1. 转换场文件`subject2template_warp.mif`
> 2. 组平均`fixel_mask`文件夹
>
> 输出：
>
> 1. 组平均下的`fc`文件夹
> 2. 以及该文件夹下有各个被试的`fc`文件，以被试名字命名`<name>.mif`

对于组统计分析的FC，建议计算log(FC)，以确保数据以0为中心并呈正态分布。并创建一个单独的**fixel目录**来存储**log(FC)**数据，并将**fixel索引文件和方向文件**复制到该目录中。

```bash
mkdir ../template/log_fc
cp ../template/fc/index.mif \
	../template/fc/directions.mif \
	../template/log_fc  # 原来cp命令可以同时复制2个文件到同一个文件夹下的 = =
for_each * : mrcalc ../template/fc/IN.mif \
					-log \
					../template/log_fc/IN.mif
```

这里计算的**FC**（以及随之计算的**log(FC)**）是一个相对度量，表示的是每个局部fixel横截面的大小，相对于**本研究**使用的**群体模板**。

这种计算方法使得我们可以在**同一研究内部**解释FC的差异（因为研究中使用了唯一的模板）。也就是说在该研究中，A被试和B被试之间是可以比较的。但是**别人的研究中的甲被试的FC**不能拿来与**本研究的A被试的FC**来比较。

总之就是这些FC值不应当在不同研究之间进行比较，因为每个研究可能有自己的群体模板。报告FC的**绝对值**或**FC的绝对效应量**提供的信息很有限，因为这些值只有在相对于模板的情况下才有意义。

## 18. 计算FDC，一个联合了FD和FC的指标

纤维束承载信息的总能力，受到**局部纤维密度（FD）**和其**横截面大小（FC）**的共同调节。

所以需要计算了一个综合度量，它同时考虑了FD和FC的影响，得到一个名为**纤维密度和横截面（FDC）**的度量（也就是把**FD**和**FC**相乘）。

```bash
mkdir ../template/fdc
cp ../template/fc/index.mif \
	../template/fdc
cp ../template/fc/directions.mif \
	../template/fdc
for_each * : mrcalc ../template/fd/IN.mif \
                    ../template/fc/IN.mif \
                    -mult \
                    ../template/fdc/IN.mif
```

这是一个很好的例子，展示了如何在多个fixel数据文件之间进行计算（即把`template/fd`中的fixel文件与`template/fc`中的fixel文件相乘）。

然而，需要注意的是，只有在这些数据文件共享相同的**原始fixel集合**（在这里指的是模板fixel mask）时，这种计算才是有效的。

为了确保计算正确，这些fixel必须严格按照相同的顺序存储，因此需要特别小心，确保与所有输入fixel数据文件相关的`index.mif`文件（例如`../template/fd`和`../template/fc`文件夹中的文件）是完全相同的副本。

## 19. 用模板FOD文件进行全脑概率纤维束成像

使用**基于连接的fixel增强（CFE）**（参考：[Raffelt2015](https://www.sciencedirect.com/science/article/pii/S1053811915004218)）进行统计分析时，利用了从**概率性纤维束追踪**中获得的局部连接信息。

这些信息作为一个邻域定义，用于对局部聚集的统计值进行**无阈值增强**。为了从**FOD模板**生成全脑的纤维束图（tractogram），接下来的步骤都将在模板目录中执行。

1. **基于连接的fixel增强（CFE）**：

   - CFE方法利用**局部连接信息**（来自纤维束追踪）来增强统计分析结果。通过这种方式，可以在统计分析中提高与邻域相关的值，从而增强分析的信噪比。

   - 这种方法特别适用于处理fixel数据，在fixel级别进行局部增强，可以改善统计值在临近区域之间的关联性。

2. **局部连接信息**：

   - 通过**概率性纤维束追踪**（probabilistic fibre tractography），可以获得局部的连接信息。纤维束追踪是用来推测不同脑区之间的白质连接的技术，它可以生成大脑各个区域之间连接的概率图谱。
   - 这些连接信息为后续统计分析提供了上下文，帮助识别和强化在特定局部区域内，多个fixel之间的统计聚集效应。

3. **邻域定义**：

   - CFE通过对邻域的统计增强，减少了数据中由单个fixel异常值引起的噪声。通过这种方式，局部区域内的**统计值**被增强，使得真正相关的变化信号更为突出。

4. **无阈值增强**：

   - CFE方法的一个关键特点是**无阈值增强**，即在计算过程中不依赖于固定的阈值来选择哪些统计值被增强。这种方式使得统计结果能够充分利用每个fixel的邻域信息，避免人为设置阈值可能带来的信息丢失或过度筛选。

5. **全脑纤维束图生成**：

   - 在这个步骤中，将从**FOD模板**生成全脑的纤维束图（tractogram）。FOD模板提供了纤维方向密度的估计信息，而全脑纤维束图则是通过纤维束追踪技术，从这些信息中推导出大脑各区域的纤维束连接结构。

6. **执行位置**：

   - 后续步骤将在**模板目录**中执行，这意味着接下来的所有处理都基于生成的模板数据。模板目录是存储全脑FOD模板和相关数据文件的地方。

```bash
cd ../template
# -cutoff翻译为“FOD幅度截断值”，表示FOD的幅度需要高于多少才会被认为纤维方向分布是有效的，否则就要被排除。一般建议0.06
tckgen -angle 22.5 \
	-maxlen 250 \
	-minlen 10 \
	-power 1.0 \
	wmfod_template.mif \
	-seed_image template_mask.mif \
	-mask template_mask.mif \
	-select 20000000 \
	-cutoff 0.06 \
	tracks_20_million.tck
```

## 20. 使用SIFT减少tractogram densities中的偏差

```bash
tcksift \
	tracks_20_million.tck \
	wmfod_template.mif \
	tracks_2_million_sift.tck \
	-term_number 2000000
```

这里没有说明使用SIFT2的方法，我猜测是基于Fixel的分析中，作者还是建议使用SIFT而不是SIFT2，因为SIFT2 只能纠正给定一组轨迹的错误密度波动，如果轨迹不正确，它无法修复轨迹本身。参考[Fixel-based analysis results - General Discussion - MRtrix3 Community](https://community.mrtrix.org/t/fixel-based-analysis-results/5542/5)

>but SIFT2 can only correct for erroneous density fluctuations given a set of trajectories, it can’t fix the trajectories themselves if they are incorrect.

## 21. 生成fixel-fixel连接矩阵

```bash
fixelconnectivity \
	fixel_mask/ \
	tracks_2_million_sift.tck \
	matrix/
```

> 输出目录应包含三个图像：`index.mif`、`fixels.mif` 和`values.mif`；这些用于对本质上稀疏**fixel-fixel连接矩阵**进行编码。

**运行 `fixelconnectivity`** 需要大量内存。

以模板分析中的大约 500,000 个 **fixel** 和典型的 **纤维束连接图**（表示各个fixel之间的配对连接）为例，通常需要 32GB 的内存。

你可以通过使用 `mrinfo -size ./fixel_template/directions.mif` 命令检查模板分析 **fixel mask** 中的 fixel 数量，查看图像的第一维大小。

还需要检查并避免纤维束图中的明显假阳性连接（例如，在不应连接的大区域中连接了两个半球的纤维束）。

如果硬件限制迫使你减少 fixel 数量，不建议通过改变阈值来调整白质模板分析 **fixel mask**，因为这可能会移除白质深层（例如交叉区）的关键 fixel。相反，建议考虑**适度增加模板的体素大小**，或从模板掩膜中**去除不感兴趣的区域**（模板掩膜是通过先前步骤获得的，表示所有受试者掩膜在模板空间中的交集）。

## 22. 使用fixel-fixel连接矩阵来平滑fixel数据

```bash
fixelfilter fd \
	smooth \
	fd_smooth \
	-matrix matrix/
fixelfilter \
	log_fc \
	smooth \
	log_fc_smooth \
	-matrix matrix/
fixelfilter \
	fdc \
	smooth \
	fdc_smooth \
	-matrix matrix/
```

通过依次在每个fixel目录下调用`fixelfilter`命令，可以将平滑滤波器应用于该目录中所有的fixel数据文件。也就是说，**不需要单独对每个fixel数据文件调用`fixelfilter`命令**，只需要在包含这些数据文件的目录中运行一次命令，命令就会自动对该目录下的所有fixel数据文件进行处理。

## 23. 对 FD、FC 和 FDC 进行统计分析

使用 CFE 对每个指标（FD、log(FC) 和 FDC）单独执行统计分析：

```
fixelcfestats fd_smooth/ files.txt design_matrix.txt contrast_matrix.txt matrix/ stats_fd/
fixelcfestats log_fc_smooth/ files.txt design_matrix.txt contrast_matrix.txt matrix/ stats_log_fc/
fixelcfestats fdc_smooth/ files.txt design_matrix.txt contrast_matrix.txt matrix/ stats_fdc/
```

`files.txt`是一个文本文件，其中列出了每个需要分析的文件名（不是完整路径），每个文件名占据一行。

文件中的行顺序应该与`design_matrix.txt`文件中的行顺序对应。也就是说，`files.txt`中的每个文件名与`design_matrix.txt`中的每一行应该一一对应，确保分析时按照正确的顺序处理数据。

注意：

在以前版本的`fixelcfestats`中，输入的fixel数据在导入时会自动进行平滑处理，**但现在已经不再如此**。**现在，用户需要确保提供给`fixelcfestats`的fixel数据已经经过适当的平滑处理，例如可以使用`fixelfilter`命令来对数据进行平滑**。因此，在使用`fixelcfestats`时，平滑处理已经不再是自动完成的步骤，而是用户需要事先完成的预处理。

## 24. 可视化结果

**要查看结果，可以在`mrview`中加载人口FOD模板图像，并使用向量绘图工具叠加fixel图像**。需要注意的是，**p值图像以 (1 - p-value) 的形式保存**，因此，如果你希望可视化所有p值小于0.05的结果，在`mrview`的fixel绘图工具中，需要设置一个下限阈值为0.95（即1 - 0.05）。这样，只有p值小于0.05的区域才会显示出来。

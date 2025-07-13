eddy是一个工具，用于校正弥散数据中，**“涡流 eddy currents EC”**和“运动 movements”导致的失真

eddy校正中，核心使用了**高斯过程（Gaussian Process，GP）** 来预测特定图像volume的“应有”样子。然后，将相应的“观察到的”图像volume（即实际获取到的图像数据）与预测的volume进行配准。

>**高斯过程（Gaussian Process，GP）** 是一种非参数化的贝叶斯模型，可以用于预测函数值。高斯过程模型可以根据已知的数据点来推断未知数据点的分布。在这个上下文中，高斯过程被用来根据其他图像的已知信息，预测某一特定图像体积在理想情况下的外观。

高斯过程的预测不是基于单一的图像体积，而是基于所有其他图像体积的信息。这样，预测的图像就包含了整个数据集的结构，因此比单独观察一个失真图像更接近真实的（未失真的）情况。

相比于基于“互信息”配准的方法，它更能应用到高b值中。

>基于**互信息**的图像配准方法通过最大化图像之间的统计相关性来对齐图像。虽然这种方法在较低 b 值下工作得很好，但在高 b 值下，图像信号质量变差，导致互信息方法难以可靠地配准这些图像。

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/before_after_hcp.gif" alt="DWI images before and after EC-correction" style="zoom:33%;" />

>上图显示左边为未eddy校正的图像，右边未校正完的图像



# 什么是涡流引起的失真？

EPI图像对“离共振场 off-resonance field”十分敏感。

而离共振场可能是由于被扫描物体（例如被试头部）自身对主磁场的扰动作用导致的，也可能是由“扫描仪高架中的导电部件 conductive parts of the scanner gantry”产生的“涡流 eddy currents”导致的。这些电流会产生磁场，因此也称为“离共振场感应的涡电流 eddy currents-induced off-resonance field”，即共振场外感应产生的电流。

> 任何快速变化的磁场都会在导电材料中感应出电流，而MR扫描仪中梯度的切换正是这种“快速变化磁场”。

一般来说，任何EPI采集都会受到影响，因为“图像编码梯度”的切换会引起EC。但是在实际中，这些EC非常小，在序列设计时就可以被处理。

主要在弥散数据成像中，因为其有非常强的“弥散编码梯度 diffusion encoding gradients”，持续出现在图像编码中，从而导致失真。

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/ECFields.jpg" alt="Examples of EC-induced field and distorted images." style="zoom: 67%;" />

>第一行显示了沿下面箭头指示的方向上，用扩散梯度采集的6张扩散加权图像。仔细看，它们相对于彼此都是失真的。
>
>第二行显示了eddy估计出的离共振场。可以看出，离共振场的方向和箭头方向相似，说明eddy准。

**与topup中校正的“磁敏感引发的离共振场”不同的是，EC引发的场，在不同的弥散方向或着说全脑上，都是不一样。**

就是说对于topup中校正的失真，所有全脑都是一样的，b=0和b=1000中的失真都是一样的，所以topup只需要校正b0下的失真就可以了，其他的全脑直接拿来套。

但是EC引发的场，不同全脑不一样，需要针对每个全脑，分别来做。



# Eddy怎么解决这个问题？

eddy本质也是一个图像配准，即把每个volume配准到一个target上，从而校正失真。

一般来说，需要设计一个cost函数，让每个volume配准到target上时，这个“变换 transform”能够产生最小的cost（也可能是最大）。但是这种思路在dwi数据上很难。因为高b值中，噪声太多，图像对比度太差。很难找到合适的cost函数。

所以eddy采用“高斯过程 GP”来解决这一问题。

**eddy 校正** 过程中的两个主要步骤：

1. **加载步骤 (Loading step)**

- **当前估计的校正应用**：在这个步骤中，eddy 校正会将当前关于 **涡流场（EC field）** 和 **被试头动** 的估计应用到所有的图像volume上。涡流场和被试头动是造成扩散加权成像失真的两大主要原因。
- **加载到高斯过程**：然后，将应用了这些校正的图像数据加载到高斯过程中。高斯过程模型使用这些校正后的图像数据，推测理想情况下未失真图像的样子。

2. **估计步骤 (Estimation step)**

- **预测图像体积**：高斯过程根据之前加载的数据，为每个图像volume（基于 b 值和扩散梯度方向）做出预测，推测出这些图像在理想状态下“应该”是什么样子。
- **撤销当前校正**：在这个步骤中，已经应用的校正（如涡流校正和运动校正）会被“撤销”，恢复到校正之前的状态。这一步骤允许系统将预测的图像与未经校正的图像进行直接比较。
- **比较观测图像**：然后，预测的图像与实际观测到的图像（即没有完全校正的图像）进行对比。这种对比反映了校正后的图像与理想图像之间的差异，揭示出剩余的失真或未校正的偏差。
- **误差驱动配准**：预测图像和实际观测图像之间的差异推动了配准过程。系统根据这个差异更新校正参数，进一步调整涡流场和运动校正，使图像配准更加精确。

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/EddySchematic.jpg" alt="Schematic of how eddy works." style="zoom:33%;" />

**迭代过程**

- 这两个步骤构成了一次完整的配准迭代。通常，**eddy** 会进行 **五到十次这样的迭代**，每次迭代都不断更新校正参数，使图像逐步向更准确、未失真的状态逼近。



# 高斯过程

高斯过程是一种基于很少的一般假设，来描述数据的方法。这些假设是：

1. 相比于沿着2个夹角更大的向量采集的2次dwi信号，夹角更小的dwi信号之间更相似。
2. 沿着$v$和$-v$采集的2次信号，是相同的。

![Gaussian Process fit to multi-shell data.](https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/GaussianProcess.jpg)

> 如上图所示，对于每个voxel，都能生成上面这样一种图。其中点是实际的volume数据，蓝点来自于b=1000的shell，红点来自于b=3000的shell。点的方向表示diffusion gradient的方向，点与中心的距离表示“图像强度 image intensity”，即该volume中该voxel的值。
>
> 红色的曲面和蓝色的曲面则是GP预测出的数据。

关于eddy的2个特点：

1. eddy不需要在“整个球形 whole-sphere”上获取数据
2. eddy不需要在“所有方向 all directions”上以PE相反的方向采集数据

当我们采集dwi数据的时候，我们都会希望我们的弥散梯度方向是分散开来的，这样能最小化弥散信号建模时在任何方向上的建模偏差。

但是dwi信号是旋转对称的，即对于弥散梯度$v$和$-v$来说，信号是一样的。所以半球分散的信号就可以覆盖到全球。

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/half_sphere_movie.gif" alt="Movie of sample points on the half-sphere" style="zoom: 50%;" /><img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/whole_sphere_movie.gif" alt="Movie of sample points on the whole-sphere" style="zoom: 50%;" />

> 上图右边采集的全球信号完全等价于左边采集的半球信号

可以用matlab代码来查看自己的数据到底是半球采集还是全球采集：

```matlab
bvecs = load('bvecs'); % Assuming your filename is bvecs
figure('position',[100 100 500 500]);
plot3(bvecs(1,:),bvecs(2,:),bvecs(3,:),'*r');
axis([-1 1 -1 1 -1 1]);
axis vis3d;
rotate3d
```



## 为什么在eddy中，全球采集更具有优势

**但是在eddy中，使用全球信号采集更有优势。**

如果数据在全球上被采样，那么GP预测出的target图像，会被认为是在无失真的空间中。因为GP预测是所有其他全脑图像的加权平均和，而这些图像会在各个方向上失真，从而抵消。

EC（我们要校正的东西）是弥散梯度引起的，而“涡流参数 EC-parameters”和“弥散梯度的不同分量 x,y,z”具有线性关系，见下图。起点的意义：当梯度分量是0的时候，“涡流参数 EC-parameters”也是0。即当某个方向上（x, y, z）的梯度分量为0时，该特定分量相关的EC效应也不存在。因此，涡流效应只会出现在有非零梯度分量的方向上。

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/SecondLevel.jpg" alt="Demonstration of unbiasing through second-level modelling." style="zoom: 67%;" />

相反，如果数据是在半球上采集的，则其中一个分量（一般是z分量，但不一定）的平均值为非零，因此该分量的EC为非零。这样GP预测的target图像不会是0失真空间，而是仍然具有一定失真的空间。

## 如果数据来自于半球采集，怎么办

可以在eddy命令行中增加`--slm=linear`

这个选项的作用是对EC参数进行建模，eddy会估计弥散梯分量的线性函数，将任何非0偏移量置于中心。

> ANDI'brain book中介绍的使用MRtrix进行预处理的代码中，已经加入了这个选项，但是HCPNHPPipeline中没有加



# eddy使用何种失真模型？

Jezzard等人将失真模型用以下3点进行描述：

1. yx-shear
2. y-zoom
3. z-translation

EC感应场是x，y，z线性梯度的线性组合。相位编码方向（PE-direction）沿 **y 轴**

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/EC2DistortionExplanation.jpg" alt="Explanation of how EC-fields translate into distortions." style="zoom: 67%;" />

> 上图显示了EC场如何导致失真。
>
> 第2、3行中，弥散梯度的方向向左，第4、5行中，弥散梯度的方向向下。不同弥散梯度的方向会导致不同程度的失真，所以涡流校正需要针对所有volume（与topup进行的磁敏感校正不同）

以上表述都有一个很重要的假设，即：EC场（也可以叫EC-induced场，EC-induced off-resonance场，无所谓，都是指一个东西），被认为是弥散梯度分量的完美的线性组合。

但是在实际情况中，大多时候都不是这样，由于各种原因。甚至发现了很多“二次 quadratic”和“三次 cubic”的关系。这很正常，因为即使是梯度线圈本身产生的“线性”场，也不是特别线性（通常还需要进行非线性校正来产生高保真图像）。

综上，eddy其实默认将EC场建模为“二次 quadratic”场，包括一个常数项，每个场/volume产生**10个参数**。如果想要修改可以在`--flm=linear, --flm=quadratic, --flm=cubic`中选择。



# 除了涡流失真，还有哪些失真能被eddy校正？

除了涡流失真，还有以下失真会被eddy校正：

1. Inter-volume subject movement 全脑间的被试运动
2. Movement-related signal drop out 运动相关的信号丢失
3. Intra-volume subject movement 全脑内的被试运动
4. Susceptibility-by-movement interaction 运动导致的磁敏感

## 全脑间的被试运动

eddy中包括了刚体模型（6个参数）用于处理被试运动，所以二次模型总共有16个参数。

**评估的“旋转参数 rotation parameters”还将生成一组新的`bvecs`，取代原来的`bvecs`**

## 运动相关的信号丢失

dwi成像基于信号损失。在序列的弥散编码阶段时发生头部运动，也会导致信号损失。这些信号损失通常表现为某个slice的信号几乎完全消失（如果用的是“多频段采集 multi-band acquisitions”，甚至会导致一组slice信号消失），或者slice的部分信号消失（例如脉动信号引起的脑干信号消失）。

eddy通过将观测到的切片的平均信号与预测信号（GP预测）进行比较，如果发现2者之间的差异超过某个数值（默认为4个标准差），eddy会用其预测信号来替换观测信号。

通过在eddy命令中添加`--repol`选项来启用该功能。

<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/OLR_before_after.gif" alt="Example of data with and without outlier-replacement." style="zoom:67%;" />

> 没有使用`--repol`选项下，图像中有明显的黑色条带，表示信号的丢失。

## 全脑内的被试运动

EPI 序列中的切片并非全部同时采集。通常需要 3 到 8 秒的时间（取决于是否使用多频段技术）来获取全部数据。

在扩散成像中，切片通常以“交错”的方式获取，即先获取所有奇数切片，然后获取所有偶数切片。这意味着，在获取过程中如果受试者移动，通常会在图像边缘出现明显的锯齿状（Z字形）图案。

![Explanation of zig-zag pattern from intra-volume movement.](https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/IntraVolumeMovementExplanation.jpg)

通过在eddy命令中添加`--mporder=n`（其中n是大于等于0的数字）选项，可以校正全脑内的被试运动

![Movie of data before any correction.](https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/before_movie.gif)<img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/after_eddy_movie.gif" alt="Movie of data after EC and inter-volume motion correction" style="zoom:33%;" /><img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/after_eddy_olr_movie.gif" alt="Movie of sample points on the half-sphere" style="zoom:33%;" /><img src="https://fsl.fmrib.ox.ac.uk/fsl/docs/diffusion/eddy/after_eddy_s2v_movie.gif" alt="Movie of sample points on the whole-sphere" style="zoom:33%;" />

> 第1张图：原始数据
>
> 第2张图：EC校正，被试间volume校正
>
> 第3张图：EC校正，被试间volume校正，outlier校正
>
> 第4张图：EC校正，被试内volume校正，outlier校正，

## 运动导致的磁敏感

topup估计的磁敏感场，严格来说只对特定被试的位置有效。

意思就是说只有被试一直保持原始位置，估计出来的场才是有效且正确的，如果被试向左移动了5mm，磁场也会变化。

当被试移动时，场不会完全改变，而是近似于跟随被试移动。但是在实际中，被试的运动会对磁场产生更复杂的影响，所以之前的说法只是一个”第一近似 first approximation“。

如果存在“平面外的旋转 out-of-plane rotations”（大多数被试运动都包括这些旋转），则场不再只是跟随被试，而会发生进一步变化。这些变化通常不大（在最严重的区域 ~5HZ/degree 的旋转，而topup校正的离共振场失真在最严重的地方能达到150Hz）。

5度对应了25Hz的场，也对应了超过2个体素的失真。

这意味着被试在不同位置时采集的图像之间，有不同的失真，甚至在“配准 alignment”之后，也不会匹配。

eddy，能够估计“被试头动 subject movement”导致的场的变化。

只需要在eddy命令中加入`--estimate_move_by_susceptibility`选项。建议在被试头动较大的情况下使用（例如小孩、老人、病患）。

# 额外内容

`eddy_combine`命令只是平均了AP和PA方向，目的是为了降低bedpostx的运行时间。见https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=fsl;f94317ea.1805

>Q: Some suggested pipelines (i.e. the HCP) use eddy_combine after the above steps but I find little to no detailed description on what is its role. My guess is it just corrects (balances) the intensity between AP and PA scans but does not alter any structural details. Does it just simply average the corrected AP and PA scans or fit a sophisticated model instead? And it is necessary to include it in the pipeline or it is deprecated?
>
>A: It just averages the corresponding AP and PA scans. It was only done so as to reduce the execution time of the subsequent bedpost step. I wouldn’t necessarily recommend doing it.
# 在MRtrix中使用其他软件的配准

`mrtransform`可以讲一个图像配准到另一个图像上，例如：

```bash
mrtransform IN/dwi_mask.mif \
	-warp IN/subject2template_warp.mif \
	interp nearest \
	-datatype bit \
	IN/dwi_mask_in_template_space.mif
```

> 输入：
>
> 1. `dwi_mask.mif`
> 2. `subject2template_warp.mif` （转换文件）
>
> 输出：
>
> 1. `dwi_mask_in_template_space.mif`

当仅仅是线性配准的时候，MRtrix用的是一个矩阵纯文本文件。可以通过 [transformconvert ](https://mrtrix.readthedocs.io/en/latest/reference/commands/transformconvert.html) 命令来将FSL或者ITK-based的文件转换成MRtrix需要的格式。

而对于非线性配准，**MRtrix3 工具要求非线性变换以特定的图像格式存储**，这种格式的特点是：每个体素的值都定义了它在另一幅图像中的扫描仪空间位置。

这种转换格式被称为“**变形场 deformation field**”。

在对图像进行**变形（warping）**时，变形场中记录的目标位置坐标会被用来从源图像中获取强度值，并将这些值填充到目标图像的网格中。

假设有一个 3D 图像的配准操作：

- 变形场记录了**目标图像**每个体素应该去**源图像**的哪个位置采样。
- 比如**目标图像**某个体素的坐标是 (10, 20, 30)，而变形场告诉我们源图像对应的是位置 (15.4, 18.2, 28.7)。
- 然后，采样算法会从**源图像** (15.4, 18.2, 28.7) 的位置获取强度值（可能需要插值），并赋值到目**标图像**的 (10, 20, 30) 的体素中。

还有一个“**位移场 displacement field**”，记录了**每个体素**从其**所在扫描仪空间**中的位置到**另一幅图像中对应位置**的**位移量**（以mm为单位）。

- 每个体素的当前位置是在**扫描仪坐标系（scanner space）**中定义的。位移场**不会直接记录目标位置的绝对坐标**，而是记录**从当前位置到目标位置的“位移向量”**。
- 这个位移向量表示了体素在三维空间中沿 x、y、z 轴的偏移量。

**变形场**和**位移场**的区别：

- **变形场（deformation field）**记录了每个体素在目标图像中的绝对位置（即坐标值）。

- **位移场（displacement field）**只记录从源图像体素到目标图像体素之间的相对位移量。

`warpconvert` 可以帮助在不同的变形场格式之间转换。

## 1. warp 图像

**变形场（warp）的体素网格与参考（“目标”）图像的体素网格是完全相同的**。

例如个体图像是`145x174x145`的，模板图像是`135x167x132`的，那么：

- `subjects2template_warp.mif` 是 `135x167x132x3`
- `template2subjcets_warp.mif` 是 `145x174x145x3`

其中最后一个维度有3个值，就是x，y，z上的位移量

如果用ANTs做配准，例如：

```bash
antsRegistration --verbose 1 \
	--dimensionality 3 \
	--float 0 \
	--output [ants,antsWarped.nii.gz,antsInverseWarped.nii.gz] \
	--interpolation Linear \
	--use-histogram-matching 1 \
	--winsorize-image-intensities [0.005,0.995] \
	--transform Rigid[0.1] \
	--metric CC[reference.nii,input.nii,1,4,Regular,0.1] \
	--convergence [1000x500x250x100,1e-6,10] \
	--shrink-factors 8x4x2x1 \
	--smoothing-sigmas 3x2x1x0vox \
	--transform Affine[0.1] \
	--metric CC[reference.nii,input.nii,1,4,Regular,0.2] \
	--convergence [1000x500x250x100,1e-6,10] \
	--shrink-factors 8x4x2x1 \
	--smoothing-sigmas 3x2x1x0vox \
	--transform SyN[0.1,3,0] \
	--metric CC[reference.nii,input.nii,1,4] \
	--convergence [100x70x50x20,1e-6,10] \
	--shrink-factors 4x2x2x1 \
	--smoothing-sigmas 2x2x1x0vox \
	-x [reference_mask.nii.gz,input_mask.nii.gz]
	
for i in {0..2}; do
    antsApplyTransforms \
    	-d 3 \
    	-e 0 \
    	-i identity_warp${i}.nii \
    	-o mrtrix_warp${i}.nii \
    	-r reference.nii \
    	-t ants1Warp.nii.gz \
    	-t ants0GenericAffine.mat \
    	--default-value 2147483647
done
```


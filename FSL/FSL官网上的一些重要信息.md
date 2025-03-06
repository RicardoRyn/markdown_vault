# FSL官网信息

## [What conventions do the bvecs use?](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/diffusion/faq?id=what-conventions-do-the-bvecs-use)

The bvecs use a radiological voxel convention, which is the voxel convention that FSL uses internally and originated before NIFTI (i.e., it is the old Analyze convention). If the image has a radiological storage orientation (negative determinant of qform/sform) then the NIFTI voxels and the radiological voxels are the same. If the image has a neurological storage orientation (positive determinant of qform/sform) then the NIFTI voxels need to be flipped in the x-axis (not the y-axis or z-axis) to obtain radiological voxels. Tools such as dcm2niix create bvecs files and images that have consistent conventions and are suitable for FSL. Applying fslreorient2std requires permuting and/or changing signs of the bvecs components as appropriate, since it changes the voxel axes.

> 翻译：bvecs 使用放射学体素约定，这是 FSL 内部使用的体素约定，早于 NIFTI（即，它是旧的 Analyze 约定）。如果图像具有放射学存储方向（qform/sform 的行列式为负），则 NIFTI 体素和放射学体素是相同的。如果图像具有神经学存储方向（qform/sform 的行列式为正），则 NIFTI 体素需要在 x 轴上翻转（而不是 y 轴或 z 轴）才能获得放射学体素。像 dcm2niix 这样的工具会创建 bvecs 文件和图像，这些文件和图像具有一致的约定，并适合用于 FSL。应用 fslreorient2std 时需要根据适当的情况对 bvecs 组件进行排列和/或更改符号，因为它改变了体素轴。



## [If something's worth saying, should I say it three times?](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/diffusion/faq?id=if-something39s-worth-saying-should-i-say-it-three-times)

Yes - every volume in data requires an element in bvecs and bvals. If your input directory is in FDT standard form you can do a quick check for the correct dimensions of all your files using bedpostx_datacheck.

```bash
bedpostx_datacheck <dirname>
```

> 翻译：是的，数据中的每个体积都需要在 bvecs 和 bvals 中有一个对应的元素。如果您的输入目录符合 FDT 标准格式，可以使用 bedpostx_datacheck 快速检查所有文件的维度是否正确。

## [Do I need to normalise my bvecs?](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/diffusion/faq?id=do-i-need-to-normalise-my-bvecs)

No. All FDT programs that use bvecs (i.e. dtifit, bedpostx and qboot) will normalise the bvecs before fitting the models.

> 翻译：不是。所有使用 bvecs 的 FDT 程序（即 dtifit、bedpostx 和 qboot）在拟合模型之前都会对 bvecs 进行归一化。



# MRtrix论坛信息

## 1. [Mrtrix3 alternative for fslreorient2std? - General Discussion - MRtrix3 Community](https://community.mrtrix.org/t/mrtrix3-alternative-for-fslreorient2std/4627/2)

If you’re after resetting the orientation of the image axes to RAS+ (the NIfTI standard frame), while preserving the image anatomical orientation, then in MRtrix-speak you’ll want to reset the strides – which you can do with a simple `mrconvert` call:

> 如果您想将图像轴的方向重置为 RAS+（NIfTI 标准框架），同时保留图像的解剖方向，那么在 MRtrix 的术语中，您需要重置步幅（strides）— 您可以通过简单的 `mrconvert` 命令来实现：

```apache
mrconvert input.mif -strides 1,2,3 output.mif
```

(the example is for `.mif` images, but this works for all supported image formats, including NIfTI).

> 翻译：（这个例子是针对 `.mif` 图像的，但这适用于所有支持的图像格式，包括 NIfTI）。

------

I should also add that if you’re applying this on NIfTI DWI data with associated bvecs/bvals, it is essential that you also apply the corresponding modifications to the bvecs. To do this is a bit cumbersome – one of the reasons we advocate the use of the `.mif` format:

> 翻译：我还应该补充一点，如果您在带有相关 bvecs/bvals 的 NIfTI DWI 数据上应用此操作，那么确保对 bvecs 进行相应的修改是至关重要的。这样做有点麻烦，这也是我们提倡使用 `.mif` 格式的原因之一。

```apache
mrconvert input.nii -fslgrad bvecs bvals -strides 1,2,3 output.mif -export_grad_fsl bvecs_out bvals_out
```


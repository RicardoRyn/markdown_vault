计算FA，ADC等值需要dwi数据（`.mif`格式文件），即整合好`.bval`和`.bvec`的弥散`.nii`文件

然后需要全脑mask文件

首先利用`dwi2tensor`命令生成**tensor**，键入：

```bash
dwi2tensor -mask mask.mif DTI.mif dt.mif
```

> 输出`dt.mif`文件，及tensor
>
> **tensor**翻译为**张量**，可以理解为储存影像信息的一个矩阵，但和矩阵也不完全一样
>
> dwi是dwi，运用张量技术才称为dt，dti

最后利用tensor来生成FA，ADC等值，用的是`tensor2metric`命令，键入：

```bash
tensor2metric -fa fa.mif -adc adc.mif dt.mif
```

> 输入为`dt.mif`
>
> 输出`fa.mif`和`adc.mif`文件


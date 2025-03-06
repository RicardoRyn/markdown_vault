# 在已经有非线性转换文件之后，应用该转换文件

```bash
applywarp -r T1w_acpc_dc_restore_brain.nii.gz \  # 参考个体t1
	-i Glasser_atlas_resample_MRtirx.nii.gz \  # 输入标准图集
	-w standard2acpc_dc.nii.gz \  # 指定转换文件
	-o rm_rjx.nii.gz \  # 生成个体图集
	--interp=nn
```

但是得到的`rm_rjx.nii.gz`文件并不能很好的和`T1w_acpc_dc_restore_brain.nii.gz`匹配，而是有位移

猜测还需要进行`FLIRT`

```bash
flirt \
	-in rm_rjx.nii.gz \  # 输入没有完全对齐的个体图集
	-ref T1w_acpc_dc_restore_brain.nii.gz \  # 参考个体t1
	-out rm_rjx1.nii.gz \  # 生成完全对齐的个体图集
	-omat rm_rjx2subj.mat \  # 生成从“没有完全对齐”到“完全对齐”的线性转换文件
	-dof 6 \
	-interp nearestneighbour
```


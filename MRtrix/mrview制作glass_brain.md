```shell
mrconvert mask.nii.gz mask.mif

# 然后高斯平滑
mrfilter mask.mif \
	smooth -stdev 2 \
	mask_smooth.mif
	
# 卡掉平滑后voxel值过小的voxel
mrthreshold mask_smooth.mif \
	-abs 0.5 \
	mask_smooth_thres.mif

# 扩大
maskfilter mask_smooth_thres.mif dilate \
	-npass 2 \
	mask_smooth_thres_dilated.mif
	
# 扩大的mask 减去 原mask 得到的中空脑子就是 glass_brain
mrcalc mask_smooth_thres_dilated.mif \
	mask_smooth_thres.mif -subtract \
	glass_brain.mif
	
# 最后在 View options中的 alpha 中调小值 就可以呈现 glass_brain 了
```


# wb_command 实用命令

```bash
# 将.nii的volume文件，转换成可以在surface上看的.gii文件
# 一些选项：
# ”-volume-roi mask.nii.gz“类似于mask的作用，只用这个mask里的voxels来map

# 常用实例：
# 算法“-trilinear”
wb_command -volume-to-surface-mapping \
	rm_rjx_lh_hMT+.nii.gz \  # 输入
	Native/103818.L.midthickness.native.surf.gii \  # 只推荐用这个
	rm_rjx_hMT+.L.func.gii \  # 输出
	-trilinear
	
# 算法“-ribbon-constrained”
wb_command -volume-to-surface-mapping \
	rm_rjx_lh_hMT+.nii.gz \
	Native/103818.L.midthickness.native.surf.gii \
	rm_rjx_hMT+.L.func.gii \
	-ribbon-constrained \
	Native/103818.L.white.native.surf.gii \
	Native/103818.L.pial.native.surf.gii
	
# 算法“-enclosing”，voxel上是多少，对应的vertex就是多少（我觉得适用于图集）fannot
wb_command -volume-to-surface-mapping \
	lh_cluster_resample2t1.nii.gz \
	Native/103818.L.midthickness.native.surf.gii \
	lh_cluster.shape.gii \
	-enclosing
	
# 算法“-myelin-style”（推荐，我猜测HCP的髓鞘化表面文件就是这么计算的）
wb_command -volume-to-surface-mapping \
	rm_rjx_lh_hMT+.nii.gz \  # 输入volume文件
	Native/103818.L.midthickness.native.surf.gii \  # 输入surface文件（只推荐使用midthickness文件）
	rm_rjx_hMT+.L.myelin_style.func.gii \  # 生成surface文件
	-myelin-style \
	ribbon.nii.gz \
	../MNINonLinear/Native/103818.L.thickness.native.shape.gii \  # 表征皮层厚度的.gii文件
	1  # 高斯核，单位mm

# 方便复制
wb_command -volume-to-surface-mapping rm_rjx_lh_hMT+.nii.gz Native/103818.L.midthickness.native.surf.gii rm_rjx_hMT+.L.myelin_style.func.gii -myelin-style ribbon.nii.gz ../MNINonLinear/Native/103818.L.thickness.native.shape.gii 1
```



```bash
# 将.dlabel.nii的surface图集label文件，转换成可以在surface上显示单个ROI的.scalar.nii文件
# 目的：在surface上，我只想显示MT，不想显示其他脑区
wb_command -cifti-all-labels-to-rois \
	103818.aparc.a2009s.native.dlabel.nii \
	1 \
	aparc.a2009s.dscalar.nii
```



```bash
# 将.label.gii转换为.func.gii文件
# 但是只能转一个ROI，即一个ROI是一个.func.gii文件
wb_command -gifti-label-to-roi \
	lh_MST.label.gii \  # 输入的.label.gii文件
	rm_rjx.func.gii \  # 输出得到的.func.gii文件
	-name L_MST_ROI  # 该.label.gii文件中对应的ROI的label
```



```bash
# 将.label.gii转换为.shape.gii文件
# 所有ROI都在一个.shape.gii文件中
wb_command -gifti-convert \
	ASCII \
	lh_charm5.label.gii \
	lh_charm5.shape.gii
```



```bash
# 将.label.gii文件转换成.nii的volume文件

# -nearest-vertex算法
wb_command -label-to-volume-mapping \
	lh_MST.label.gii \  # 输入的.label.gii文件
	103818.L.midthickness.32k_fs_LR.surf.gii \  # 参考的.surf.gii文件，需要有一致的vertex。注意该.surf.gii（T1w/fsaverage_LR32k文件夹下的，不是MNINonLinear/fsaverage_LR32k文件夹下的）必须和下面的brain.nii.gz在一个空间上
	brain.nii.gz \  # 参考volume文件，和上一个.surf.gii文件在一个空间上
	rm_rjx.nii.gz \  # 输出结果的volume文件
	-nearest-vertex 1  # 算法，指定从surface map到volume，map多远，单位mm

# -ribbon-constrained算法（推荐）
wb_command -label-to-volume-mapping \
	lh_MST.label.gii \
	103818.L.midthickness.32k_fs_LR.surf.gii \
	brain.nii.gz \
	rm_rjx.nii.gz \
	-ribbon-constrained 103818.L.white.32k_fs_LR.surf.gii 103818.L.pial.32k_fs_LR.surf.gii

```



```bash
# 输入white和pial的surface文件，最后可以计算得到ribbon.nii.gz
wb_command -create-signed-distance-volume \
	103818.L.white.native.surf.gii \  # 输入之一
	rfMRI_REST1_LR_SBRef.nii.gz \  # 输入之一，参考用的.nii.gz文件
	103818.L.white.native.nii.gz
wb_command -create-signed-distance-volume \
    103818.L.pial.native.surf.gii \  # 输入之一
    rfMRI_REST1_LR_SBRef.nii.gz \
    103818.L.pial.native.nii.gz
# white
fslmaths 103818.L.white.native.nii.gz \
  -thr 0 -bin -mul 255 \
  103818.L.white_thr0.native.nii.gz
fslmaths 103818.L.white_thr0.native.nii.gz \
  -bin \
  103818.L.white_thr0.native.nii.gz
# pial
fslmaths 103818.L.pial.native.nii.gz \
  -uthr 0 -abs -bin -mul 255 \
  103818.L.pial_uthr0.native.nii.gz
fslmaths 103818.L.pial_uthr0.native.nii.gz \
  -bin \
  103818.L.pial_uthr0.native.nii.gz
# 计算生成ribbon.nii.gz
fslmaths 103818.L.pial_uthr0.native.nii.gz \
  -mas 103818.L.white_thr0.native.nii.gz -mul 255 \
  103818.L.ribbon.nii.gz
fslmaths 103818.L.ribbon.nii.gz \
  -bin -mul 1 \
  103818.L.ribbon.nii.gz  # 最后输出文件
```



```bash
# 从cifti文件和gifti文件生成border

# 从cifti
wb_command -cifti-label-to-border \
	Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii \
	-border \
	Q1-Q6_RelatedParcellation210.L.very_inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii \
	L.rm_rjx.border
# 从gifti
wb_command -label-to-border \
	L.white_surface.inf_300.surf.gii R.charm5.label.gii \
	L.rm_rjx.border
```



```bash
# 在surface上利用一个mask，卡掉白质里的值
wb_command -metric-mask \                      
        "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii \
        "$AtlasSpaceNativeFolder"/"$Subject"."$Hemisphere".roi.native.shape.gii \
        "$WorkingDirectory"/"$Hemisphere"."$Map".native.func.gii
```

# 将nii.gz图集文件转换成.label.giisurface文件

```bash
#!/bin/bash                                                                                                                               
 
# 这个脚本用来从volume图集（.nii.gz），生成对应的surface图集（.label.gii）
# 输入文件：
# 1. CHARM_5_MRtrix.nii.gz
# 2. L.mid_surface.surf.gii
# 3. R.mid_surface.surf.gii
# 4. macaque_charm5_LUT_wb.txt
 
for hemi in L R; do
 
    # 根据volume图集文件生成surface mask文件（.shape.gii）
    wb_command -volume-to-surface-mapping \
        CHARM_6_MRtrix.nii.gz \
        ${hemi}.mid_surface.surf.gii \
        rm_${hemi}.charm6.shape.gii \
        -enclosing
 
    # 给生成的mask填洞，再移除孤顶点
    wb_command -metric-fill-holes \
        ${hemi}.mid_surface.surf.gii \
        rm_${hemi}.charm6.shape.gii \
        rm_${hemi}.charm6_filled.shape.gii
    wb_command -metric-remove-islands \
        ${hemi}.mid_surface.surf.gii \
        rm_${hemi}.charm6_filled.shape.gii \
        rm_${hemi}.charm6_filled_rmislands.shape.gii
 
    # 把mask dilate再erode
    wb_command -metric-dilate \
        rm_${hemi}.charm6_filled_rmislands.shape.gii \
        ${hemi}.mid_surface.surf.gii \
        3 \
        rm_${hemi}.charm6_filled_rmislands_dilate3.shape.gii
    wb_command -metric-erode \
        rm_${hemi}.charm6_filled_rmislands_dilate3.shape.gii \
        ${hemi}.mid_surface.surf.gii \
        3 \
        rm_${hemi}.charm6_filled_rmislands_dilate3_erode3.shape.gii
 
    # 把图集dilate 10倍，再乘以mask
    wb_command -metric-dilate \
        rm_${hemi}.charm6.shape.gii \
        ${hemi}.mid_surface.surf.gii \
        10 \
        rm_${hemi}.charm6_dilate10.shape.gii \
        -nearest
    wb_command -metric-mask \
        rm_${hemi}.charm6_dilate10.shape.gii\
        rm_${hemi}.charm6_filled_rmislands_dilate3_erode3.shape.gii \
        rm_${hemi}.charm6.shape.gii
 
    # 
    wb_command -metric-label-import \
        rm_${hemi}.charm6.shape.gii \
        macaque_charm6_LUT_wb.txt \
        ${hemi}.charm6.label.gii
 
done
rm rm_*
```

# 将Freesurfer的.annot文件转换成.label.gii文件

```bash
#!/bin/bash                                                                                                                               
 
mris_convert --annot lh.charm5_atlas.annot \
    ../lh.mid_surface.surf.gii \
    lh_charm5.label.gii
mris_convert --annot rh.charm5_atlas.annot \
    ../rh.mid_surface.surf.gii \
    rh_charm5.label.gii
 
wb_command -set-structure lh_charm5.label.gii CORTEX_LEFT
wb_command -set-structure rh_charm5.label.gii CORTEX_RIGHT
```

# 将.label.gii文件转换成.nii.gz文件

```bash
#!/bin/bash


wb_command -label-to-volume-mapping \
	fsaverage.L.Glasser.32k_fs_LR.label.gii \
	101309.L.midthickness.32k_fs_LR.surf.gii \
	T1w_acpc_dc_restore_brain.nii.gz \
	Glasser_atlas.nii.gz \
	-ribbon-constrained \
	101309.L.white.32k_fs_LR.surf.gii \
	101309.L.pial.32k_fs_LR.surf.gii
	

```


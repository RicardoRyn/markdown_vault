# mri_label2vol

已知HCP被试的freesurfer文件夹

然后在`label/`中发现名为`lh.MT.thresh.label`的文件

现在想转换成volume文件，能在afni上查看的那种

```bash
# 根据Freesurfer的.label文件，转换成.nii.gz文件
mri_label2vol --label lh.MT.thresh.label \
            --temp brain.nii.gz \
            --reg ${subj}/mri/transforms/hires21mm.dat \  # 指定转换方法，hires应该是high resolution的意思
            --o lh_hMT+_from_BA_atlas.nii.gz	
```



```bash
# 根据Freesurfer的.annot文件，转换成wb适用的.label.gii文件
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



```bash
# 根据Freesurfer的.label文件，转换成wb适用的.shape.gii文件
mris_convert --label lh.cortex.label cortex \
	SC_06018.L.midthickness.native.surf.gii \
	SC_06018.L.roi.native.shape.gii

wb_command -set-structure SC_06018.L.roi.native.shape.gii CORTEX_LEFT
```

```bash
# 根据wb的.label.gii文件，转换成freesurfer适用的.annot文件
# 要求存在./../label文件夹
mris_convert --annot ./L.charm5.label.gii \
	./L.mid_surface.surf.gii \
	lh.charm5.annot  # 最后生成的这个文件会保存到./../label文件夹中
```


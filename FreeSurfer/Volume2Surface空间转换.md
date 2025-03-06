

# 这里用到的sub_111312_t1.nii.gz是由FreeSuerfer的mri文件夹中的brain.mgz转换过来的，不能直接用原始被试的t1.nii.gz

原因可能是两个文件voxel大小不一样



需要准备:

1. 个体`sub_111312_t1.nii.gz`（必须是剥完头皮的）
2. 个体`roi_lh_MST.nii.gz`（MST是一个脑区ROI，需要和`sub_111312_t1.nii.gz`在同一空间）

## 第一步

将个体T1配准到Freesurfer标准模板上，获得个体volume到标准surface的转换矩阵

推荐使用FreeSurfer的模板fsaverage

可以使用FSL的fslregister和SPM的spmregister命令，这里使用FSL的：

```bash
cd $SUBJECTS_DIR/fsaverage/surf  # 后续生成的文件都在这个文件夹下
fslregister --s fsaverage --mov /path/to/sub_111312_t1.nii.gz --reg t1_2_fsaverage.dat
```

>FreeSurfer的命令
>
>--s是输入，表示被试ID
>
>--mov是输入，表示需要用来配准的volume（即需要扭曲的volume）
>
>--reg是输出，表示转换矩阵



## 第二步

利用转换矩阵，将volum空间的ROI配准到标准模板的surface上

```bash
cd $SUBJECTS_DIR/fsaverage/surf  # 如果是当前文件夹下，就不需要更改
mri_vol2surf --mov /path/to/roi_lh_MST.nii.gz --reg t1_2_fsaverage.dat --projdist-max 0 1 0.1 --interp nearest --hemi lh --out lh.fsaverage.MST.mgz
```

>--mov是输入，表示需要转换的ROI的volume
>
>--reg是输入，之前得到的转换矩阵
>
>--projdist-max是输入，表示映射距离（mm），后面跟3个值，分别是min、max、del
>
>--interp是输入，表示插值方法
>
>--hemi是输入，lh或者rh表示左右半脑
>
>--out是输出，获得转换后的文件

## 第三步

查看文件

打开freeview，打开fsaverage模板的lh.white或者其他surface文件，然后在overlay中选择`load generic`然后打开`lh.fsaverage.MST.mgz`文件

## 第四步

将个体数据配准到fsaverage标准空间中得到`lh.thickness.fsaverage.mgz`

```bash
cd $SUBJECTS_DIR/subjid/surf
mri_surf2surf --s sub_111312 --trgsubject fsaverage --hemi lh --sval lh.thickness --tval lh.thickness.fsaverage.mgz
```

## 第五步

从`lh.thickness.fsaverage.mgz`中提取lh.fsaverage.MST的信息

```bash
cd $SUBJECTS_DIR/subjid/surf
mri_segstats --seg $SUBJECTS_DIR/fsaverage/surf/lh.fsaverage.MST.mgz --in lh.thickness.fsaverage.mgz --sum segstats_lh_MST.txt
```



# 自己写，不用fsaverage的模板，使用sub_111312个体surface

## 第一步

volume到surface的转换矩阵

```bash
cd $SUBJECTS_DIR/sub_111312/surf  # 后续生成的文件都在这个文件夹下
fslregister --s sub_111312 --mov ../rjx_ANTs/FS_t1.nii.gz --reg t1_2_surface.dat
```

## 第二步

查看ROI位置对不对

```bash
tkmedit sub_111312 T1.mgz -overlay ../rjx_ANTs/roi_lh_MST.nii.gz -overlay-reg t1_2_surface.dat -fthresh 0.5 -surface lh.white -aux-surface rh.white
```

## 第三步

```bash
mri_vol2surf --mov ../rjx_ANTs/roi_lh_MST.nii.gz --reg t1_2_surface.dat --projdist-max 0 1 0.1 --interp nearest --hemi lh --out lh.rjx_MST.mgz  # 这个输出在当前文件夹下，也就是surf文件夹下
```

## 第四步

提取体积信息

```bash
mri_segstats --seg $SUBJECTS_DIR/sub_111312/surf/lh.rjx_MST.mgz --in lh.thickness --sum segstats_lh_MST.txt
```


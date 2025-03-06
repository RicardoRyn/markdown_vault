在每个被试的结果文件夹的`stats`文件夹中，都有根据Destrieux atlas和Desikan-Killiany atlas得到的左右半脑的parcellation，例如`lh.aparc.annot`对应Desikan-Killiany atlas，而`lh.aparc.a2009s.annot`对应Destrieux atlas

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/11_Atlas_Comparison.png" alt="../../_images/11_Atlas_Comparison.png" style="zoom: 25%;" />

Destrieux atlas分区更多，适合细粒度更高的研究（finer-grained analyses）

而segmentation包含在`aseg.stats`文件中，并没有针对不同atlas单独分段的文件

# 使用asegstats2table和aparcstats2table提取数据

`asegstats2table`和`aparcstats2table`都需要被试列表和测量结构

---

例如`asegstats2table`，键入：

```bash
python2 $FREESURFER_HOME/bin/asegstats2table --subjects sub-101 sub-103 --common-segs --meas volume --stats=aseg.stats --table=segstats.txt  # 该命令有一个bug，必须用python2才能正常运行，详情见下文
```

> `--subjects`后跟被试名字列表
>
> `--common-segs`表示输出所有被试共有的segmentation，即如果有些被试有，但有些被试没有，不会报错，只会输出都具有的segmentation
>
> `--meas`表示想要提取的structural measurement，默认是volume，还有`mean`和`std`
>
> `--stats`指定从哪个文件中提取segmentation
>
> `--table`输出一个text文件

---

同样的`aparcstats2table`键入：

```bash
python2 $FREESURFER_HOME/bin/aparcstats2table --subjects sub-101 sub-103 --hemi lh --meas thickness --parc=aparc --tablefile=aparc.txt
```

> 多出了几个选项
>
> `--hemi`指定左右半球
>
> `--meas`后可以跟`thickness`，`volume`，`area`，`meancurv`
>
> `--parc`后跟`aparc`，表示Desikan-Killinay atlas，也可以跟`aparc.a2009s`，表示Destrieux atlas
>
> `--tablefile`输出一个text文件

---

这些命令的输出都是`.tsv`（tab-delimited text files），可以用excel读取，然后可以用其他统计软件做分析



***实践无效，可能与python2有关？但是切换了python2，也没有用***

切换python2的方法：

```bash
echo alias python=python2 >> ~/.bashrc
source ~/.bashrc
```

查看python版本：

```bash
python --version
python2 --version
python3 --version
```

***破案了，确实是python2的原因，但是上述切换python2的方法可能不行，正确方法见这封回信：***

```bash
Hi,

This is a bug introduced by python3, you must run this script with python2 by 
either modifying the first line to say:
#!/usr/bin/env python2

or by running:
python2 $FREESURFER_HOME/bin/asegstats2table --subjects baseline 12m 24m 36m 
--meas volume --tablefile aseg_stats.txt

best,
Andrew
```



# ROI

以下脚本是作者创建的将volumetric ROI重采样到surface上，然后从该ROI中提取structual measurements的代码，适用于大部分工作：

```bash
#!/bin/tcsh

setenv SUBJECTS_DIR `pwd`

#Create 5mm sphere ROI with 3dUndump; ROI_file.txt contains x-, y-, and z-coordinates for center of sphere (e.g., 0 30 20)
3dUndump -srad 5 -prefix S2.nii -master MNI_caez*+tlrc.HEAD -orient LPI -xyz ROI_file.txt  # 这部分内容去看AFNI教程里ROI的画法

#View in tkmedit
tkmedit -f MNI_caez_N27.nii -overlay S2.nii -fthresh 0.5

#Register anatomical template to fsaverage (FreeSurfer template)
fslregister --s fsaverage --mov MNI_caez_N27.nii --reg tmp.dat

#View ROI on fsaverage
tkmedit fsaverage T1.mgz -overlay S2.nii -overlay-reg tmp.dat -fthresh 0.5 -surface lh.white -aux-surface rh.white


#Map ROI to fsaverage surface
mri_vol2surf --mov S2.nii \
        --reg tmp.dat \
        --projdist-max 0 1 0.1 \
        --interp nearest \
        --hemi lh \
        --out lh.fsaverage.S2.mgh \
        --noreshape

#Check how well the ROI maps onto the inflated surface
tksurfer fsaverage lh inflated -overlay lh.fsaverage.S2.mgh -fthresh 0.5
```

---

相反的，也有可能想根据surface上的ROI重采样一个volume，然后提取volume里的数据

**本例：从FreeSurfer中提取颞上（superior temporal）ROI，然后重采样到volume space上**

首先需要创建名为`register.dat`的registration文件，用到FreeSurfer的`tkregister2`命令：

```bash
tkregister2 --mov beta_0001.nii --s subject --noedit --regheader --reg register.dat
```

> `beta_0001.nii`是被试原生空间中创建的beta map（Where “beta_0001.nii” is a beta map created in the subject’s native space）
>
> `subject`是recon-all预处理过的被试名字

然后用`mri_label2vol`命令将surface ROI转换到体积空间中：

```bash
mri_label2vol --label lh.superiortemporal.label --temp beta_0001.nii --subject subject --hemi lh --fillthresh .9 --proj frac 0 1 .1 --reg register.dat --o $PWD/stgnew.nii
```

> 最后的`stgnew.nii`文件即由surface ROI创建出来的volumetric ROI
# 获得diff到standard的转换

一开始diff像就是**剥了头皮**的，所以diff应该和brain**线性对齐**

```bash
flirt -ref brain.nii.gz -in fdt_FA.nii.gz -omat diff2struct.mat
```

试一试生成的diff2struct.nii.gz是不是真的有用键入：

```bash
flirt -in fdt_FA.nii.gz -ref brain.nii.gz -omat diff2struct.mat -out rjx.nii.gz
```

看了看rjx.nii.gz文件，没有问题

---

然后进行struct2standard的非线性配准，但是首先需要先线性配准一下，线性配准用**剥头皮**的数据

```bash
flirt -ref MNI152_T1_2009c.nii.gz -in brain.nii.gz -omat struct2standard.mat -out rjx.nii.gz
```

看了看rjx.nii.gz文件，没有问题

---

用**剥头皮**的数据进行非线性配准

```bash
fnirt --ref=MNI152_T1_2009c.nii.gz --in=brain.nii.gz --aff=struc2standard.mat --cout=struc2standard.nii.gz
```

再看看生成的warp，键入：

```bash
applywarp --ref=MNI152_T1_2009c.nii.gz --in=brain.nii.gz --warp=struct2standard.nii.gz --out=rjx.nii.gz
```

这个就没问题了，***那以后flirt和fnirt都不用带头皮的数据了***

---

现在需要把diff2stuct.mat和struct2standard.nii.gz合并成一个文件，键入：

```bash
convertwarp --ref=MNI152_T1_2009c.nii.gz --premat=diff2struct.mat --warp1=struct2standard.nii.gz --out diff2standard.nii.gz --relout
```

试一试生成的diff2standard.nii.gz是不是真的有用，键入：

```bash
applywarp --ref=MNI152_T1_2009c.nii.gz --in=dti_FA.nii.gz --warp=diff2standard.nii.gz --out=rjx.nii.gz --rel
```

没问题，这个warp有用

---

现在创建这个warp的逆，即standard2diff.nii.gz

```bash
invwarp --ref=dti_FA.nii.gz --warp=diff2standard.nii.gz --out=standard2diff.nii.gz
```



# 跑XTRACT

然后就可以跑XTRACT了

```bash
xtract -bpx ./orig.bedpostX -out xtract -species HUMAN -gpu -stdwarp standard2diff.nii.gz diff2standard.nii.gz
```



---

# XTRACT

xtract是一个命令行工具来提取一组”仔细解剖的tracts“，既可以提取人（human）的，也可以提取猴子（macaque）的

xtract也可以用来你自己的tractography protocol，你只需要在标准空间中（例如MNI152空间）定义一组mask

xtract读取 标准空间的protocol然后在被试的**原生空间**中执行tractography（probtrackx2），生成的被试个体的tracts既可以在被试的**原生空间**，也可以在**标准空间**。你需要的只是提供”交叉纤维拟合数据“（bedpostx）和弥散像到标准空间的registration warp field（以及它们的逆）

xtract atlases可以用fsleyes查看

```bash
Usage:
     xtract -bpx <bedpostX_dir> -out <outputDir> -species <SPECIES> [options]
     xtract -bpx <bedpostX_dir> -out <outputDir> -species CUSTOM -str <file> -p <folder> -stdref <reference> [options]
     xtract -list

     Compulsory arguments:

        -bpx <folder>                          Path to bedpostx folder
        -out <folder>                          Path to output folder
        -species <SPECIES>                     One of HUMAN or MACAQUE or CUSTOM

     If -species CUSTOM:
       -str <file>                             Structures file (format: format: <tractName> [samples=1], 1 means 1000, '#' to skip lines)
       -p <folder>                             Protocols folder (all masks in same standard space)
       -stdref <reference>                     Standard space reference image

     Optional arguments:
        -list                                  List the tract names used in XTRACT
        -str <file>                            Structures file (format: <tractName> per line OR format: <tractName> [samples=1], 1 means 1000, '#' to skip lines)
        -p <folder>                            Protocols folder (all masks in same standard space) (Default=$FSLDIR/data/xtract_data/<SPECIES>)
        -stdwarp <std2diff> <diff2std>         Standard2diff and Diff2standard transforms (Default=bedpostx_dir/xfms/{standard2diff,diff2standard})
        -stdref <reference>                    Standard space reference image (Default = $FSLDIR/data/standard/MNI152_T1_1mm [HUMAN], $datadir/standard/F99/mri/struct_brain [MACAQUE])
        -gpu                                   Use GPU version
        -res <mm>                              Output resolution (Default=same as in protocol folders unless '-native' used)
        -ptx_options <options.txt>             Pass extra probtrackx2 options as a text file to override defaults, e.g. --steplength=0.2 --distthresh=10)

        And EITHER:
        -native                                Run tractography in native (diffusion) space

        OR:
        -ref <refimage> <diff2ref> <ref2diff>  Reference image for running tractography in reference space, Diff2Reference and Reference2Diff transforms
```

xtract会自动检测，如果`$SGE_ROOT`被设定，或者使用`FSL_SUB`。***最好使用gpu版本***

# XTRACT的output

在输出文件夹下，有：

- `commands.txt`：xtract处理使用的命令
- `logs`：文件夹，包含了probtrackx的log文件
- `tracts`：文件夹，包含了tractography的结果，其中又包含：
  - `tractsName`：对应指定的tract，里面又包含：
    - `waytotal`：txt文本，包含了有效的streamlines的数量
    - `density.nii.gz`：”纤维概率分布“的nifti格式文件
    - `density_lenths.nii.gz`：纤维长度的你nifti格式文件，每个voxel表示平均streamline长度。是`-ompl` probtrackx选项
    - ***`densityNorm.nii.gz`：waytotal标准化纤维概率分布的nifti格式文件。即`density.nii.gz`文件除以总的有效streamlines数量得到***
    - 如果protocol中有要求”反向种子设定“：
      - `tractsInv`：包含要求的从种子反向run的目录
      - `sum_waytotal`和`sum_density.nii.gz`：waytotal的和，纤维概率分布的和

如果protocol中有`-native`选项，就会有以下文件夹：

- `masks`：一个文件夹，包含了：
  - `tractName`：一个文件夹，里面包含了每个原生空间protocol的mask

***所有输出里面，最主要的就是`densityNorm.nii.gz`文件***

xtract的预处理过程包括：

1. BET剥头皮
2. topup磁敏感校正
3. eddy涡流校正
4. bedpostx交叉纤维模型拟合
5. 非线性配准（人用的MNI152，猴用的F99）

然后就可以跑xtract了

# 标准空间

运行xtract的时候，使用`-species`选项，会提取以下束：

| **Tract**                            | **Abbreviation** |
| ------------------------------------ | ---------------- |
| Arcuate Fasciculus                   | AF               |
| Acoustic Radiation                   | AR               |
| Anterior Thalamic Radiation          | ATR              |
| Cingulum subsection : Dorsal         | CBD              |
| Cingulum subsection : Peri-genual    | CBP              |
| Cingulum subsection : Temporal       | CBT              |
| Corticospinal Tract                  | CST              |
| Frontal Aslant                       | FA               |
| Forceps Major                        | FMA              |
| Forceps Minor                        | FMI              |
| Fornix                               | FX               |
| Inferior Longitudinal Fasciculus     | ILF              |
| Inferior Fronto-Occipital Fasciculus | IFO              |
| Middle Cerebellar Peduncle           | MCP              |
| Middle Longitudinal Fasciculuc       | MdLF             |
| Optic Radiation                      | OR               |
| Superior Thalamic Radiation          | STR              |
| Superior Longitudinal Fasciculus 1   | SLF1             |
| Superior Longitudinal Fasciculus 2   | SLF2             |
| Superior Longitudinal Fasciculus 3   | SLF3             |
| Anterior Commissure                  | AC               |
| Uncinate Fasciculus                  | UF               |
| Vertical Occipital Fasciculus        | VOF              |

# mcc Xtract步骤

## 第一步

已有人/猴同源42个tracts的图集

这里所谓的图集，其实是名为`seed.nii`、`target.nii.gz`、`stop.nii.gz`、`exclude.nii.gz`的文件

将这些文件转换到个体空间上，然后使用`probtractx2`或者`probtractx2_gpu`实时生成

有些tract，还需要将seed和target互换位置，再生成一遍（即invert选项）

```bash
# 一、对于没有invert选项的tract
# 1. ptx opts1
probtractx2 \
    # 默认选项
    -s ${subjfsl}/Diffusion.bedpostX/merged \
    -m ${subjfsl}/Diffusion.bedpostX/nodif_brain_mask \
    -V 1 --loopcheck --forcedir --opd --ompl \
    --seedref=${ref} \
    --sampvox=1 \
    --randfib=1 \
	# 特定tract选项
    --stop=${stop} \  # 如果有
    --avoid=${exclude} \  # 如果有
    --nsamples=${nseed} -x ${seed} \  # 一定有
    --waypoints=${subjresults}/xtra/tracts/${struct}/targets.txt \  # 一定有
    # 输出结果
    -o density --dir=${subjresults}/xtra/tracts/${struct}
# 2. normcmd
fslmaths "${subjresults}/xtra/tracts/${struct}/density" \
    -div `cat "${subjresults}/xtra/tracts/${struct}/waytotal"` \
    "${subjresults}/xtra/tracts/${struct}/densityNorm"

# 二、对于有invert选项的tract
# 1. ptx opts1
probtractx2 \
    # 默认选项
    -s ${subjfsl}/Diffusion.bedpostX/merged \
    -m ${subjfsl}/Diffusion.bedpostX/nodif_brain_mask \
    -V 1 --loopcheck --forcedir --opd --ompl \
    --seedref=${ref} \
    --sampvox=1 \
    --randfib=1 \
    # 特定tract选项
    --stop=${stop} \  # 如果有
    --avoid=${exclude} \  # 如果有
    --nsamples=${nseed} -x ${seed} \  # 一定有
    --waypoints=${subjresults}/xtra/tracts/${struct}/targets.txt \  # 一定有
    # 输出结果
    -o density --dir=${subjresults}/xtra/tracts/${struct}
# 2. ptx opts2
probtractx2 \
    # 默认选项
    -s ${subjfsl}/Diffusion.bedpostX/merged \
    -m ${subjfsl}/Diffusion.bedpostX/nodif_brain_mask \
    -V 1 --loopcheck --forcedir --opd --ompl \
    --seedref=${ref} \
    --sampvox=1 \
    --randfib=1 \
    # 特定tract选项（互换seed和target）
    --stop=${stop} \  # 如果有
    --avoid=${exclude} \  # 如果有
    --nsamples="${nseed}" -x "${target}" \  # 一定有，而且只有一个target.nii.gz文件
    --waypoints="${seed}" \  # 一定有
    # 输出结果
    -o density --dir="${subjresults}/xtra/tracts/${struct}/tractsInv"
# 3. mergecmd
fslmaths "${subjresults}/xtra/tracts/${struct}/density" \
    -add "${subjresults}/xtra/tracts/${struct}/tractsInv/density" \
    "${subjresults}/xtra/tracts/${struct}/sum_density"
# 4. addcmd
echo "scale=5; `cat "${subjresults}/xtra/tracts/${struct}/waytotal"` + `cat "${subjresults}/xtra/tracts/${struct}/tractsInv/waytotal"` "|bc > "${subjresults}/xtra/tracts/${struct}/sum_waytotal"
# 5. normcmd
fslmaths "${subjresults}/xtra/tracts/${struct}/sum_density" \
    -div `cat "${subjresults}/xtra/tracts/${struct}/sum_waytotal"` \
    "${subjresults}/xtra/tracts/${struct}/densityNorm"
```

## 第二步

`xtract_blueprit`需要`xtract`中一模一样的warp文件

`xtract_blueprit`支持surface（.gii）和volume（.nii）

1. 对于灰质皮层，一般用surface，用灰白质交界处作为seed；
   1. 如果用surface，结果是.dscalar.nii
   2. 如果用volume，结果是4D的.nii
2. 对于皮之下结构，一般用volume

需要输入：

1. bedpostx文件夹
2. xtract文件夹
3. seeds，用逗号分隔的文件，例如`L.white.surf.gii,R.white.surf.gii`
4. warps，标准空间图像，以及个体到标准空间的转换文件，例如`MNI152.nii.gz standard2diff.nii.gz diff2standard.nii.gz`
5. target，全脑白质target .nii mask（使用`-res`设置target的分辨率）

FSL组建议跑全脑，先提供左边再提供右边，而且建议使用一个“medial wall”来限制blueprint到灰质表面。

`xtract_blueprit`可以使用`-gpu`进行GPU版本

```bash
xtract_blueprint \
	-bpx sub001/dMRI.bedpostx \
	-out sub001/blueprint \
	-xtract sub001/xtract \
    -warps MNI152_brain.nii.gz sub001/xtract2diff.nii.gz sub001/diff2xtract.nii.gz \
    -gpu \
    -seeds sub001/l.white.surf.gii \
    -rois sub001/l.temporal_lobe.shape.gii \
    -tract_list af_l,ilf_l,ifo_l,mdlf_l,slf3_l
```


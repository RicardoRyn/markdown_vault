创建完streamline map之后，需要创建connectome，来表征不同ROI之间连接，可以使用atlas

可以根据意愿选择atlas，本例中选用[FreeSurfer](https://andysbrainbook.readthedocs.io/en/latest/FreeSurfer/FS_ShortCourse/FS_11_ROIAnalysis.html#fs-11-roianalysis)中的图集，所以首先第一步重构被试结构像，键入：

```bash
recon-all -i ../anat/sub-CON02_ses-preop_T1w.nii.gz -s sub-CON02_recon -all
```

> 生成一个名为`sub-CON02_recon`的文件夹，保存在freesurfer默认被试文件夹中,即`/usr/local/freesurfer/subjects`里

可能需要几个小时

完成后根据[this chapter](https://andysbrainbook.readthedocs.io/en/latest/FreeSurfer/FS_ShortCourse/FS_12_FailureModes.html#fs-12-failuremodes)来进行质量检查

# 检查重构图像

***未完待续***

有时候被试的重构图中白质表面出现洞，这会影响灰质厚度和体积的计算，这也许会导致重构提前退出并报错，需要手动edit

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/12_Holes.png" alt="../../_images/12_Holes.png" style="zoom: 25%;" />

错误分2种：**Hard Failures**和**Soft Failures**

Hard Failures直接导致重构退出，可能由一下原因造成：

1. 没有磁盘读写权限（考虑使用`chmod`命令）
2. 磁盘空间不足
3. 头动过多

Soft Faliures不会导致重构退出，也可能并不报错，但质量检查时能够发现并需要纠正

1. 白质上有洞（White matter segmentation errors）
2. **重构完的白质灰质边界与原结构像的有巨大差异（Pial surface errors）**
3. **颅骨剥离错误（Skullstripping errors）**
4. **强度标准化错误（Intensity normalization errors）**
5. 拓扑错误（Topological defects）：指重构白质表面穿孔，还有false “handles” of grey matter that bridge gyri；这些都会出现在`surf`文件夹中，但随着FreeSurfer 6.0的发布，这些错误越来越罕见；它们也会在重构过程中自动修复；可以在freeview中加载`lh.smoothwm.nofix`和`lh.white`文件来看是如何修复的

![../../_images/12_WM_Pial_Surface_Errors.png](https://andysbrainbook.readthedocs.io/en/latest/_images/12_WM_Pial_Surface_Errors.png)

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/12_lh_smoothwm_nofix.png" alt="../../_images/12_lh_smoothwm_nofix.png" style="zoom: 25%;" />

另有一些由于被试健康问题引起的大脑图像重构错误这里不介绍，详情见[FreeSurfer page](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/WhiteMatterEdits_freeview)

---

上述错误1和错误5基本在重构过程中自动解决，错误2、3、4需要在质量检查之后手动去除

首先需要以T1像和brainmask为underlay，把2侧脑的白质和pial surface作为overlay，查看重构图像，定位到`dwi`文件夹中，键入：

```bash
freeview -v ./sub-CON02_recon/mri/T1.mgz \
./sub-CON02_recon/mri/brainmask.mgz \
-f ./sub-CON02_recon/surf/lh.pial:edgecolor=red \
./sub-CON02_recon/surf/lh.white:edgecolor=yellow \
./sub-CON02_recon/surf/rh.pial:edgecolor=red \
./sub-CON02_recon/surf/rh.white:edgecolor=yellow
```

> pial（软脑膜）边界用红色表示，白质边界用黄色表示

***未完待续***







# 创建Connectome

首先需要将FreeSurfer里的label转换成MRtrix能读懂的格式，使用的是`labelconvert`命令能将FreeSurfer的**分块（parcellation）**和**分段（segmentation）**转换成`.mif`文件，键入：

```bash
labelconvert sub-CON02_recon/mri/aparc+aseg.mgz \
             $FREESURFER_HOME/FreeSurferColorLUT.txt \
             /usr/local/mrtrix3/share/mrtrix3/labelconvert/fs_default.txt \
             sub-CON02_parcels.mif
```

>`labelconvert [ options ]  path_in lut_in lut_out image_out`
>
>1. 第一个文件是分好区的图像文件，即`aparc+aseg.mgz`
>2. 第二个文件是该分区对应的LUT（lookup table）文件，即FreeSurferColorLUT.txt
>3. 第三个文件是转换成MRtrix的LUT文件，是MRtrix自带的，不是这条命令生成的
>4. 第四个文件是输出的分区文件，对应转换的LUT文件，并换了一种格式

首先需要创建全脑的connectome，在每个atlas之间表示出streamline（本例中是84×84，应该和图集大小有关系），键入：

```bash
tck2connectome -symmetric -zero_diagonal -scale_invnodevol \
               -tck_weights_in sift_1M.txt \
               tracks_10M.tck \
               sub-CON02_parcels.mif \
               sub-CON02_parcels.csv \
               -out_assignment assignments_sub-CON02_parcels.csv
```

>`-symmetric`选项将会让下对角线（lower diagonal）与上对角线（upper diagonal）相同
>
>`-zero_diagonal`***不知道是啥***
>
>`-scale_invnodevol`选项将会根据节点大小的相反（the **inverse** of the size of the node）缩放（scale）连接组
>
>`-tck_weights_in`后跟的文件`sift_1M.txt`，表示大脑中不同ROI连接权重
>
>输入`tracks_10M.tck`
>
>从FreeSurfer得到的分块/分段文件（即atlas）`sub-CON02_parcels.mif`
>
>输出文件`sub-CON02_parcels.csv`
>
>另一个输出文件`assignments_sub-CON02_parcels.csv`

得到的两个文件都是`.csv`文件，即逗号分隔值文件，可以导入matlab里画出图查看

从打开matlab，定位到dwi文件夹中，键入：

```matlab
connectome = importdata('sub-CON02_parcels.csv');
imagesc(connectome)
```

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/08_ViewingConnectome.png" alt="../../_images/08_ViewingConnectome.png" style="zoom: 33%;" />

> 这种图，看一半就好了，要么看左下角，要么看右上角
>
> 全看的话，有两个明显的正方形（左上角和右下角），说明了半脑内显著的结构连接

如果觉得显示的不够清晰，可以键入：

```bash
imagesc(connectome, [0 1])
```

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/08_ViewingConnectome_Scaled.png" alt="../../_images/08_ViewingConnectome_Scaled.png" style="zoom: 25%;" />

---

到此，单个被试的DWI数据预处理以及connectome的建立全部完成


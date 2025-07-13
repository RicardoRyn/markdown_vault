目前已经使用`recon-all`完成了所有被试T1结构像的处理，量化了不同脑区灰质厚度和体积

皮质上分块称为**parcellations**，皮质下分段称为**segmentations**

其中只有皮质才会膨胀成inflation图，成为surface，而皮质下区域只会包含灰质体积测量（measurements of grey matter volume），而没有厚度（thickness）

和fMRI中比较voxel一样，这里我们比较vertics（顶点）；只要被试的surface都配准到标准空间（例如MNI），然后就可以看看组与组之间是否有显著差异

# 创建文件夹

首先需要将fsaverage模板复制到当前文件夹下，这里用的是FS文件夹，先定位到FS文件夹中，然后键入：

```bash
cp -R $FREESURFER_HOME/subjects/fsaverage .  # -R表示递归，复制所有子文件
```

然后修改FreeSurfer的被试文件夹，键入：

```bash
export SUBJECTS_DIR=`pwd`  # bash下用这个
setenv SUBJECTS_DIR `pwd`  # csh（tcsh）下用这个
```

然后再创建2个新的文件夹`FSGD`和`Contrasts`，键入：

```bash
mkdir FSGD Contrasts
```

# 创建FSGD文件

FreeSurfer Group Descriptor (FSGD) file

这组数据是有关大麻吸食者的数据，下载时有一个`participants.tsv`文件，包含了每个被试各种label以及协变量，例如：

- 所在组
- 性别
- 年龄
- 开始吸食时间

我们需要提取我们感兴趣的label和协变量，写成FreeSurfer能读懂的格式，也就是FSGD文件，键入：

```bash
cp ../participants.tsv FSGD/CannabisStudy.tsv
```

然后在第一列（In the first column）中键入以下4行：

```txt
GroupDescriptorFile 1
Title CannabisStudy
Class HC
Class CB
```

> 这些行被称为**header lines**
>
> `GroupDescriptorFile 1`说明这个文件是FSGD格式的，所有FSGD格式文件的第一行都是这个
>
> `Title CannabisStudy`最后会创建名为`CannabisStudy`的文件夹来保存分析结果
>
> `Class HC`和`Class CB`说明被试的分组

最终修改为：

```text
GroupDescriptorFile 1
Title CannabisStudy
Class HC
Class CB
Input sub-202 HC
Input sub-206 HC
Input sub-207 HC
Input sub-101 CB
Input sub-103 CB
Input sub-104 CB
```

重新命名为`CannabisStudy.txt`（作者表示还是.tsv文件，Tab Delimited Text）

**注意被试的名字一定要和`Cannabis`文件夹下的被试文件夹名字一样（which should correspond to the subject directories in the Cannabis folder），应该不需要和FS文件夹下的被试文件夹名字`sub-101_ses-BL_T1w`一样；但是，后面的脚本依旧需要`FS`文件夹下被试文件夹名字只是`sub-xxx`，所以还是修改这里的被试文件夹名字**

键入：

```bash
tr '\r' '\n' < CannabisStudy.txt > CannabisStudy.fsgd  # \r是回车；\n是新行
```

> 能够去除DOS回车符`\r`（这个Unix系统不能识别，是Windows的东西），即将`\r`换成`\n`

本例中未加入任何协变量，需要的化只需要在后面加入，许多研究人员会将**估计颅内总体积（eTIV）**作为协变量

# 创建对比矩阵

```bash
echo "1 -1" > HC-CB.mtx
```

> `.mtx`表示matrix

同样可以创建相反的对比矩阵

```bash
echo "-1 1" > CB-HC.mtx
```

最后记得把`.mtx`文件移动到`Contrast`文件夹中

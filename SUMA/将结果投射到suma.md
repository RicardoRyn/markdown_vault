# 第一个video
首先对被试进行recon-all
```bash
recon-all -i t1.nii.gz -subjid sub-01 -all
```

(这里被试文件夹生成在freesurfer默认路径)
用freeview打开被试结果

`volume`菜单栏选择`aparc.a2009s+aseg`
`surface`菜单栏选择`lh.pial`，并在下面的`Annotation`里选择`lh.aparc.a2009s.annot`文件
就可以在3D图上看到个体分区

# 第二个video
用freesurfer生成的文件
这里要用的命令是`@SUMA_Make_Spec_FS`
键入：

```bash
@SUMA_Make_Spec_FS -NIFTI -sid sub-01 -fspath ./sub-01 -debug 1
```

这条命令会在之前freesurfer生成的被试文件夹下再创建一个`SUMA`文件夹

cd进这个文件夹下
带`*REN*`后缀的文件是由原来文件生成的，只是编码变了
`*cmap*`结尾的是colormap文件，每一个分区对应的颜色都在cmap上定义的
`*.gii`文件是surface文件，对应的是`*.nii.gz`结尾的文件
`*乱码*.alt`是一些中间文件

`*.spec`文件是一个文本文件，但里面定义了SUMA要读这些surface文件的时候要读哪些内容，不一样的表层的呈现方式对应的是哪些文件
这个spec文件可以自己生成，但是SUMA在这里准备了个体空间的左右脑以及both的

用SUMA打开spec文件，键入：
```bash
suma -spec sub-01_both.spec
```

点击菜单栏的`view`里的第二项
可以打开分区文件，按`.`和`,`来回切换视图

`std*`是标准的意思，也就是说所有std文件开头的都是把被试个体皮层表层映射到标准空间上来，一个映射的是`std.141`一个是`std.60`。这一步就相当于在volume上做的标准化
141应该是比freesurfer皮层表层的mesh有更密集的节点
键入：

```bash
suma -spec std.141.sub-01_both.spec
```

如果你想要把分区映射到overlay的时候，需要选择141对应的`aparc`文件，而不能选择其他的。尽管它们看上去很相似
映射到标准空间是为了组水平的分析

# 第三个video
在surface上做功能像的预处理
与之前afni做预处理没太大差别，只是block中多了surf一步

```bash
-blocks tshift align volreg surf blur scale regress
-surf_anat sub-01/SUMA/sub-01_SurfVol.nii
-surf_spec sub-01/SUMA/std.141.sub-01_?h.spec
```

因为有了surf这一步，所以就没有空间标准化了
预处理生成`pb0*`的文件
其中`*.niml.dset`后缀的就是在表层空间的文件，是afni独特的文件格式
`*+tlrc*`说明afni认为它是在标准空间的，这个信息是写在头文件(.HEAD)里面的。有时候在网上下载数据，明明不是在标准空间，但afni依然记录成+tlrc，可以通过`3drefit`命令来修改

# 第四个video
组分析

# 第五个video
把surface结果呈现到volume上来
用的是`3dSurf2Vol`命令
需要一个`spec`文件和一个`sv`文件(Surf_Vol)
被试SUMA文件夹里会包含这些文件

> 所以：
> 个体volume 通过 个体sv 转换到 个体surface
> 同样的 MNIvolume 通过 MNI_sv 转换到 MNI_surface

在afni官网上能够下载对应标准空间的文件
例如：`suma_MNI152_2009.tgz`
就是在MNI152上运行`suma`，然后生成了对应的`spec`文件和`volume`文件
`3dSurf2Vol` 
...
在做surface到volume的转换的时候，头文件的信息丢掉了
可以用`3drefit`来把这些sub-brick的名字重新规定一下。但是一个一个改很麻烦，可以把之前头文件的信息拷贝过来

```bash
3drefit -copyaux stats/group_anova_results.lh.niml.dset group_anova_results.nii.gz
```

这一步并不改变体素结果，只是改变头文件信息的结果
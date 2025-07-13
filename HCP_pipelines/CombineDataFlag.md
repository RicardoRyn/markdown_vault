# 一、人类反相有95个全脑（正相95个全脑）

反相中包括b值不为0的volume

## 1. CombineDataFlag == 1

不会报错，最终得到的data.nii.gz包括95个全脑，均完成dwi预处理，生成的`${subj}/data/bvals`文件中的值并没有变化，应该是正相和反相文件bvals值和bvecs值一样，所以很正常

## 2. CombineDataFlag == 2

不会报错，最终得到的data.nii.gz包括190（95+95）个全脑，均完成dwi预处理

## 3. CombineDataFlag == 0

不会报错，最终得到的data.nii.gz包括95个全脑，均完成dwi预处理



# 二、人类反相有6个全脑（正相95个全脑）

反相中只包括b值为0的volume

## 1. CombineDataFlag == 1

不会报错，但是最终得到的data.nii.gz**只有6个全脑（即b=0的volume）**，均完成预处理。但是生成的`${subj}/data/bvals`文件中的值有变化

## 2. CombineDataFlag == 2

不会报错，最终得到的data.nii.gz包括101（95+6）个全脑，均完成dwi预处理

## 3. CombineDataFlag == 0

不会报错，最终得到的data.nii.gz包括95个全脑，均完成dwi预处理

`${subj}/Diffusion/data`除了有`bvals`文件，还有一个`bvals_noRot`文件，`bvals_noRot`文件和原始的`bvals`文件是同一个文件，但是`${subj}/Diffusion/data`中的`bvals`文件中的第2个值~第6个值却有变化：**前面6个全脑图像上看像是b=0，但是`bvals`文件中写的却是`5 707 1411 2125 704 2114`，除了第一个`5`，剩下5个`707 1411 2125 704 2114`全部都对不上。**

我猜测`CombineDataFlag == 0`时，会对原始`bvals`文件进行处理，会把反相图像文件（6个全脑）融入到正相图像文件（95个全脑）中，最终得到的`data.nii.gz`文件中的前6个全脑就是反相和正相图像融合后的全脑，所以对应的最后生成的`bvals`文件的前6个值（准确来说是2个值~第6个值）有变化，具体变化未知。



# 三、猕猴的反相只有6个全脑（正相258个全脑）

## 1. CombineDataFlag == 1

不会报错，但是最终得到的data.nii.gz**只有6个全脑（即b=0的volume）**，均完成预处理。但是生成的`${subj}/data/bvals`文件中的值有变化

## 2. CombineDataFlag == 2

不会报错，最终得到data.nii.gz包括264（258+6）个全脑，均完成dwi预处理

## 3. CombineDataFlag == 0

会报错，但是对脚本进行以下2种处理即可：

1. 在`eddy_postproc.sh`脚本中的`average_bvecs.py`命令中的`${datadir}/avg_data`的后面增加`${CombineDataFlag}`
2. 将`NHPPipelines/global/scripts`中的`averge_bvecs.py`脚本替换成`HCPpipelines/global/scripts`中的`average_bvecs.py`

然后再运行就不会报错，并且最后生成的data.nii.gz包括258个全脑，均完成dwi预处理

其中`${subj}/Diffusion/data`除了有`bvals`文件，还有一个`bvals_noRot`文件，`bvals_noRot`文件和原始的`bvals`文件是同一个文件，但是`${subj}/Diffusion/data`中的`bvals`文件中的第2个值~第3个值、第131~第132个值却有变化：`0 711 711 ... 0 711 711`



# 四、总结

`${combineDataFlag}==1或者0`应该在正相、反相全脑图像完全一致（只有方向相反）的情况下才能用，即bval文件和bvec文件都应该一致

在`${combineDataFlag}==0`的情况下，反相有多少个全脑，就会和正相的前多少个全脑进行匹配，这要求他们的bval以及bvec都是一样的。如果不一样，最终在`average_bvecs.py`文件中会生成新的bvals和bvecs文件，并对其中的值进行变化

**这个变化的bval值可靠性存疑**

> 例如正相95个全脑，反相6个全脑，在`${combineDataFlag}==0`的情况下，最后生成的data.nii.gz有95个全脑，但是前6个是正相和反相融合处理过的，bval值有变化

肉眼比较猕猴上`${combineDataFlag}==0`和`${combineDataFlag}==2`的最终结果（`data.nii.gz`文件），差异不大



**结论：**

**我们猕猴的数据并不建议`${combineDataFlag}==0`，还是`${combineDataFlag}==2`比较靠谱。**

**如果向HCP这种正反相都有95个全脑的数据，则建议`${combineDataFlag}==1`**

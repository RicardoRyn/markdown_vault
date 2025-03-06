# ANTs剥头皮

```bash
antsBrainExtraction.sh -d 3 \
	-a sub-001_T1w_202.nii.gz \
	-e brainWithSkullTemplate.nii.gz \
	-m brainPrior.nii.gz \
	-o anat_Stripped.nii
```

> The option “-d 3” means that it is a three-dimensional image; 
>
> “-a” indicates the anatomical image to be stripped;
>
> and “-e” is used to supply a template for skull-stripping. (which ones?) 
>
> “-m” will generate a brain mask, 
>
> and “-o” is the label for the output.

# ANTs配准

```bash
antsRegistrationSyN.sh -d 3 \
	-o ./ants \
	-f ./T1.nii.gz \
	-m ./NMT_v2.0_sym_SS.nii.gz
```

> 需要去颅骨的native t1和模板t1
>
> -d表示文件是3维的
>
> -o表示生成文件的前缀
>
> -f表示不动的文件，-m表示需要配准的文件，即把-m后的文件扭曲配准到-f后的文件上
>
> ANTs在做转换的时候是先做一个线性的转换，再做一个非线性的转换

```bash
antsApplyTransforms -d 3 \
	-i ./CHARM_5_in_NMT_v2.0_sym.nii.gz \
	-r ./T1.nii.gz \
	-n GenericLabel[Linear] \
	-t ./ants1Warp.nii.gz \
	-t ./ants0GenericAffine.mat \
	-o ./Native_atlas.nii.gz
```

> -i表示需要转换的标准模板的atlas
>
> -r表示reference，用来参考的文件，这里是个体t1像
>
> -n表示原模板atlas转换的方法，因为原atlas值都是整数，所以这里不用插值的方式，否则转换得到的native atlas里值有不是整数的部分
>
> -t后跟转换用的矩阵
>
> -o表示生成文件的名字

合起来，方便复制粘贴：

```bash
antsRegistrationSyN.sh -d 3 \
                       -o ./ants \
                       -f ./t1.nii.gz \
                       -m ./NMT_v2.0_sym_SS.nii.gz
antsApplyTransforms -d 3 \
                    -i ./CHARM5_MRtrix.nii.gz \
                    -r ./t1.nii.gz \
                    -n GenericLabel[Linear] \
                    -t ./ants1Warp.nii.gz \
                    -t /ants0GenericAffine.mat \
                    -o ./parcels.nii.gz


# 使用逆矩阵
antsRegistrationSyN.sh -d 3 \
                       -o ./ants \
                       -f ./t1.nii.gz \
                       -m ./NMT_v2.0_sym_SS.nii.gz
antsApplyTransforms -d 3 \
                    -i ./rm_rjx.nii.gz \
                    -r ./NMT_v2.0_sym_SS.nii.gz \
                    -n GenericLabel[Linear] \
                    -t [./ants0GenericAffine.mat,1] \
                    -t ./ants1InverseWarp.nii.gz \
                    -o ./rm_rjx_NMT2.nii.gz
```


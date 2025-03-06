```bash
dwi2mask dwi.mif - | maskfilter - dilate preproc_mask.mif -npss 3  # maskfilter里的dilate会将mask往外扩张，确保能够包含所有的大脑组织，往外扩张3个体素，就是npss设置的数值

dwidenoise dwi.mif denoise.mif -noise noise.mif

mrdegibbs denoise.mif degibbs.mif

dwiextract PA.mif - -bzero | mrmath - mean mean_b0_PA.mif -axis 3
dwiextract degibbs.mif - -bzero | mrmath - mean mean_b0_AP.mif -axis 3
mrcat mean_b0_AP.mif mean_b0_PA.mif -axis 3 b0_pair.mif

dwifslpreproc degibbs.mif preproc.mif -pre_dir AP -rpe_pair -se_epi b0_pair.mif -eddy_options " --slm=linear --data_is_shelled --niter=5"  # --niter=5表示迭代5次

dwibiascorrect ants preproc.mif unbiased.mif -bias bias.mif
```

# 生成全脑概率性纤维束

```bash
mrthreshold -abs 0.2 FA.mif - | mrcalc - mask.mif -mult dwi_wmMask.mif

tckgen -algo iFOD2 -act 5tt_coreg.mif -backtrack -crop_at_gmwmi \
       -cutoff 0.05 -angle 45 -minlength 20 -maxlength 200 \
       -seed_image dwi_wmMask.mif -select 200k \
       dwi_wmCsd.mif \
       200k.tck
```

> 其中`-act`，`-backtrack`，`-crop_at_gmwmi`三个选项都是基于ACT（Anatomically-Constrained Tractography ）的选项，需要基于`5tt`格式的文件
>
> `-crop_at_gmwmi`表示在灰白质交界处精确停止
>
> `-cutoff`表示FA的阈限
>
> `-seed_image`表示用白质来做种子，而不是灰白质交界

额外的：

> `-seed_random_per_voxel image num_per_voxel` *(multiple uses permitted)* **seed a fixed number of streamlines per voxel in a mask image**; random placement of seeds in each voxel
>
> `-seed_grid_per_voxel image grid_size` *(multiple uses permitted)* seed a fixed number of streamlines per voxel in a mask image; place seeds on a 3D mesh grid (grid_size argument is per axis; so a grid_size of 3 results in 27 seeds per voxel)

# 生成特定脑区间的概率性纤维束

```bash
mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 10 \
                  lh_thalamus.nii.gz
mri_extract_label -dilate 1 aparc.a2009s+aseg.nii.gz 1111 \
                  lh_cuneus.nii.gz

tckgen -algo iFOD2 -cutoff 0.05 -angle 45 \
       -minlength 20 -maxlength 100 \
       -seed_image lh_thalamus.nii.gz \
       -include lh_cuneus.nii.gz \
       -seed_unidirectional \
       -stop \
       dwi_wmCsd.mif \
       thalamus_cuneus.tck
```

> 生成 thalamus 和 cuneus 之间的概率性纤维束
>
> ***注意：`-stop`和`-act`并用会报错***

# 生成脑区对结构矩阵

```bash
tck2connectome -symmetric -zero_diagonal -scale_invnodevol \
               200k.tck \
               parcellation.nii.gz \
               connectome_a2009s.csv \
               -out_assignment assignment_a2009s.csv
```

>这个矩阵是用ROI与ROI之间的 streamline 数量来表征连接强度
>
>`-symmetric`表示生成的矩阵对称
>
>`-zero_diagonal`表示矩阵的对角线值为0
>
>`-scale_invonoderol`表示进行标准化，因为越大的ROI肯定有越多的streamline，所以要标准化
>
>`-out_assignment`表示生成一个分区节点的配对文件（感觉没啥用）

```bash
tcksample 200.tck FA.mif \
          tck_meanFA.txt \
          -stat_tck mean

tck2connectome -symmetric -zero_diagonal \
               200k.tck \
               parcellation.nii.gz \
               connectome_fa.csv \
               -scale_file tck_meanFA.txt \
               -stat_edge mean
```

> 首先输入`200.tck`和`FA.mif`文件，生成`tck_meanFA.txt`；即计算连接线FA的平均值是多少
>
> `-scale_file`表示不再根据ROI的体积来进行标准化，而是根据FA平均值来标准化

# 单个脑区投射到全脑矩阵

```bash
tck2connectome fixed_seed_tracks.tck nodes.mif fingerprint.csv -vector
```

> This usage assumes that the streamlines being provided to the command have all been seeded from the (effectively) same location, and as such, only the endpoint of each streamline (not their starting point) is assigned based on the provided parcellation image. Accordingly, the output file contains only a vector of connectivity values rather than a matrix, since each streamline is assigned to only one node rather than two.


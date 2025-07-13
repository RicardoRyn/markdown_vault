# 一、DiffPreprocPipelineNHP.sh

```bash
${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipelineNHP.sh \
    --path=${current_dir} \  # 当前路径，包括各个被试名字的文件夹
    --subject=${subj} \  # 被试名字
    --PEdir=2 \  # 相位编码方向，1=LR/RL，2=AP/PA
    --posData=${current_dir}/${subj}/unprocessed/Diffusion/${subj}_1_AP_zeropad.nii.gz@${current_dir}/${subj}/unprocessed/Diffusion/${subj}_2_AP_zeropad.nii.gz \  # 正相数据，多个数据用@号隔开。这里使用zeropad的数据是为了能够进行eddy_squad命令
    --negData=${current_dir}/${subj}/unprocessed/Diffusion/${subj}_1_PA_zeropad.nii.gz@${current_dir}/${subj}/unprocessed/Diffusion/${subj}_2_PA_zeropad.nii.gz \  # 反相数据
    --echospacing=0.47 \  # 可以从json文件中读取，也可以通过下面公式计算，单位毫秒ms
    --gdcoeffs=NONE \ # gradients-coefficients-file的路径
    --dof=12 \  # eddy到结构文件上进行的线性配准所用的自由度
    --combine-data-flag=2  # 如果在eddy_postproc.sh中使用了JAC重采样，这个值决定了输出文件的处理方式

```

$$
\begin{align}
&第一种计算：EffectiveEchoSpacing=\frac{TotalReadoutTime}{ReconMatrixPE-1} \\
&第二种计算：EffectiveEchoSpacing=\frac{1}{BandwidthPerPixelPhaseEncode\times ReconMatrixPE} \\
\end{align}
$$



理论上$BandwidthPerPixelPhaseEncode$和$TotalReadoutTime$互为倒数，但是`json`文件中算出有差别：
$$
BandwidthPerPixelPhaseEncode=\frac{1}{TotalReadoutTime}
$$


## 1. DiffPreprocPipeline_PreEddy.sh

在Eddy之前的各种操作，以及topup

```bash
pre_eddy_cmd+="${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline_PreEddy.sh "
pre_eddy_cmd+=" --path=${StudyFolder} "
pre_eddy_cmd+=" --subject=${Subject} "
pre_eddy_cmd+=" --dwiname=${DWIName} "  # 默认是Diffusion
pre_eddy_cmd+=" --PEdir=${PEdir} "
pre_eddy_cmd+=" --posData=${PosInputImages} "
pre_eddy_cmd+=" --negData=${NegInputImages} "
pre_eddy_cmd+=" --echospacing=${echospacing} "
pre_eddy_cmd+=" --b0maxbval=${b0maxbval} "  # 默认为50，指b值小于这个数则被认为是b0
pre_eddy_cmd+=" --printcom=${runcmd} "  # 测试用命令
```

### (1) basic_preproc.sh

```bash
${runcmd} ${HCPPIPEDIR_dMRI}/basic_preproc.sh \
	${outdir} \
	${echospacing} \
	${PEdir} \
	${b0dist} \  # 默认是45。b0与b0之间至少间隔多少个全脑（假设第1个全脑的是b0,那下一个b0要到45个全脑后才会出现）
	${b0maxbval}
```

主要输出在`${subj}/Diffusion/rawdata`文件夹中，另外：

1. 将生成的`extractedb0.txt`文件移动到`${subj}/Diffusion/topup`文件夹中
2. 将生成的`acqparams.txt`文件移动到`${subj}/Diffusion/topup`文件夹和`${subj}/Diffusion/eddy`文件夹中，前三个值表示的是相位编码方向，最后一个值表示的是“ro_time”即读出时间
3. 将生成的`index.txt`文件移动到`${subj}/Diffusion/eddy`文件夹中
4. 将生成的`series_index.txt`文件移动到`${subj}/Diffusion/eddy`文件夹中
5. 将生成的`Pos_Neg.nii.gz`，`Pos_Neg.bv??`，`Pos.bv??`，`Neg.bv??`等文件移动到`${subj}/Diffusion/eddy`文件夹中

$$
Total\_readout=EffectiveEchoSpacing\times (ReconMatrixPE-1)
$$

**重要：为了计算读出时间，该脚本中会根据`${PEdir}`来获取相位编码方向上voxel的数量，命令为`fslval ${any} dim1`或者`fslval ${any} dim2`，确保初始文件方向符合FSL规范。**

### (2) run_topup.sh

```bash
${runcmd} ${HCPPIPEDIR_dMRI}/run_topup.sh \
	${outdir}/topup  # basic_preproc.sh会生成对应的该文件夹，并包括必要的文件
```

在`${subj}/Diffusion/topup`中，生成3个比较重要的文件：

1. `hifib0.nii.gz`，“hifi”是高保真的意思，这个即校正完的b0图像文件
2. `topup_Pos_Neg_b0_fieldcoef.nii.gz`，即离共振场文件
3. 通过FSL的`bet`命令，针对`hifib0.nii.gz`文件，生成`nodif_brain.nii.gz`以及`nodif_brain_mask.nii.gz`文件**（这些大脑mask文件不一定好用）**



## 2. DiffPreprocPipeline_Eddy.sh

主要进行Eddy

```bash
eddy_cmd+="${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline_Eddy.sh "
eddy_cmd+=" --path=${StudyFolder} "
eddy_cmd+=" --subject=${Subject} "
eddy_cmd+=" --dwiname=${DWIName} "
eddy_cmd+=" --printcom=${runcmd} "
eddy_cmd+=" --replace-outliers"  # 要求eddy将检测到的任何异常值替换为它们的预期值。注意：如果不使用支持GPU的eddy版本，则此选项无效。
eddy_cmd+=" --detailed-outlier-stats" # 在每次迭代后，从eddy生成详细的异常值统计数据。注意：如果不使用支持GPU的eddy版本，则此选项无效。
eddy_cmd+=" --rms" # 为了QC，生成均方根运动文件。注意：如果不使用支持GPU的eddy版本，则此选项无效。 
```

### (1) run_eddy.sh

```bash
run_eddy_cmd="${runcmd} ${HCPPIPEDIR_dMRI}/run_eddy.sh "
run_eddy_cmd+=" ${stats_option} "  # 因为指定了“--detailed-outlier-stats”，所以这里是“--wss”
run_eddy_cmd+=" ${replace_outliers_option} "  # 因为指定了“--replace-outliers”，所以这里是“--repol”
run_eddy_cmd+=" ${nvoxhp_option} "
run_eddy_cmd+=" ${sep_offs_move_option} "
run_eddy_cmd+=" ${rms_option} "  # 因为指定了“--rms”，所以这里是“--rms”
run_eddy_cmd+=" ${ff_option} "
run_eddy_cmd+=" ${ol_nstd_value_option} "
run_eddy_cmd+=" -g "  # 使用GPU版本
run_eddy_cmd+=" -w ${outdir}/eddy "
```

在这里面决定用那种版本的eddy，主要命令为：

```bash
eddy_command="${eddyExec} "  # 指定eddy版本
eddy_command+="${outlierStatsOption} "  # --wss
eddy_command+="${replaceOutliersOption} "  # --repol
eddy_command+="${nvoxhpOption} "
eddy_command+="${sep_offs_moveOption} "
eddy_command+="${rmsOption} "  # --rms
eddy_command+="${ff_valOption} "
eddy_command+="--imain=${workingdir}/Pos_Neg "
eddy_command+="--mask=${workingdir}/nodif_brain_mask "  # 复制自topup中的nodif_brain_mask.nii.gz文件
eddy_command+="--index=${workingdir}/index.txt "
eddy_command+="--acqp=${workingdir}/acqparams.txt "
eddy_command+="--bvecs=${workingdir}/Pos_Neg.bvecs "
eddy_command+="--bvals=${workingdir}/Pos_Neg.bvals "
eddy_command+="--fwhm=${fwhm_value} "
eddy_command+="--topup=${topupdir}/topup_Pos_Neg_b0 "
eddy_command+="--out=${workingdir}/eddy_unwarped_images "
eddy_command+="--flm=quadratic "
eddy_command+="--slm=linear "  # 添加 by RJX。因为这个选项适合半球采集数据
if [ ! -z "${dont_peas}" ] ; then
    eddy_command+="--dont_peas "
fi
if [ ! -z "${resamp_value}" ] ; then
    eddy_command+="--resamp=${resamp_value} "
fi
if [ ! -z "${ol_nstd_option}" ] ; then
    eddy_command+="${ol_nstd_option} "
fi
if [ ! -z "${extra_eddy_args}" ] ; then
    for extra_eddy_arg in ${extra_eddy_args} ; do
        eddy_command+=" ${extra_eddy_arg} "
    done
fi
```



## 3. DiffPreprocPipeline_PostEddyNHP.sh

eddy之后的工作，包括配准到T1上

```bash
post_eddy_cmd+="${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline_PostEddyNHP.sh "
post_eddy_cmd+=" --path=${StudyFolder} "
post_eddy_cmd+=" --subject=${Subject} "
post_eddy_cmd+=" --dwiname=${DWIName} "
post_eddy_cmd+=" --gdcoeffs=${GdCoeffs} "
post_eddy_cmd+=" --dof=${DegreesOfFreedom} "
post_eddy_cmd+=" --combine-data-flag=${CombineDataFlag} "
post_eddy_cmd+=" --printcom=${runcmd} "
```

### (1) eddy_postproc.sh

```bash
${runcmd} ${HCPPIPEDIR_dMRI}/eddy_postproc.sh \
	${outdir} \
	${GdCoeffs} \  # 未指定
	${CombineDataFlag}  # 2
```

主要输出都在`${subj}/Diffusion/data`文件夹中，主要就干了3件事：

1. `${CombineDataFlag}==2`时，eddy完的`eddy_unwarped_images.nii.gz`文件就是`data.nii.gz`文件。如果`${CombineDataFlag}!=2`，则需要进行“JAC采样”，具体不清楚。**但是只有在`${CombineDataFlag}!=2`时，才会使用eddy生成的`eddy_unwarped_images.eddy_rotated_bvecs`文件（原因未知，需要搞清楚不同`CombineDataFlag`到底意味着什么）**
2. 梯度非线性校正，但是一般缺少机密文件，所以这一步大都跳过
3. 将`data.nii.gz`中的负值剔除，然后据此，利用`bet`生成`nodif_brain.nii.gz`及`nodif_brain_mask.nii.gz`文件。**注意：这里又重新生成了大脑mask文件，与`run_topup.sh`中的有些许差异（依旧不一定好用）**

>**`${CombineDataFlag}`是很关键的参数，但是暂时并不清楚它到底在干什么，只是`${CombineDataFlag}==1`时，猴上的数据会报错，所以只能设置成`${CombineDataFlag}==2`，已知这个参数会在命令`eddy_combine`中被使用。后面还要结合`average_bvecs.py`脚本（这个脚本来自于HCPNHPPipeline，而不是FSL）**



### (2) DiffusionToStructuralNHP.sh

```bash
${runcmd} ${HCPPIPEDIR_dMRI}/DiffusionToStructuralNHP.sh \
    --t1folder="${T1wFolder}" \
    --subject="${Subject}" \
    --workingdir="${outdir}/reg" \
    --datadiffdir="${outdir}/data" \
    --t1="${T1wImage}" \
    --t1restore="${T1wRestoreImage}" \
    --t1restorebrain="${T1wRestoreImageBrain}" \
    --biasfield="${BiasField}" \
    --brainmask="${FreeSurferBrainMask}" \
    --datadiffT1wdir="${outdirT1w}" \
    --regoutput="${RegOutput}" \
    --QAimage="${QAImage}" \
    --dof="${DegreesOfFreedom}" \
    --gdflag=${GdFlag} \
    --diffresol=${DiffRes}
```

手动加了一段代码，判断之前是否创建了`brainmask_fs.nii.gz`文件，如果没有则手动创建。

> 根据FreeSurface得到的brain.nii.gz，直接mask来创建

主要输出在`${subj}/T1w/Diffusion`文件夹中，将data.nii.gz配准到T1上。

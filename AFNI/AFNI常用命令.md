# 3dinfo

用来显示HEAD文件的信息

```bash
3dinfo -verb 目标文件.HEAD  # -verb是显示跟详细的信息
```

# 3dcalc

用来计算用的

```bash
3dcalc -a FACE.nii.gz -b HOUSE.nii.gz -expr 'a+2*b' -prefix FACEaHOUSE.nii.gz  # 该命令中已经假设对face的激活为1，其余为0；对house的激活为1，其余为0。则生成的文件中，都不激活的脑区为0，只对face激活的区域为1，只对house激活的脑区为0，都激活的脑区为3
```

```bash
3dcalc -a 参数a -b 参数b -expr 'step(a-b)'  # step括号里的值，若大于0则全为1，若小于等于0则全为0
3dcalc -a rm_rjx.nii.gz[0] -expr 'step(a)' -prefix rm_rjx1.nii.gz  # 只操作第一个全脑
3dcalc -a rm_rjx.nii.gz'<2,3,4>' -expr 'step(a)' -prefix rm_rjx1.nii.gz  # 选择label为2,3,4的脑区
3dcalc -a rm_rjx.nii.gz'<2..100>' -expr 'step(a)' -prefix rm_rjx1.nii.gz  # 选择label为2,3,4...99,100的脑区
```

# 3dTcat

用来删除或者合并一些volume（sub-brick）

```bash
3dTcat -prefix FT.results/pb00.FT.r01.tcat 'FT/FT_epi_r1+orig[2..$]'  # 首先是生成一个pb00.FT.r01.tcat的文件，输入数据是FT_epi_r1+orig。[2..$]表示从#2号（也就是第3个数据，因为起始为0）数据开始选择，一直到最后一个。最终效果就是将最开始的2个volume去除掉
```

```bash
3dTcat run01.nii.gz run02.nii.gz allrun.nii.gz  # 将run01和run02合并成allrun
```

# 3dTstat

在时间维度上进行各种计算（例如平均值、和、标准差等等），直接键入`3dTstat`再回车可以看其介绍

```bash
3dTstat -mean # 例如1个run有100个时间点，计算完得到一个3d的全脑，里面每一个体素的值都是100个时间点的平均值（也可以计算其他的）
```

# 3dROIstats

对ROI进行一些计算

可以计算在这个mask里面的值

# 关于组水平分析

3dttest++  # t检验

3dANOVA  # 单因素方差分析

3dANOVA2  # 双因素方差分析

3dANOVA3  # 多因素方差分析

3dLME  # 线性混合效应模型
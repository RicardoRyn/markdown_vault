# FSL实用命令

```bash
randomise  # 体素水平上的统计，我猜是AFNI里面的FWE思想，或者就是Permutation思想

fslmerge -t all_FA.nii.gz `imglob *_FA_to_target.*`  # 很容易将一堆.nii.gz文件沿着第四维组合起来

imglob *_FA.*  # 显示所有.nii/.nii.gz结尾的文件的名字(不包括“.nii.gz/.nii”)

imtest rm_rjx  # 判断名为rm_rjx的.nii/.nii.gz文件是否存在，存在输出1,不存在输出0

remove_ext  # 移除文件名的后缀，只能移除.nii.gz和.nii结尾的后缀
```


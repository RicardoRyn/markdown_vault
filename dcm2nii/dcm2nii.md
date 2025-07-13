```bash
Chris Rorden's dcm2nii :: 4AUGUST2014 (Debian) 64bit BSD License
reading preferences file /home/nhp/.dcm2nii/dcm2nii.ini
Either drag and drop or specify command line options:
  dcm2nii <options> <sourcenames>
OPTIONS:
-4 Create 4D volumes, else DTI/fMRI saved as many 3D volumes: Y,N = Y
# 创建一个4d文件，在fMRI和DWI中会用到
-a Anonymize [remove identifying information]: Y,N = Y
# 移除辨认信息
-b load settings from specified inifile, e.g. '-b C:\set\t1.ini'
# 加载初始选项设置
-c Collapse input folders: Y,N = Y
# 折叠文件夹
-d Date in filename [filename.dcm -> 20061230122032.nii]: Y,N = Y
# 以日期命名输出文件
-e events (series/acq) in filename [filename.dcm -> s002a003.nii]: Y,N = Y
# 把events作为输出文件名
-f Source filename [e.g. filename.par -> filename.nii]: Y,N = N
# 不修改源文件名
-g gzip output, filename.nii.gz [ignored if '-n n']: Y,N = Y
# 以.nii.gz格式保存文件
-i ID  in filename [filename.dcm -> johndoe.nii]: Y,N = N
# 根据ID更改输出文件名
-m manually prompt user to specify output format [NIfTI input only]: Y,N = Y
# 手动指定输出文件格式
-n output .nii file [if no, create .hdr/.img pair]: Y,N = Y
# 以.nii格式保存文件，别与-g共用
-o Output Directory, e.g. 'C:\TEMP' (if unspecified, source directory is used)
# 输出文件到指定文件夹
-p Protocol in filename [filename.dcm -> TFE_T1.nii]: Y,N = Y
-r Reorient image to nearest orthogonal: Y,N 
-s SPM2/Analyze not SPM5/NIfTI [ignored if '-n y']: Y,N = N
-t Text report (patient and scan details): Y,N = N
-v Convert every image in the directory: Y,N = Y
-x Reorient and crop 3D NIfTI images: Y,N = N
  You can also set defaults by editing /home/nhp/.dcm2nii/dcm2nii.ini
EXAMPLE: dcm2nii -a y /Users/Joe/Documents/dcm/IM_0116
```


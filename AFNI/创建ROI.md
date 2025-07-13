# 创建ROI

## 通过坐标创建ROI

通常为前人研究中报告了某个任务对某个区域有激活，我们再对该区域进行进一步研究

neurosynth.org

> 是一个元分析的网站，相当于一个平台，可以从此处获得感兴趣的元分析，并获得对应脑区的坐标

根据坐标创建一个球形的ROI（-42，-60，-12），键入：

```bash
3dcalc -a MNI152_T1_2009c+tlrc. -expr "step(25-(x+42)*(x+42)-(y+60)*(y+60)-(z+12)*(z+12))" -LPI -prefix ball.nii.gz
# -a后面跟想要创建ROI的Underlay
# -expr表达式，25为半径为5mm的球形ROI，（x-x坐标）的平方，（y-y坐标）的平方，（z-z坐标）的平方；step表示所有小于0的都为0，大于0的都为1
# -LPI表示 左到右，后到前，下到上 为轴方向；MNI坐标以LPI为默认方向；另一种格式是RAS
# LPI一般是神经科学用的格式，RAS是放射学用的格式（但是afni默认RAS格式坐标，所以需要我们手动改为LPI格式）
# -prefix表示生成数据的名称
afni
```

生存的ROI文件保存在ball.nii.gz文件中

在afni中更改Underlay为MNI152_T1_2009c；将Overlay更改为ball.nii.gz

右键移动坐标（MNI）到（-42，-60，-12）方可查看

该球形ROI是以结构像为基准做的（其体素的大小是1×1×1），实验中想要以功能像为基准做只需要将`-a`后面的参数改为功能像就行了



## 通过激活区的体素团创建ROI

在已经得到的一堆激活的脑区之间定义一个ROI

打开一个示例，例如：

```bash
afni MNI152_T1_2009c+tlrc. stats.FT+tlrc.
```

在图形界面中设置Underlay为MNI152_T1_2009c；Overlay为stats.FT

设定p值为0.001

点击Clusterize按钮，打开设置体素团界面；设置40体素为一体素团

点击下方Rpt（Report）按钮打开，选取某一体素团为感兴趣的区域（示例为第12号体素团）

![image-20201202161735698](C:\Users\91009\AppData\Roaming\Typora\typora-user-images\image-20201202161735698.png)

点击Write按钮，afni会单独将该cluster写成一个文件（终端中可查看：`Clust_mask_0012+tlrc.BRIK`）

如果想将此体素团修改成一个0/1（二进制）的mask，则利用之前类似的命令，键入：

```bash
3dcalc -a Clust_mask_0012+tlrc. -expr 'step(a)' -prefix binaryCluster12.nii.gz  #step表示把小于0的值变成0，大于0的值都变成1；binary表示生成二进制的mask
```

生成的ROI则保存在binaryCluster12.nii.gz文件中



## 通过生理结构创建ROI

从已有的atlas（图集）来获取ROI
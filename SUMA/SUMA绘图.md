在网址https://afni.nimh.nih.gov/pub/dist/tgz/中下载适合自己的空间文件，这里选择`suma_MNI152_2009.tgz`

将下载好的文件解压缩，并找到`MNI152_2009_SurfVol.nii`	，将其作为underlay，将进行统计检验的结果（即做完预处理和GLM的）作为Overlay，用afni打开，键入：

```bash
afni MNI152_2009_SurfVol.nii stats.FT+tlrc.
```

得到激活图，现在将该图映射到大脑皮层表面空间，键入：

~~~bash
suma -spec suma_MNI152_2009/std.141.MNI152_2009_both.spec -sv MNI152_2009_SurfVol.nii &  # std.141.MNI152_2009_both.spec是suma_MNI152_2009文件夹里关于大脑两个半球（both）的文件；&表示让程序在后台运行，不影响前台继续工作
~~~

出现SUMA图形界面，终端中显示`SUMA_Engine: Starting to listen ...`

表明SUMA已经准备好了，可以听从AFNI调遣

进入SUMA界面时，在键盘上键入`t`键，并迅速在AFNI图形界面中按下`NIML+PO`按键（如果超时，则回到SUMA再次按下`t`键）

一些SUMA中快捷键

a：在明与暗之间切换脑沟中的颜色

。：切换大脑显示模式

p：切换网格模式（SUMA中每个节点表示承载数据的最小单位）

ctrl+方向键：调整大脑方向

Z键和z键：放大和缩小

[键和]键：只显示左/右半球

ctrl+拖动鼠标：同时看两个半球的外/内侧，以及调整两者之间距离

m键：按下m键再拖动鼠标，自动向鼠标移动方向旋转

ctrl+r：储存当前截图（自动在当前文件夹下新建SUMA_Recordings文件夹来储存截图），截图质量和SUMA界面的大小有关

R：录制视频，每次移动都会记录一帧，可以更改视频输出格式，以及保存想要的帧数
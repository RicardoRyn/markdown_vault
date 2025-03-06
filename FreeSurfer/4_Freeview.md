freeview可以查看`.nii`文件，还可以查看`.mgz`和`.inflated`文件

![../../_images/06_Freeview_Example.png](https://andysbrainbook.readthedocs.io/en/latest/_images/06_Freeview_Example.png)

左上角Volumes显示当前加载的图像，勾选或者不勾选可以展现和隐藏该图

`Opacity`可以更改overlay的透明度

**FreeSurferColorLUT（LUT = Look-Up Table）颜色对应的查找表**

键入：

```bash
freeview -v mri/orig.mgz mri/aseg.mgz:colormap=LUT -f surf/lh.pial:edgecolor=yellow
```

> `-v`表示后面跟的是volume
>
> `-f`表示后面跟的是surface
>
> `:`表示附加到文件的选项；例如`aseg.mgz:colormap=LUT`表示为``文件分配一个LUT颜色表

更多的选项请键入`freeview -h`查看

![../../_images/06_Volumes_Surfaces_Freeview.png](https://andysbrainbook.readthedocs.io/en/latest/_images/06_Volumes_Surfaces_Freeview.png)
# 反转恢复类序列

反转恢复，IR

180°脉冲会产生反向的纵向磁化矢量

![image-20220706234431116](..\..\..\typora_images\image-20220706234431116.png)

IR可以明显提高组织的T1对比（大约比90°脉冲大1倍）

![](..\..\..\typora_images\image-20220706234903619.png)

> 前面黑色的使“180°预脉冲”，后面红色加蓝色合起来就是一个自选回波序列SE

## 快速反转恢复序列

又叫FIR、TIR（Turbo Inversion Recovery）、TIRM、IR-TSE、IR-FSE

![image-20220706235543510](..\..\..\typora_images\image-20220706235543510.png)

FIR中，根据不同组织的性质，选择不同的TI，可以抑制不同组织，如下图

分别在3个箭头所指的时间处选择施加一个90°脉冲（这个时候由于没有纵向磁化矢量，90°之后就没有横向磁化矢量），这个时候线圈就采集不到这个信号，相当于这个组织信号被抑制

![image-20220706235959062](..\..\..\typora_images\image-20220706235959062.png)

IR-FSE的临床应用：

1. 脂肪抑制（STIR，short TI inversion recory）
2. 黑水作用（FLAIR，Fluid attenuated inversion recovery，T2-FLAIR），脑脊液抑制
3. 双反转甚至三反转IR-FSE序列，可以抑制多个组织的信号（如下图，可以抑制甲丙组织的信号，有利于乙组织的识别）；可以进行脑灰白质分离成像

![image-20220707001517463](..\..\..\typora_images\image-20220707001517463.png)

4. T1-FLAIR

# 梯度回波类序列 GRE

## 1. GRE基础

GRE，Gradient Recalled Echo

回波的采集分为2种：

1. **180°聚焦脉冲**采集回波（之前介绍的都是这类）
2. 用**读出梯度场的正反向切换**采集回波

采用小角度激发加快采集速度

![image-20220708230635059](..\..\..\typora_images\image-20220708230635059.png)

梯度场切换采集回波更快

![image-20220708230738293](..\..\..\typora_images\image-20220708230738293.png)

GRE序列内在信号比低于SE序列（GRE的缺点）

![image-20220708230938393](..\..\..\typora_images\image-20220708230938393.png)

> “梯度回波的高度”小于“自旋回波的高度”

GRE序列上的血流经常呈现高信号

![image-20220708231149682](..\..\..\typora_images\image-20220708231149682.png)

> 梯度场的切换无需层面选择，被激发的血流尽管离开了扫描层面，但是仍在有效梯度场和采集线圈的有效范围内（上图的虚线框中），仍能产生回波，所以表现成高信号
>
> 如果是180°聚焦脉冲来采集，因为血流已经流出层面，所以采集不到信号

![image-20220708231606471](..\..\..\typora_images\image-20220708231606471.png)

## 2. GRE中的稳态

### （1）纵向磁化矢量的稳态Mz

 ![image-20220708231910719](..\..\..\typora_images\image-20220708231910719.png)

> 例如连续的60°角度激发最终导致纵向磁化矢量稳定在63%（稳态）

### （2）横向磁化矢量的稳态Mxy

类似，连续的小角度脉冲也具有聚焦的作用

![image-20220708232126078](..\..\..\typora_images\image-20220708232126078.png)

## 稳态自由进动 SSFP

steady state free preceesion

![image-20220708232316374](..\..\..\typora_images\image-20220708232316374.png)

![image-20220708232347312](..\..\..\typora_images\image-20220708232347312.png)

### （1）扰相梯度回波（临床上使用最多的GRE）

如果SSFP过程中，每个T2间隙中聚焦REF（即SSFP-REF）的横向磁化矢量保持稳态，那我们是可以加以利用的

但是，实际采样过程中，读出梯度场（频率编码）正反向切换的梯度都是一样的，但是采集每个回波时相位编码梯度是不同的，因此SSFP-REF横向磁化矢量是不同的（即不是稳态）

这会导致图像出现带状伪影

所以扰相梯度回波就是一种去除残留横向磁化矢量的方法（SSFP-REF）

![image-20220708233508737](..\..\..\typora_images\image-20220708233508737.png)

> 如上图绿色的相位编码梯度是不断变换的

![image-20220708233606878](..\..\..\typora_images\image-20220708233606878.png)

![image-20220708233715697](..\..\..\typora_images\image-20220708233715697.png)

不同厂家对扰相技术有不同的命名：

1. GE：SPGR，spoiled gradient recalled acquisition in steady state
2. SIEMENS：FLASH，fast low angle shot
3. PHILIPS：T1-FEF，fast field echo


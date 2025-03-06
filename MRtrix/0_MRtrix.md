MRtirx是一个分析弥散数据的软件包，相比张量拟合技术（tensor-fitting techniques）其有一个显著的优势，即**约束球面反卷积方法（constrained spherical deconvolution, or CSD）**

这个方法将voxel的弥散信号（diffusion signal）反卷积成一系列重叠的纤维束（overlapping fiber bundles），这减少了拟合一个张量（fitting a tensor）时纤维束交叉处的问题

![../../_images/00_BasisFunction.png](https://andysbrainbook.readthedocs.io/en/latest/_images/00_BasisFunction.png)

除了MRtrix团队自己的命令库，还用到了FSL的命令，特别是`topup`和`eddy`

---

本课程将会学习：

1. diffusion基础，如何采集，如何分析
2. 如何使用基于fixel的分析来量化每个voxel内的白质纤维密度
3. 如何使用**概率纤维束描记术（probabilistic tractography）**来创建**纤维束图（tractograms）**
4. 如何创建**连接体（connectomes）**，如何让不同脑区连接的纤维束数量可视化


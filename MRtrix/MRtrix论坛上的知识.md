# 一、猕猴MRtrix中tckgen的参数

[Macaque pipeline feedback - General Discussion - MRtrix3 Community](https://community.mrtrix.org/t/macaque-pipeline-feedback/7080)

这个人在猕猴上的tckgen命令是

```bash
tckgen -act \
	5tt_output.mif \
	-backtrack \
	-maxlength 250 \
	-nthreads 8 \
	-cutoff 0.06 \
	-select 10000000 \
	-seed_dynamic wmfod_norm.mif wmfod_norm.mif \
	tracks_10M.tck \
	-force
```

# 二、HCP 32k surface

[Generating vertex-wise connectivity matrix - General Discussion - MRtrix3 Community](https://community.mrtrix.org/t/generating-vertex-wise-connectivity-matrix/2060/7)

为什么HCP要把数据映射到32k的surface上？

答：

1. 因为在 32k 网格中，相邻顶点之间的间隔大约为 2 毫米。与 HCP 使用的功能磁共振成像（fMRI）数据的采集分辨率相当。因此将数据映射到 32k 网格不会显著丢失空间分辨率。
2. 2 mm的分辨率仍然足够细，可以保留个体间的皮层折叠模式差异（例如脑回和脑沟的形态差异）。这种分辨率被认为足以描述大脑结构的主要特征。
3. 此外，即使存在比 2 毫米更细微的个体间差异，这些差异在扩散 MRI（dMRI）纤维追踪技术中也无法被准确重建。扩散 MRI 的空间分辨率通常较低，难以检测到这种级别的细微变化。

> The HCP map everything to a 32k mesh in addition to a higher resolution one, and from memory that provides a ~ 2mm spacing between vertices, which is about the spatial resolution of the fMRI acquisition and hence doesn’t incur either major losses in resolution or major redundancy when resampling the acquired data into that space. I would expect a 2mm spacing to still preserve subject differences in cortical folding or the like. Besides, any inter-subject differences finer than that likely couldn’t be reconstructed with diffusion MRI tractography anyways.

# 三、使用SIFT2的时候，并不推荐使用-scale_invnodevol

[Computing & comparing SIFT2-connectomes - General Discussion - MRtrix3 Community](https://community.mrtrix.org/t/computing-comparing-sift2-connectomes/973)

说话者的观点是不推荐这种缩放，因为从单位的角度来看，它会导致计算结果的单位变得不直观。**L²** 和 **L⁻¹** 是关于空间的单位，L通常代表长度单位。因此，L²代表横截面积，而L⁻¹则是长度的倒数，这在物理学中是非常不常见的单位。

总结来说，Rob认为，使用这种方法可能会让结果变得“奇怪”或难以理解，尤其是在单位转换方面。

> That’s up to you. Personally I don’t recommend it, I’m sure I’ve made that rant somewhere on here before. But as a basic demonstration: Taking the sum of streamline weights, your connectome edges have units L2: a cross-sectional area. If you divide each edge by the node volumes, each edge now has units L-1. Which is … weird.

# 四、被试间比较connectome

[Connectome with Fiber Bundle Capacity as edge weight? - General Discussion - MRtrix3 Community](https://community.mrtrix.org/t/connectome-with-fiber-bundle-capacity-as-edge-weight/5455/2)

最好的情况下，是把所有的被试的“响应函数”拿出来，生成一个“组平均响应函数”，用“组平均响应函数”分别为每个被试生成“多组织的FOD”，再用`mtnormalise`对每个被试的FOD进行组织间的标准化。

> If you had previously followed the current typical approach for AFD quantification, i.e. common response functions and the `mtnormalise` method, then that component of the scaling can be ignored (again, assuming you’re not chasing after connectivity values with physical units).

如果没有按照最标准的做法来做，比如使用每个被试自己的响应函数，然后使用`mtnormalise`，那么潜在的biases就会变得更加复杂（mutli-shell和multi-tissue情况下会更复杂）

> If however you did something less conventional, like use subject-specific response functions but then use `mtnormalise`, then the potential biases become a bit more complex, and indeed I’ve never gotten around to figuring out the appropriate math in that circumstance (multi-shell & multi-tissue makes things more complex).

但是即使没有做，也不需要担心是世界末日，因为这个因素对最终结果的影响可能会很小

> Ultimately the magnitude of this particular correction is likely to be small compared to other factors, so it’s not the end of the world if it can’t be done; but it should at least be known to be a confounding factor.

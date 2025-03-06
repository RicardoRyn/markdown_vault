# 使用mri_glmfit-sim进行校正

脚本`runClustSims.sh`如下：

```bash
#!/bin/tcsh

set SUBJECTS_DIR = `pwd`  # This line may be invalid, and you may need to change the SUBJECTS_DIR manually in terminal before run. By RJX

setenv study $argv[1]

foreach meas (thickness volume)
  foreach hemi (lh rh)
    foreach smoothness (10)
      foreach dir ({$hemi}.{$meas}.{$study}.{$smoothness}.glmdir)
        mri_glmfit-sim \
          --glmdir {$dir} \  # 一般线性模型输出的结果
          --cache 1.3 pos \  # 一个顶点一个顶点聚类的阈值（The vertex-wise cluster threshold）
          --cwp 0.05  \  # cluster-wise p-threshold；一般都设置为0.05
          --2spaces  # 分析2个半脑的校正
      end
    end
  end
end
```

***记得放在具有包含所有被试文件夹的文件夹下(FS)再跑，跑的时候需要键入：***

```bash
tcsh runClustSims.sh CannabisStudy  # 需要指定研究题目，即CannabisStudy
```

---

大部分分析中，`--glmdir`，`--cwp`,`--2spaces`都不需要更改

`--cache`可能需要看情况更改，其后跟2个参数，参考本例：

- 1.3表示**vertex-wise threshold**，即大于该值的vetex才被认为是显著的；
  cache是`缓存`的意思，即下列vertex-wise的阈值已经被内存缓存，而它们是由`--qcache`命令生成的；这将决定哪些相邻的vertex将会被计算进同一cluster中

  | -log10(P) value | p-value |
  | --------------- | ------- |
  | 1.3             | 0.05    |
  | 2.0             | 0.01    |
  | 2.3             | 0.005   |
  | 3.0             | 0.001   |
  | 3.3             | 0.0005  |
  | 4.0             | 0.0001  |

- `pos`表示positive，对应的还有`neg`和`abs`；

  如果已经有了先验假设（*priori* hypothesis）说明哪一组更大，哪一组更小，就可以用`pos`或者`neg`；否则，用`abs`

> 自从[Greve & Fischl (2018)](https://www.sciencedirect.com/science/article/pii/S1053811917310960)之后，推荐`--cache`使用**3.0及以上**的参数，这样才能保证0.05的false positive rate，或者使用`--perm`（置换检验，permutation test），详情键入`mri_glmfit-sim`查看

# 查看结果

跑完后，可以定位到任意contrast文件夹中，例如`lh.volume.CannabisStudy.10.glmdir/HC-CB`，会发现生成了几个新的文件

<img src="https://andysbrainbook.readthedocs.io/en/latest/_images/09_ClustSim_Output.png" alt="../../_images/09_ClustSim_Output.png" style="zoom:33%;" />

> 只需要关注`cache.th13.pos.sig.cluster.mgh`和`cache.th13.pos.sig.cluster.summary`

打开`.summary`文件并移到最下面，可以看到

![../../_images/09_clusterSummary_output.png](https://andysbrainbook.readthedocs.io/en/latest/_images/09_clusterSummary_output.png)

可以看到每个被认为是显著的cluster的信息

想在`freeview`中查看可以键入：

```bash
freeview -f $SUBJECTS_DIR/fsaverage/surf/lh.inflated:overlay=cache.th13.pos.sig.cluster.mgh
```


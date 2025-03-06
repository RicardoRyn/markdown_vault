MNE的使用有很多坑，尤其在MNE画surface图的过程中。

根据经验，以下代码经常会报错：

```python
subj_dir = 'E:\\4_DTI\\macaque\\KIZ1\\results_of_16_subj\\FreeSurfer_output\\'
subj = 'NMT_template'
brain = mne.viz.Brain(subj, hemi="lh", surf="inflated", subjects_dir=subj_dir, size=(800, 600))
brain.add_annotation("charm5_atlas", borders=0)
brain.close()
```

原因有很多，根据经验考虑：

1. 是否安装了`pyvistaqt`以及`ipywidgets`包，可能还有`qdarkstyle`包；
2. `import vtk`是否报错，如果报错，则卸载重新`pip install vtk==9.3.0`直到不报错；
3. 安装`mne`的时候，除了`pip install mne`，还可以尝试`pip install mne-base`。
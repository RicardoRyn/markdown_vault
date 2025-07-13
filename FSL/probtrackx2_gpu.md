```sh
probtrackx2_gpu --help
PROBTRACKX2 VERSION GPU

Part of FSL (ID: 6.0.5:9e026117)
probtrackx

Usage: 
probtrackx2 -s <basename> -m <maskname> -x <seedfile> -o <output> --targetmasks=<textfile>
 probtrackx2 --help


Compulsory arguments (You MUST set one or more of):
	-s,--samples	Basename for samples files - e.g. 'merged'  # bedpostx中生成的文件，一般都是“./orig.bedpostX/merged”
	-m,--mask	Bet binary mask file in diffusion space  # bedpostx中生成的文件，一般都是“./orig.bedpostX/nodif_brain_mask”
	-x,--seed	Seed volume or list (ascii text file) of volumes and/or surfaces  # 可以是一个.txt列表，每行一个路径加文件；也可以是一个.nii文件

Optional arguments (You may optionally specify one or more of):
	-V,--verbose	Verbose level, [0-2]
	-h,--help	Display this message


	-o,--out	Output file (default='fdt_paths')
	--dir		Directory to put the final volumes in - code makes this directory - default='logdir'  # 默认写法“--dir=./rm_rjx”
	--forcedir	Use the actual directory name given - i.e. do not add + to make a new directory  # 一般都与“--dir”同用，会自动生成该文件夹


	--simple	Track from a list of voxels (seed must be a ASCII list of coordinates)
	--network	Activate network mode - only keep paths going through at least one of the other seed masks  # 通过与“-x ./rm_masks.txt”并用，给定N个ROIs，最后生成NxN的连接矩阵，文件名为 “fdt_network_matrix”，但是这是个不对称矩阵！！！发现这个矩阵的每一行之和并不等于waytotal文件中的每一行的值。并且waytotal的值总是要小于fdt_network_matrix的每一行之和。我猜测，有的streamline从A出发，到达B，但是没有结束，最终能够到达C。这导致fdt_network_matrix文件中，有的stremline被多次计数，所以其每一行的值之和大于waytotal文件每一行的值。
	--opd		Output path distribution  # 最终结果文件夹中生成“fdt_paths.nii.gz”文件
	--pd		Correct path distribution for the length of the pathways  # 和“--opd”并用之后，会更改原来 “fdt_paths.nii.gz” 文件中的值的大小，甚至出现 “x.5” 的小数
	--ompl		Output mean path length from seed
	--fopd		Other mask for binning tract distribution
	--os2t		Output seeds to targets
	--s2tastext	Output seed-to-target counts as a text file (default in simple mode)


	--closestvertex	Count only nearest neighbour vertex when the face of a surface is crossed.
	--targetmasks	File containing a list of target masks - for seeds_to_targets classification
	--waypoints	Waypoint mask or ascii list of waypoint masks - only keep paths going through ALL the masks
	--waycond	Waypoint condition. Either 'AND' (default) or 'OR'
	--wayorder	Reject streamlines that do not hit waypoints in given order. Only valid if waycond=AND
	--onewaycondition	Apply waypoint conditions to each half tract separately
	--avoid		Reject pathways passing through locations given by this mask
	--stop		Stop tracking at locations given by this mask file
	--wtstop	One mask or text file with mask names. Allow propagation within mask but terminate on exit. If multiple masks, non-overlapping volumes expected


	--omatrix1	Output matrix1 - SeedToSeed Connectivity  # 会生成名为 “fdt_matrix1.dot” 的文件，这个文件记录seed区中所有voxel之间的streamline数量。典型用法是令seed为 “GM.nii” ，然后结果就是GM-GM的连接。
	--distthresh1	Discards samples (in matrix1) shorter than this threshold (in mm - default=0)
	--omatrix2	Output matrix2 - SeedToLowResMask  # 会生成名为 “fdt_matrix2.dot” 的文件，这个文件记录seed区中所有voxel与target区中所有voxel之间的streamline数量；还会生成名为“tract_space_coords_for_fdt_matrix2”的文件，记录target区所有voxel的坐标。如果“--omatrix1”和“--omatrix2”同时存在则只会生成“fdt_matrix2.dot”
	--target2	Low resolution binary brain mask for storing connectivity distribution in matrix2 mode  # 如果只有“--target2”则不会有什么特别的输出结果
	--omatrix3	Output matrix3 (NxN connectivity matrix)
	--target3	Mask used for NxN connectivity matrix (or Nxn if lrtarget3 is set)
	--lrtarget3	Column-space mask used for Nxn connectivity matrix
	--distthresh3	Discards samples (in matrix3) shorter than this threshold (in mm - default=0)
	--omatrix4	Output matrix4 - DtiMaskToSeed (special Oxford Sparse Format)
	--colmask4	Mask for columns of matrix4 (default=seed mask)
	--target4	Brain mask in DTI space


	--xfm		Transform taking seed space to DTI space (either FLIRT matrix or FNIRT warpfield) - default is identity
	--invxfm	Transform taking DTI space to seed space (compulsory when using a warpfield for seeds_to_dti)
	--seedref	Reference vol to define seed space in simple mode - diffusion space assumed if absent
	--meshspace	Mesh reference space - either 'caret' (default) or 'freesurfer' or 'first' or 'vox' 


	-P,--nsamples	Number of samples - default=5000
	-S,--nsteps	Number of steps per sample - default=2000
	--steplength	Steplength in mm - default=0.5


	--distthresh	Discards samples shorter than this threshold (in mm - default=0)
	-c,--cthr	Curvature threshold - default=0.2
	--fibthresh	Volume fraction before subsidary fibre orientations are considered - default=0.01
	-l,--loopcheck	Perform loopchecks on paths - slower, but allows lower curvature threshold
	-f,--usef	Use anisotropy to constrain tracking
	--modeuler	Use modified euler streamlining


	--sampvox	Sample random points within a sphere with radius x mm from the center of the seed voxels (e.g. --sampvox=0.5, 0.5 mm radius sphere). Default=0
	--randfib	Default 0. Set to 1 to randomly sample initial fibres (with f > fibthresh). 
                        Set to 2 to sample in proportion fibres (with f>fibthresh) to f. 
                        Set to 3 to sample ALL populations at random (even if f<fibthresh)
	--fibst		Force a starting fibre for tracking - default=1, i.e. first fibre orientation. Only works if randfib==0
	--rseed		Random seed

```


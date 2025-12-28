# 常规安装arch系统

## 0. 前言

1. 从U盘安装
2. 双系统，windows 11 + arch （即 windows 系统和 arch 系统安装到同一个硬盘）或全新硬盘，事先没有安装任何系统
3. Swap分区，非Swap文件
4. btrfs 文件系统，非ext4 文件系统
5. intel cpu，nvidia gpu
6. grup引导

---

**补充知识：**

Btrfs 的未来现在来看是光明的；我们也可以在 archlinux 上享受到 Btrfs 文件系统的特性带来的好处：

1. 快照 —— archlinux 作为滚动发行版，若滚挂了可以使用 Btrfs 的快照特性快速回滚。
   - 若使用传统的 ext4 文件系统，我们可以使用 timeshift 的 RSYNC 模式进行增量备份。
     但是，一般来说 RSYNC 方式的快照大小略大于当前实际使用大小，也就是说实际上开启了 timeshift 的 RSYNC 模式快照相当于磁盘可用空间直接少了一半多。
     因为虽然 RSYNC 方式的快照是增量的，但历史最久远的快照依然是完整备份，随后才是增量的。

2. 透明压缩 —— 可以大大减少磁盘的使用空间（压缩率大概在 10% 左右）

---

## 1. 进入安装环境

没啥好说的，使用Ventoy将某个足够大的U盘改装成系统安装盘，并安装好arch系统镜像。
从U盘启动电脑，选择arch镜像，进入安装界面。

## 2. 准备工作

### 1. 确认是否为UEFI模式

UEFI（Unified Extensible Firmware Interface）中文一般叫 统一可扩展固件接口。

它是电脑开机时，操作系统启动之前 运行的一层“固件接口”，也就是取代传统 BIOS 的新标准。
简单来说：UEFI 是现代计算机开机时最底层的“引导程序”，负责加载操作系统。

本安装笔记要求UEFI模式。

确认一下是否为 UEFI 模式：

```bash
ls /sys/firmware/efi/efivars
```

若输出了一堆东西（efi 变量），则说明已在 UEFI 模式。

### 2. 禁用reflector服务

2020 年，archlinux 安装镜像中加入了 reflector 服务。
该服务用于：

1. 自动从 Arch 镜像列表中选择速度最快、最新的镜像；
2. 然后自动更新 /etc/pacman.d/mirrorlist 文件（也就是 pacman 的软件源列表）。

简而言之：Reflector 会自动帮你找最快的 Arch 软件源。

由于它会自己更新 mirrorlist。
在特定情况下，它会误删某些有用的源信息。

这里进入安装环境后的第一件事就是将其禁用。

也许它是一个好用的工具，但是由于国内的特殊网络环境，这项服务并不适合启用。

```bash
systemctl stop reflector.service
```

查看该服务是否被禁用

```bash
systemctl status reflector.service
```

> 有些设备的蜂鸣器会发出“哔——”声，可以使用如下命令禁用蜂鸣器内核模块：`rmmod pcspkr`
> 要永久禁用蜂鸣器内核模块, 请创建并编辑 /etc/modprobe.d/blacklist.conf。
> `sudoedit /etc/modprobe.d/blacklist.conf`然后加入`blacklist pcspkr`。

### 3. 连接网络

**Arch linux 系统安装必须联网。**

使用 `iwctl` 进行连接：

```bash
iwctl                           # 进入交互式命令行
device list                     # 列出无线网卡设备名，比如无线网卡看到叫 wlan0
station wlan0 scan              # 扫描网络
station wlan0 get-networks      # 列出所有 wifi 网络
station wlan0 connect wifi-name # 进行连接，注意这里无法输入中文。回车后输入密码即可
exit                            # 连接成功后退出
```

若使用有线连接，正常来说，只要插上一个已经联网的路由器分出的网线（DHCP），直接就能联网。

测试网络：

```bash
ping baidu.com
```

### 4. 同步网络时间

必做，正确的系统时间对于部分程序来说非常重要：

```bash
timedatectl set-ntp true # 将系统时间与网络时间进行同步
timedatectl status       # 检查服务状态
```

### 5. 更换国内软件仓库镜像源加快下载速度

使用 vim 编辑器修改 `/etc/pacman.d/mirrorlist` 文件。
将 pacman 软件仓库源更换为国内软件仓库镜像源：

```bash
vim /etc/pacman.d/mirrorlist
```

在最上面输入（选择一行就行了）：

```
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch  # 中国科学技术大学开源镜像站
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch  # 清华大学开源软件镜像站
Server = https://repo.huaweicloud.com/archlinux/$repo/os/$arch  # 华为开源镜像站
Server = http://mirror.lzu.edu.cn/archlinux/$repo/os/$arch  # 兰州大学开源镜像站
```

## 3. 分区和格式化

我们需要划分的区域有：

- `/` 根目录：>= 128GB（和用户主目录在同一个 Btrfs 文件系统上）
- `/home` 用户主目录：>= 128GB（和根目录在同一个 Btrfs 文件系统上）
- `/boot` EFI 分区：1GB（双系统可能不需要手动分配）
- Swap 分区：>= 电脑实际运行内存的 60%（设置这个大小是为了配置休眠准备）

> 如果电脑事先已经有 windows 11 系统，且准备 arch 系统将安装到 windows 11 同一个物理硬盘中,
> 则不需要手动划分EFI分区（`/boot`）。
>
> 只要是多系统，尽量使用同一个 EFI 分区用来启动。
>
> 但是这个分区默认可能只有256MB，在后面安装intel微码时可能空间不够，所以我这里直接加到1GB了。
> 扩充已经存在的 windows EFI分区，用Diskgenius就行，b站上有教程。

因为采用 Btrfs 文件系统，所以根目录和用户主目录实际在一个分区上，只是在不同的子卷上而已。
这里根目录和用户主目录的大小仅为参考，一般来说日常使用的 linux 分配 128GB 已经够用了。

```bash
lsblk # 显示磁盘信息
```

**需要根据硬盘情况，了解各个已有分区的作用。
已经使用的分区，不能轻易改动。**

---

**补充知识：**

在 Linux 系统中，所有设备（包括硬盘、键盘、声卡等）都被当作“文件”来看待。
这些设备文件都放在 `/dev` 目录下（device 的缩写）。

`/dev/nvme0n1` 和 `/dev/sda` 都是 磁盘设备的名字，但它们表示的是 不同类型的物理硬盘：

1. `/dev/sda`：SATA/SCSI 硬盘，传统机械或 SATA 固态硬盘
2. `/dev/nvme0n1`：NVMe 硬盘，更快的新型 SSD
3. `/dev/sr0`：光驱，CD/DVD 设备

对于sda磁盘：

1. `/dev/sda` → 第一块 SATA 磁盘
2. `/dev/sdb` → 第二块 SATA 磁盘
3. `/dev/sdc` → 第三块 SATA 磁盘
4. `/dev/sda1` → 第 1 个分区
5. `/dev/sda2` → 第 2 个分区
6. `/dev/sda3` → 第 3 个分区

对于NVMe磁盘：

1. `/dev/nvme0n1` → 第一块 NVMe 磁盘
2. `/dev/nvme1n1` → 第二块 NVMe 磁盘
3. `/dev/nvme2n1` → 第三块 NVMe 磁盘
4. `/dev/nvme0n1p1` → 第 1 个分区
5. `/dev/nvme0n1p2` → 第 2 个分区
6. `/dev/nvme0n1p3` → 第 3 个分区

**以下用`nvmexn1`以及`nvmexn1pn`代替。
每一次都需按实际情况更改对应的物理硬盘和具体分区名字。**

---

### 1. 全新的硬盘，事先没有 windows 系统，需要手动创建EFI分区

#### 1. 建立新的GPT分区表

**重建分区表会使磁盘所有数据丢失，请事先确认。**

将磁盘转换为 gpt 类型：

```bash
parted /dev/nvmexn1      # 执行 parted，进行磁盘类型变更
(parted) mktable         # 输入 mktable
New disk label type? gpt # 输入 gpt，将磁盘类型转换为 GPT 类型。如磁盘有数据会警告，输入 Yes 即可
(parted) quit            # 退出 parted 命令行交互
```

#### 2. 创建EFI分区

对安装 archlinux 的磁盘分区

```bash
cfdisk /dev/nvmexn1
```

对 `Free Space` 区域进行操作：

1. 选中 `[New]` > 回车，新建分区
2. 输入分区大小`1G` > 回车，确定分区大小（也可以尝试 512MB）
3. 选中操作 `[Type]` > 回车 > 通过方向键 ↑ 和 ↓ 选中 `EFI System` > 回车，确定分区类型

剩下的步骤与 [情况2](### 情况2：已经存在 windows 系统，无须手动创建EFI分区) 相同。

### 2. 已经存在 windows 系统，无须手动创建EFI分区

#### 1. 创建Swap分区

进入 cfdisk 分区界面（如果已经进入了，无需再次进入）

# math package
```bash
cfdisk /dev/nvmexn1
```

对 `Free Space` 区域进行操作：

1. 选中 `[New]` > 回车，新建分区
2. 输入分区大小`10G` > 回车，确定分区大小（内存的60%）
3. 选中操作 `[Type]` > 回车 > 通过方向键 ↑ 和 ↓ 选中 `Linux swap` > 回车，确定分区类型

#### 2. 创建文件系统分区

对 `Free Space` 区域进行操作：

1. 选中 `[New]` > 回车，新建分区
2. 默认分区为剩下的所有空间 > 回车，确定分区大小
3. 选中操作 `[Type]` > 回车 > 通过方向键 ↑ 和 ↓ 选中 `Linux filesystem` > 回车，确定分区类型

#### 3. 正式写入分区并保存退出

1. 选中操作 `[Write]` > 回车 > 输入 `yes` > 回车，确认分区操作
2. `[Quit]` > 回车，退出 `cfdisk` 命令行交互，保存分区表。

分区完成后，使用 `fdisk` 或 `lsblk` 命令复查分区情况：

```bash
lsblk
# 或者
fdisk -l
```

### 3. 格式化分区

**注意以下为可选**

```bash
# !!! （可选）格式化 EFI 分区
# !!! 仅在自己手动创建的全新的 EFI 分区上执行格式化：
mkfs.fat -F32 /dev/nvmexn1pn
```

```bash
# 格式化 Swap 分区
mkswap /dev/nvmexn1pn
# 格式化文件系统分区
mkfs.btrfs -L archlinux /dev/nvmexn1pn
```

> `-L` 选项后指定该分区的 LABLE，这里以 archlinux 为例，也可以自定义，但不能使用特殊字符以及空格，且最好有意义。

### 4. 第一次挂载以创建 Btrfs 子卷

为了创建子卷，我们需要先将 `Btrfs` 分区挂载到 `/mnt` 下：

```bash
mount -t btrfs -o compress=zstd /dev/nvmexn1pn /mnt
```

> `-t btrfs` 选项后指定挂载分区文件系统类型。
> `-o compress=zstd` 开启透明压缩

使用 `df` 命令复查挂载情况：

```bash
df -h
```

通过以下命令创建两个 Btrfs 子卷，之后将分别挂载到 `/` 根目录和 `/home` 用户主目录：

```bash
btrfs subvolume create /mnt/@     # 创建 / 目录子卷
btrfs subvolume create /mnt/@home # 创建 /home 目录子卷
```

通过以下命令复查子卷情况：

```bash
btrfs subvolume list -p /mnt
```

子卷创建好后，我们需要将 `/mnt` 卸载掉：

```bash
umount /mnt
```

## 4. 正式挂载 Btrfs 子卷

**挂载是有顺序的，需要从根目录开始挂载。
时刻确保挂载的名字正确。**

```bash
mount -t btrfs -o subvol=/@,compress=zstd /dev/nvmexn1pn /mnt                  # 挂载 / 目录
mount --mkdir -t btrfs -o subvol=/@home,compress=zstd /dev/nvmexn1pn /mnt/home # 挂载 /home 目录
mount --mkdir /dev/nvmexn1pn /mnt/boot                                         # 挂载 /boot 目录
swapon /dev/nvmexn1pn                                                          # 挂载交换分区
```

使用 `df` 命令复查挂载情况，使用 `free` 命令复查 Swap 分区挂载情况：

```bash
df -h # -h 选项会使输出以人类可读的单位显示
free -h
```

## 5. 安装 arch 系统

通过如下命令使用 `pacstrap` 脚本安装基础包（基本都是必装）：

```bash
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs
```

> `bash`: 最核心的软件包组（必装）
> `base-devel`: 基础开发环境（强烈推荐）
> `linux`: 内核包（必装，但是有其他版本可选）
> `linux-firmware`: 硬件固件包（必装）
> `btrfs-progs`: Btrfs 文件系统工具（对于 Btrfs 文件系统必装）

---

**补充知识：**

`pacstrap`: 初始化安装系统（基础包），安装阶段（Live 环境），Arch 官方安装工具 相当于“把系统装进硬盘”。

`pacman`: 包管理器（安装、更新、删除软件）系统运行阶段，Arch 官方包管理器，管理 `/etc/pacman.conf` 中定义的官方仓库。

`paru`: AUR 助手（辅助 pacman），系统运行阶段（可选），第三方工具，让你轻松安装社区软件（AUR）。

---

如果提示 GPG 证书错误，可能是因为使用的不是最新的镜像文件，可以通过更新 archlinux-keyring 解决此问题：

```bash
pacman -S archlinux-keyring
```

安装其它必要的功能性软件：

```bash
pacstrap /mnt networkmanager vim sudo
```

## 6. 创建 fstab 文件

fstab 用来定义磁盘分区。它是 Linux 系统中重要的文件之一。
使用 `genfstab` 自动根据当前挂载情况生成并写入 fstab 文件：

```bash
genfstab -U /mnt >/mnt/etc/fstab
```

复查一下 /mnt/etc/fstab 确保没有错误：

```bash
cat /mnt/etc/fstab
```

## 7. change root

使用以下命令把系统环境切换到新系统下：

```bash
arch-chroot /mnt
```

---

**补充知识：**

2个事件把整个流程分成了3个状态：

- 状态1: 挂载前
- 事件1: `mount -t btrfs -o subvol=/@,compress=zstd /dev/nvmexn1pn /mnt`
- 状态2: 挂载后
- 事件2: `arch-chroot /mnt`
- 状态3: chroot后

状态1: 挂载前

位于刚启动 Arch Live 环境（内存中）。
`/` 指向Live 系统根目录（在内存里，来自 U 盘的 squashfs 镜像）。
操作对象：Live 系统本身。硬盘存在，但还没挂载，无法直接访问系统文件。

```
Live 系统 /
          ├── bin/
          ├── etc/
          ├── usr/
          ├── mnt/   <-- 空目录，用来挂载硬盘
          └── ...
```

状态2: 挂载后

仍然位于 Arch Live环境（内存中，但是挂载了硬盘）。
`/` 仍然指向是 Live 系统的根目录（内存中的临时系统），其他目录：仍然是 Live 系统内容。
操作对象：`/mnt` 目录现在映射到硬盘分区，对 `/mnt` 下的操作都会写入硬盘。

```
Live 系统 /
          ├── bin/
          ├── etc/
          ├── usr/
          └── mnt/  <-- 已挂载硬盘
                ├── bin/
                ├── etc/
                └── usr/
```

状态3: chroot后

位于新系统环境（硬盘中）。Live 系统变成无关紧要的背景环境（仍在内存里，但被挂起/隔离）。
`/` 指向硬盘系统根目录（新系统）。
操作对象：所有操作直接影响硬盘系统。

```
新系统 /
       ├── bin/
       ├── etc/
       ├── usr/
       └── ...
```

---

## 8. 配置系统

### 1. 设置主机名和时区

通过 `vim /etc/hostname` 首先设置主机名，比如就叫 archlinux：

```
archlinux
```

> 主机名不要包含特殊字符以及空格。

通过 `vim /etc/hosts` 设置与其匹配的条目：

```
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain archlinux
```

> `127.0.0.1` 是 IPv4 的“本机”地址。
> `::1` 是 IPv6 的“本机”地址。
> 无论是否联网，这两个地址都指向 自己这台电脑。
>
> `127.0.1.1` 是主机名解析后的结果。
> 当系统需要解析自己的主机名（hostname）时，能在本地立刻找到对应的 IP 地址。
> Arch希望把 localhost 和 主机名 分开处理，以避免潜在的解析冲突。

设置时区：

```bash
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

> 只有上海，因为上海人口最多。

将系统时间同步到硬件时间：

```bash
hwclock --systohc
```

### 2. 设置语言环境

`locale` 决定了软件使用：

- 语言
- 书写习惯
- 字符集k

通过 `vim /etc/locale.gen` 去掉 `en_US.UTF-8 UTF-8` 以及 `zh_CN.UTF-8 UTF-8` 行前的注释符号。

生成 `locale`：

```bash
locale-gen
```

通过 `vim /etc/locale.conf` 设置语言环境：

```
LANG=en_US.UTF-8
```

> 目前不推荐在此设置任何中文 `locale`，会导致 tty 乱码。后续有了图形界面之后再改。

### 3. 设置 root 用户密码

```bash
passwd root
```

### 4. 安装微码

通过以下命令安装对应芯片制造商的微码：

```bash
pacman -S intel-ucode # Intel
pacman -S amd-ucode   # AMD
```

> 如果这里安装失败，有可能是 EFI 分区（`/boot`）太小导致的，扩大EFI分区即可。

---

**补充知识：**

当执行 `pacman -S intel-ucode` 时发生了什么：

1. 安装微码文件到 `/usr/lib/firmware/intel-ucode/`
2. 创建镜像文件 `/boot/intel-ucode.img`（≈2–3 MB）
3. 触发 `mkinitcpio`（或 kernel-install）钩子

有时它会重建 initramfs（几十到上百 MB）。
并更新引导项文件 `/boot/loader/entries/*.conf`。

如果这时 `/boot` 空间不足，`pacman` 无法写入 `intel-ucode.img`，或者无法更新内核镜像、initramfs

---

## 9. 安装 Grub 引导程序

```bash
pacman -S grub efibootmgr os-prober
```

`grub`: 引导 Linux 系统（以及其他操作系统，比如 Windows）

`efibootmgr`: 与主板的 UEFI 固件交互，管理 EFI 启动项。GRUB 在安装时会调用它来注册启动项。

`os-prober`: 扫描硬盘，查找其他操作系统的引导文件，为了能够双系统启动 windows 11。

安装 GRUB 到 EFI 分区：

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCH
```

> `--target=x86_64-efi`: 指定目标平台是 64 位 UEFI 系统。
> `--efi-directory=/boot`: 指定 EFI 系统分区（ESP）挂载点。
> `--bootloader-id=ARCH`: 定义 GRUB 在 UEFI 启动菜单中的名字（可以自定义）。

通过 `vim /etc/default/grub` 编辑 grub 配置文件，把`GRUB_CMDLINE_LINUX_DEFAULT`一行改成：

```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=5 nowatchdog modprobe.blacklist=iTCO_wdt"
```

> `nowatchdog` 参数无法禁用 intel 的看门狗硬件，所以需要添加 `modprobe.blacklist=iTCO_wdt` 即可

为了能够引导 windows 11。取消 `GRUB_DISABLE_OS_PROBER=false` 的注释（一般在最后一行）

```
GRUB_DISABLE_OS_PROBER=false
```

生成 grub 配置文件

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## 10. 完成安装，退出挂载环境，重启

**重启前要先拔掉U盘。**

```bash
exit
umount -R /mnt
reboot
```

狂按F2更改启动顺序

## 11. 完成安装

使用 `root` 账号登录系统

设置开机自启并立即启动 networkmanager 服务，即可连接网络：

```bash
systemctl enable --now NetworkManager # 设置开机自启并立即启动 NetworkManager 服务
ping baidu.com
```

如果是WiFi连接：

```bash
nmcli dev wifi list # 显示附近的 Wi-Fi 网络
nmcli dev wifi connect <WiFi名字> password <网络密码> # 连接指定的无线网络

systemctl enable --now NetworkManager # 设置开机自启并立即启动 NetworkManager 服务
```

安装玩具：

```bash
pacman -S fastfetch
pacman -S yadm
```

# Termux 全能 Android 编译包

一个在 Termux 上运行的全能 Android 编译环境，整合了 Android SDK、Ubuntu chroot、ARM 交叉编译工具链和 AnyKernel3 模板。

## 功能特性

- **Android SDK**: 完整的 Android 开发工具包
- **Ubuntu chroot**: 通过 proot 运行的 Ubuntu 22.04 环境
- **ARM 工具链**: AOSP Clang + GCC 交叉编译工具链
- **AnyKernel3**: 内核打包和刷入模板

## 系统要求

- **设备**: 任何 Android 设备 (aarch64)
- **Android 版本**: Android 12-15
- **内存**: 建议至少 6GB RAM
- **存储**: 建议至少 10GB 可用空间
- **Termux**: 需要安装 Termux 应用

## 快速开始

### 1. 安装 Termux

从 F-Droid 或 GitHub 下载安装 Termux 应用。

### 2. 克隆此仓库

```bash
git clone https://github.com/your-username/termux-android-builder.git
cd termux-android-builder
```

### 3. 运行安装脚本

```bash
bash install.sh
```

安装脚本会自动：
- 更新 Termux 包管理器
- 安装基础依赖
- 安装 Android SDK
- 安装 ARM 交叉编译工具链
- 安装 Ubuntu chroot 环境
- 配置 AnyKernel3 模板

### 4. 检查环境

```bash
bash env-check.sh
```

### 5. 编译内核

```bash
bash build-kernel.sh -k ~/kernel -c vendor/defconfig
```

## 目录结构

```
termux-android-builder/
├── install.sh              # 主安装脚本
├── setup-sdk.sh            # Android SDK 安装
├── setup-ubuntu.sh         # Ubuntu chroot 安装
├── setup-toolchain.sh      # ARM 交叉编译工具链
├── setup-anykernel3.sh     # AnyKernel3 模板配置
├── build-kernel.sh         # 内核编译入口脚本
├── enter-chroot.sh         # 进入 Ubuntu chroot
├── env-check.sh            # 环境检查脚本
├── config/
│   ├── kernel_defconfig    # 默认内核配置
│   └── toolchain.env       # 工具链环境变量
└── README.md               # 使用说明
```

## 使用说明

### 进入 Ubuntu 环境

```bash
# 快速进入 Ubuntu
ubuntu

# 或使用脚本进入
bash enter-chroot.sh
```

### 安装内核编译依赖

```bash
bash enter-chroot.sh -i
```

### 编译内核

```bash
# 基本用法
bash build-kernel.sh -k ~/kernel

# 指定 defconfig
bash build-kernel.sh -k ~/kernel -c vendor/oneplus9_defconfig

# 清除之前的编译
bash build-kernel.sh -k ~/kernel -C

# 指定编译线程数
bash build-kernel.sh -k ~/kernel -j 8
```

### AnyKernel3 打包

```bash
# 进入 AnyKernel3 目录
cd ~/AnyKernel3

# 复制内核镜像
cp ~/kernel/arch/arm64/boot/Image.gz .

# 编辑配置
nano anykernel.sh

# 打包
zip -r9 kernel.zip * -x .git/*
```

## 设备支持

### 高通设备

大多数高通 Snapdragon 设备都支持，包括：
- OnePlus 系列
- 小米/Redmi 系列
- 三星 Galaxy 系列
- Google Pixel 系列
- Sony Xperia 系列

### 联发科设备

联发科设备也支持，包括：
- Redmi Note 系列
- Realme 系列
- Oppo 系列
- Vivo 系列
- Nothing Phone 系列

## 常见问题

### Q: 编译时内存不足怎么办？

A: 建议手机至少 6GB RAM。如果内存不足，可以：
1. 减少编译线程数：`-j 2`
2. 使用交换空间
3. 在 Ubuntu 环境中编译

### Q: 如何查看设备的 defconfig？

A: 通常在内核源码的以下位置：
- `arch/arm64/configs/`
- `vendor/`
- `device/`

### Q: 编译出的内核如何刷入？

A: 可以使用以下方式：
1. **Magisk**: 将内核 Image 放到 `/sdcard/Download/`，使用 Magisk Manager 刷入
2. **TWRP**: 将 kernel.zip 通过 TWRP Recovery 刷入
3. **KernelSU**: 支持 KernelSU 的设备可以直接使用

### Q: 如何更新工具链？

A: 重新运行安装脚本：
```bash
bash setup-toolchain.sh
```

## 高级用法

### 自定义工具链版本

编辑 `setup-toolchain.sh` 中的版本号：
```bash
CLANG_VERSION="r416183b"  # 修改为你需要的版本
```

### 添加设备配置

在 `setup-anykernel3.sh` 中的 `create_device_configs` 函数添加新配置。

### 使用交换空间

```bash
# 创建 4GB 交换空间
fallocate -l 4G /sdcard/swapfile
chmod 600 /sdcard/swapfile
mkswap /sdcard/swapfile
swapon /sdcard/swapfile
```

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 致谢

- [Termux](https://termux.com/) - Android 上的终端模拟器
- [proot](https://proot-me.github.io/) - 用户空间实现的 chroot
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3) - 通用内核打包工具
- [AOSP](https://source.android.com/) - Android 开源项目

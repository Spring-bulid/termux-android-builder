#!/data/data/com.termux/files/usr/bin/bash
# AnyKernel3 模板配置脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# AnyKernel3 安装目录
ANYKERNEL_DIR="$HOME/AnyKernel3"

# 克隆 AnyKernel3
clone_anykernel3() {
    print_info "克隆 AnyKernel3..."
    
    if [ -d "$ANYKERNEL_DIR" ]; then
        print_warning "AnyKernel3 目录已存在"
        read -p "是否更新？(y/N): " update
        if [ "$update" = "y" ] || [ "$update" = "Y" ]; then
            cd "$ANYKERNEL_DIR"
            git pull
        else
            print_info "跳过 AnyKernel3 更新"
            return
        fi
    else
        git clone https://github.com/osm0sis/AnyKernel3.git "$ANYKERNEL_DIR"
    fi
    
    print_success "AnyKernel3 下载完成"
}

# 配置 AnyKernel3
setup_anykernel3() {
    print_info "配置 AnyKernel3..."
    
    cd "$ANYKERNEL_DIR"
    
    # 创建默认配置
    cat > "anykernel.sh" << 'EOF'
# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=Kernel for Android Devices
do.devicecheck=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
device.name6=
device.name7=
device.name8=
device.name9=
supported.versions=
supported.patchlevels=
}; end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

## AnyKernel file attributes
# set permissions and ownership for extracted ramdisk files
chmod -R 750 $ramdisk
chown -R root:root $ramdisk

## AnyKernel install
kernelstring=Kernel for Android Devices
outfd=/proc/self/fd/$fd;
is_slot_device=$is_slot_device;
ramdisk_compression=$ramdisk_compression;
patch_vbmeta_flag=$patch_vbmeta_flag;

# begin properties
properties() {
kernel.string=$kernelstring
do.devicecheck=1
device.name1=$device.name1
device.name2=$device.name2
}; end properties

# patch neverallow
ui_print " ";
ui_print "- Patching SELinux neverallow...";
cd $patch;
patch -p1 -i neverallow-*.patch;
cd /;

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=$is_slot_device;
ramdisk_compression=$ramdisk_compression;
patch_vbmeta_flag=$patch_vbmeta_flag;

. tools/ak3-core.sh;
EOF
    
    print_success "AnyKernel3 配置完成"
}

# 创建设备配置模板
create_device_configs() {
    print_info "创建设备配置模板..."
    
    mkdir -p "$ANYKERNEL_DIR/device-configs"
    
    # 高通设备配置
    cat > "$ANYKERNEL_DIR/device-configs/qualcomm.sh" << 'EOF'
# 高通设备配置

# 分区设置
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;  # 支持 A/B 分区的设备设为 1
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# 设备信息
device.name1= OnePlus;
device.name2= Xiaomi;
device.name3= Samsung;
device.name4= Google;
device.name5= Sony;
EOF
    
    # 联发科设备配置
    cat > "$ANYKERNEL_DIR/device-configs/mediatek.sh" << 'EOF'
# 联发科设备配置

# 分区设置
block=/dev/block/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# 设备信息
device.name1= Redmi;
device.name2= Realme;
device.name3= Oppo;
device.name4= Vivo;
device.name5= Nothing;
EOF
    
    # 三星设备配置
    cat > "$ANYKERNEL_DIR/device-configs/samsung.sh" << 'EOF'
# 三星设备配置

# 分区设置
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;  # 三星通常使用 A/B 分区
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# 设备信息
device.name1= Galaxy;
device.name2= SM-;
EOF
    
    print_success "设备配置模板创建完成"
}

# 创建 AnyKernel3 使用说明
create_readme() {
    print_info "创建 AnyKernel3 使用说明..."
    
    cat > "$ANYKERNEL_DIR/README_CN.md" << 'EOF'
# AnyKernel3 使用说明

## 基本使用

1. 将编译好的内核 Image/Image.gz 放到 AnyKernel3 根目录
2. 编辑 `anykernel.sh` 配置文件
3. 运行打包脚本

## 配置文件说明

```bash
# 分区设置
block=/dev/block/bootdevice/by-name/boot;  # boot 分区路径
is_slot_device=0;  # 0=非 A/B 分区, 1=A/B 分区
ramdisk_compression=auto;  # ramdisk 压缩方式
patch_vbmeta_flag=auto;  # vbmeta 补丁标志
```

## 常用命令

```bash
# 打包内核
bash build.sh

# 或使用 zip 命令
zip -r9 kernel.zip * -x .git/*
```

## 设备配置

查看 `device-configs/` 目录获取不同设备的配置示例。

## 注意事项

1. 确保 `block` 路径正确
2. A/B 分区设备需要设置 `is_slot_device=1`
3. 不同设备的 boot 分区路径可能不同
EOF
    
    print_success "使用说明创建完成"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  AnyKernel3 配置程序${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    clone_anykernel3
    setup_anykernel3
    create_device_configs
    create_readme
    
    echo ""
    print_success "AnyKernel3 配置完成!"
    echo ""
    print_info "使用方法:"
    echo "  1. 进入 $ANYKERNEL_DIR 目录"
    echo "  2. 将编译好的内核 Image 放到该目录"
    echo "  3. 编辑 anykernel.sh 配置文件"
    echo "  4. 运行 'zip -r9 kernel.zip * -x .git/*' 打包"
    echo ""
}

# 运行
main "$@"

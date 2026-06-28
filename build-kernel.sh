#!/data/data/com.termux/files/usr/bin/bash
# Android 内核编译入口脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

# 工具链目录
TOOLCHAIN_DIR="$HOME/android-toolchain"
ANYKERNEL_DIR="$HOME/AnyKernel3"

# 默认值
KERNEL_SOURCE=""
DEVICE=""
DEFCONFIG=""
THREADS=$(nproc)
CLEAN_BUILD=0

# 显示帮助
show_help() {
    echo -e "${CYAN}Android 内核编译脚本${NC}"
    echo ""
    echo "使用方法:"
    echo "  bash build-kernel.sh [选项]"
    echo ""
    echo "选项:"
    echo "  -k, --kernel <路径>     内核源码路径"
    echo "  -d, --device <设备>     设备名称"
    echo "  -c, --config <配置>     defconfig 文件"
    echo "  -j, --jobs <数量>       编译线程数 (默认: $(nproc))"
    echo "  -C, --clean             清除之前的编译"
    echo "  -h, --help              显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  bash build-kernel.sh -k ~/kernel -d OnePlus9 -c vendor/oneplus9_defconfig"
    echo "  bash build-kernel.sh --kernel ~/kernel --clean"
    echo ""
}

# 检查环境
check_environment() {
    print_info "检查编译环境..."
    
    # 检查工具链
    if [ ! -d "$TOOLCHAIN_DIR" ]; then
        print_error "工具链未安装，请先运行 setup-toolchain.sh"
        exit 1
    fi
    
    # 检查 clang
    if [ ! -f "$TOOLCHAIN_DIR/clang/bin/clang" ]; then
        print_error "Clang 工具链未找到"
        exit 1
    fi
    
    # 检查 AnyKernel3
    if [ ! -d "$ANYKERNEL_DIR" ]; then
        print_error "AnyKernel3 未安装，请先运行 setup-anykernel3.sh"
        exit 1
    fi
    
    # 检查 Ubuntu 环境
    if ! command -v proot-distro &> /dev/null; then
        print_warning "proot-distro 未安装，建议在 Ubuntu 环境中编译"
    fi
    
    print_success "环境检查完成"
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -k|--kernel)
                KERNEL_SOURCE="$2"
                shift 2
                ;;
            -d|--device)
                DEVICE="$2"
                shift 2
                ;;
            -c|--config)
                DEFCONFIG="$2"
                shift 2
                ;;
            -j|--jobs)
                THREADS="$2"
                shift 2
                ;;
            -C|--clean)
                CLEAN_BUILD=1
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 交互式输入
    if [ -z "$KERNEL_SOURCE" ]; then
        read -p "请输入内核源码路径: " KERNEL_SOURCE
    fi
    
    # 验证内核源码路径
    if [ ! -d "$KERNEL_SOURCE" ]; then
        print_error "内核源码路径不存在: $KERNEL_SOURCE"
        exit 1
    fi
    
    # 检查是否是有效的内核源码
    if [ ! -f "$KERNEL_SOURCE/Makefile" ]; then
        print_error "未找到内核 Makefile，请确认这是有效的内核源码"
        exit 1
    fi
    
    # 如果没有指定 defconfig，尝试自动检测
    if [ -z "$DEFCONFIG" ]; then
        print_info "未指定 defconfig，尝试自动检测..."
        detect_defconfig
    fi
}

# 自动检测 defconfig
detect_defconfig() {
    cd "$KERNEL_SOURCE"
    
    # 尝试在常见位置查找 defconfig
    local locations=(
        "arch/arm64/configs/"
        "arch/arm/configs/"
        "vendor/"
        "device/"
    )
    
    local configs=()
    
    for location in "${locations[@]}"; do
        if [ -d "$location" ]; then
            while IFS= read -r -d '' file; do
                configs+=("$file")
            done < <(find "$location" -name "*defconfig" -print0 2>/dev/null)
        fi
    done
    
    if [ ${#configs[@]} -eq 0 ]; then
        print_error "未找到 defconfig 文件"
        print_info "请手动指定: -c <defconfig文件>"
        exit 1
    fi
    
    print_info "找到以下 defconfig 文件:"
    for i in "${!configs[@]}"; do
        echo "  $((i+1)). ${configs[$i]}"
    done
    
    read -p "请选择 (1-${#configs[@]}): " choice
    DEFCONFIG="${configs[$((choice-1))]}"
    
    print_info "已选择: $DEFCONFIG"
}

# 配置环境变量
setup_build_env() {
    print_info "配置编译环境..."
    
    export TOOLCHAIN_DIR
    export PATH="$TOOLCHAIN_DIR/clang/bin:$TOOLCHAIN_DIR/gcc/bin:$PATH"
    
    # Clang 环境变量
    export CC=clang
    export CXX=clang++
    export AR=llvm-ar
    export NM=llvm-nm
    export OBJCOPY=llvm-objcopy
    export OBJDUMP=llvm-objdump
    export STRIP=llvm-strip
    export LD=ld.lld
    
    # 交叉编译变量
    export CROSS_COMPILE=aarch64-linux-android-
    export ARCH=arm64
    export SUBARCH=arm64
    
    print_success "编译环境配置完成"
}

# 执行编译
build_kernel() {
    print_info "开始编译内核..."
    echo ""
    
    cd "$KERNEL_SOURCE"
    
    # 清除之前的编译
    if [ $CLEAN_BUILD -eq 1 ]; then
        print_info "清除之前的编译..."
        make clean 2>/dev/null || true
        make mrproper 2>/dev/null || true
    fi
    
    # 生成 .config
    print_info "生成 .config 文件..."
    make "$DEFCONFIG"
    
    # 编译内核
    print_info "编译内核 (使用 $THREADS 个线程)..."
    make -j"$THREADS" \
        CC=clang \
        AR=llvm-ar \
        NM=llvm-nm \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        LD=ld.lld \
        CLANG_TRIPLE=aarch64-linux-gnu- \
        CROSS_COMPILE=aarch64-linux-android-
    
    # 检查编译结果
    if [ -f "arch/arm64/boot/Image.gz" ] || [ -f "arch/arm64/boot/Image" ]; then
        print_success "内核编译成功!"
    else
        print_error "内核编译失败"
        exit 1
    fi
}

# 打包内核
package_kernel() {
    print_info "打包内核..."
    
    # 复制内核镜像到 AnyKernel3
    cp "$KERNEL_SOURCE/arch/arm64/boot/Image"* "$ANYKERNEL_DIR/" 2>/dev/null || true
    
    # 进入 AnyKernel3 目录
    cd "$ANYKERNEL_DIR"
    
    # 创建 zip 包
    zip -r9 kernel.zip * -x .git/*
    
    if [ -f "kernel.zip" ]; then
        print_success "内核打包成功!"
        print_info "输出文件: $ANYKERNEL_DIR/kernel.zip"
    else
        print_error "内核打包失败"
        exit 1
    fi
}

# 主函数
main() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Android 内核编译脚本${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    parse_args "$@"
    check_environment
    setup_build_env
    build_kernel
    package_kernel
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  编译完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    print_info "输出文件: $ANYKERNEL_DIR/kernel.zip"
    print_info "可以使用 Magisk 或 TWRP 刷入此内核"
    echo ""
}

# 运行
main "$@"

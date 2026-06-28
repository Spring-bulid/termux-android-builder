#!/data/data/com.termux/files/usr/bin/bash
# ARM 交叉编译工具链安装脚本

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

# 工具链安装目录
TOOLCHAIN_DIR="$HOME/android-toolchain"

# AOSP Clang 版本
CLANG_VERSION="r416183b"
CLANG_URL="https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-${CLANG_VERSION}.tar.gz"

# GCC 版本
GCC_VERSION="4.9"
GCC_URL="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-${GCC_VERSION}/+archive/refs/heads/main.tar.gz"

# 下载 Clang 工具链
download_clang() {
    print_info "下载 AOSP Clang 工具链..."
    
    mkdir -p "$TOOLCHAIN_DIR/clang"
    cd /tmp
    
    if [ ! -f "clang.tar.gz" ]; then
        wget -q --show-progress "$CLANG_URL" -O clang.tar.gz
    fi
    
    print_info "解压 Clang..."
    tar -xzf clang.tar.gz -C "$TOOLCHAIN_DIR/clang"
    rm -f /tmp/clang.tar.gz
    
    print_success "Clang 工具链下载完成"
}

# 下载 GCC 工具链
download_gcc() {
    print_info "下载 GCC 工具链..."
    
    mkdir -p "$TOOLCHAIN_DIR/gcc"
    cd /tmp
    
    if [ ! -f "gcc.tar.gz" ]; then
        wget -q --show-progress "$GCC_URL" -O gcc.tar.gz
    fi
    
    print_info "解压 GCC..."
    tar -xzf gcc.tar.gz -C "$TOOLCHAIN_DIR/gcc"
    rm -f /tmp/gcc.tar.gz
    
    print_success "GCC 工具链下载完成"
}

# 下载内核 Binutils
download_binutils() {
    print_info "下载内核 Binutils..."
    
    mkdir -p "$TOOLCHAIN_DIR/binutils"
    
    BINUTILS_URL="https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+/refs/heads/main/aarch64-linux-android/bin"
    
    # 使用 wget 下载 binutils
    cd "$TOOLCHAIN_DIR/binutils"
    
    for tool in as ld objcopy objdump strip; do
        if [ ! -f "$tool" ]; then
            wget -q "$BINUTILS_URL/$tool" || true
            chmod +x "$tool" 2>/dev/null || true
        fi
    done
    
    print_success "Binutils 下载完成"
}

# 配置环境变量
setup_environment() {
    print_info "配置工具链环境变量..."
    
    PROFILE_FILE="$HOME/.bashrc"
    
    # 检查是否已经配置
    if grep -q "TOOLCHAIN_DIR" "$PROFILE_FILE" 2>/dev/null; then
        print_warning "工具链环境变量已存在，跳过配置"
        return
    fi
    
    # 添加环境变量
    cat >> "$PROFILE_FILE" << 'EOF'

# Android 编译工具链环境变量
export TOOLCHAIN_DIR="$HOME/android-toolchain"
export PATH="$TOOLCHAIN_DIR/clang/bin:$TOOLCHAIN_DIR/gcc/bin:$TOOLCHAIN_DIR/binutils:$PATH"

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

# 内核编译变量
export KERNEL_MAKE="make"
export KERNEL_CROSS_COMPILE="$TOOLCHAIN_DIR/clang/bin/aarch64-linux-android-"
EOF
    
    print_success "环境变量配置完成"
}

# 创建工具链包装脚本
create_wrapper_scripts() {
    print_info "创建工具链包装脚本..."
    
    mkdir -p "$TOOLCHAIN_DIR/bin"
    
    # 创建 clang 包装脚本
    cat > "$TOOLCHAIN_DIR/bin/clang-kernel" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# 内核编译 Clang 包装脚本

TOOLCHAIN_DIR="$HOME/android-toolchain"
CLANG_DIR="$TOOLCHAIN_DIR/clang"

# 设置默认标志
CFLAGS="--target=aarch64-linux-gnu --sysroot=$CLANG_DIR/sysroot"
LDFLAGS="--target=aarch64-linux-gnu --sysroot=$CLANG_DIR/sysroot"

# 执行 clang
exec "$CLANG_DIR/bin/clang" $CFLAGS "$@"
EOF
    chmod +x "$TOOLCHAIN_DIR/bin/clang-kernel"
    
    # 创建 gcc 包装脚本
    cat > "$TOOLCHAIN_DIR/bin/gcc-kernel" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# 内核编译 GCC 包装脚本

TOOLCHAIN_DIR="$HOME/android-toolchain"
GCC_DIR="$TOOLCHAIN_DIR/gcc"

# 执行 gcc
exec "$GCC_DIR/bin/aarch64-linux-android-gcc" "$@"
EOF
    chmod +x "$TOOLCHAIN_DIR/bin/gcc-kernel"
    
    print_success "包装脚本创建完成"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  ARM 交叉编译工具链安装程序${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # 检查是否已安装
    if [ -d "$TOOLCHAIN_DIR" ] && [ -f "$TOOLCHAIN_DIR/clang/bin/clang" ]; then
        print_warning "工具链已安装在 $TOOLCHAIN_DIR"
        read -p "是否重新安装？(y/N): " reinstall
        if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
            print_info "跳过工具链安装"
            return
        fi
        rm -rf "$TOOLCHAIN_DIR"
    fi
    
    download_clang
    download_gcc
    download_binutils
    create_wrapper_scripts
    setup_environment
    
    echo ""
    print_success "ARM 交叉编译工具链安装完成!"
    echo ""
}

# 运行
main "$@"

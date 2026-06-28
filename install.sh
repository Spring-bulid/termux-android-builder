#!/data/data/com.termux/files/usr/bin/bash
# Termux 全能 Android 编译包 - 主安装脚本
# 适用于所有设备，兼容 Android 12-15

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 打印带颜色的消息
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

print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Termux Android 编译包安装程序${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# 检查是否在 Termux 环境中
check_termux() {
    if [ -d "/data/data/com.termux" ]; then
        print_success "检测到 Termux 环境"
        return 0
    else
        print_error "此脚本只能在 Termux 中运行"
        exit 1
    fi
}

# 检查存储权限
check_storage() {
    if [ -d "/sdcard" ] && [ -r "/sdcard" ]; then
        print_success "存储权限正常"
        return 0
    else
        print_warning "存储权限未授予，正在请求..."
        termux-setup-storage
        sleep 2
        if [ -d "/sdcard" ] && [ -r "/sdcard" ]; then
            print_success "存储权限已授予"
            return 0
        else
            print_error "无法获取存储权限"
            return 1
        fi
    fi
}

# 更新 Termux 包管理器
update_packages() {
    print_info "更新 Termux 包管理器..."
    pkg update -y
    pkg upgrade -y
}

# 安装基础依赖
install_base_deps() {
    print_info "安装基础依赖..."
    pkg install -y \
        wget \
        curl \
        git \
        zip \
        unzip \
        tar \
        xz-utils \
        proot \
        proot-distro \
        jq \
        python
}

# 主安装流程
main() {
    clear
    print_header
    
    # 检查环境
    check_termux
    check_storage
    
    # 更新和安装基础依赖
    update_packages
    install_base_deps
    
    print_info "基础环境准备完成"
    echo ""
    print_info "接下来将安装各个组件..."
    echo ""
    
    # 安装 Android SDK
    print_info "步骤 1/4: 安装 Android SDK..."
    bash "$SCRIPT_DIR/setup-sdk.sh"
    
    # 安装 ARM 工具链
    print_info "步骤 2/4: 安装 ARM 交叉编译工具链..."
    bash "$SCRIPT_DIR/setup-toolchain.sh"
    
    # 安装 Ubuntu chroot
    print_info "步骤 3/4: 安装 Ubuntu chroot 环境..."
    bash "$SCRIPT_DIR/setup-ubuntu.sh"
    
    # 安装 AnyKernel3
    print_info "步骤 4/4: 配置 AnyKernel3..."
    bash "$SCRIPT_DIR/setup-anykernel3.sh"
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  安装完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    print_info "使用方法:"
    echo "  1. 运行 'bash build-kernel.sh' 开始编译内核"
    echo "  2. 运行 'bash enter-chroot.sh' 进入 Ubuntu 环境"
    echo "  3. 运行 'bash env-check.sh' 检查环境配置"
    echo ""
    print_info "详细说明请查看 README.md"
}

# 运行主函数
main "$@"

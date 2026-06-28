#!/data/data/com.termux/files/usr/bin/bash
# 进入 Ubuntu chroot 环境脚本

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

# Ubuntu 目录
UBUNTU_DIR="$HOME/ubuntu-rootfs"
TOOLCHAIN_DIR="$HOME/android-toolchain"

# 检查 Ubuntu 是否安装
check_ubuntu() {
    if [ ! -d "$UBUNTU_DIR" ]; then
        print_error "Ubuntu 未安装，请先运行 setup-ubuntu.sh"
        exit 1
    fi
    
    if ! command -v proot &> /dev/null; then
        print_error "proot 未安装"
        exit 1
    fi
}

# 进入 Ubuntu 环境
enter_ubuntu() {
    print_info "进入 Ubuntu 环境..."
    echo ""
    
    # 检查工具链是否存在
    local toolchain_args=""
    if [ -d "$TOOLCHAIN_DIR" ]; then
        toolchain_args="-b $TOOLCHAIN_DIR:/opt/toolchain"
    fi
    
    # 进入 proot
    proot \
        --link2symlink \
        -0 \
        -r "$UBUNTU_DIR" \
        -b /dev \
        -b /proc \
        -b /sys \
        $toolchain_args \
        -w /root \
        /usr/bin/env -i \
        HOME=/root \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        TERM="$TERM" \
        LANG=C.UTF-8 \
        /bin/bash --login
}

# 安装内核编译依赖
install_deps() {
    print_info "安装内核编译依赖..."
    
    proot \
        --link2symlink \
        -0 \
        -r "$UBUNTU_DIR" \
        -b /dev \
        -b /proc \
        -b /sys \
        -w /root \
        /usr/bin/env -i \
        HOME=/root \
        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        TERM="$TERM" \
        LANG=C.UTF-8 \
        /bin/bash --login -c "
            apt update && apt upgrade -y && \
            apt install -y \
                build-essential \
                flex \
                bison \
                libssl-dev \
                libncurses-dev \
                bc \
                cpio \
                kmod \
                rsync \
                dtc \
                wget \
                curl \
                git \
                zip \
                unzip \
                python3 \
                python3-pip \
                gcc-aarch64-linux-gnu \
                gcc-arm-linux-gnueabi \
                libboost-all-dev \
                libncurses5 \
                libgmp3-dev \
                libmpfr-dev \
                libmpc-dev \
                && rm -rf /var/lib/apt/lists/*
        "
    
    print_success "依赖安装完成"
}

# 显示帮助
show_help() {
    echo -e "${BLUE}Ubuntu chroot 环境管理脚本${NC}"
    echo ""
    echo "使用方法:"
    echo "  bash enter-chroot.sh [选项]"
    echo ""
    echo "选项:"
    echo "  (无参数)           进入 Ubuntu 环境"
    echo "  -i, --install      安装内核编译依赖"
    echo "  -h, --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  bash enter-chroot.sh          # 进入 Ubuntu 环境"
    echo "  bash enter-chroot.sh -i       # 安装依赖后进入"
    echo ""
}

# 主函数
main() {
    local install_deps_flag=0
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--install)
                install_deps_flag=1
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
    
    check_ubuntu
    
    if [ $install_deps_flag -eq 1 ]; then
        install_deps
    fi
    
    enter_ubuntu
}

# 运行
main "$@"

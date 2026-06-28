#!/data/data/com.termux/files/usr/bin/bash
# Ubuntu chroot 环境安装脚本

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

# Ubuntu 安装目录
UBUNTU_DIR="$HOME/ubuntu-rootfs"
PROOT_SCRIPT="$HOME/enter-ubuntu.sh"

# 安装 proot-distro
install_proot_distro() {
    print_info "检查 proot-distro..."
    
    if ! command -v proot-distro &> /dev/null; then
        print_info "安装 proot-distro..."
        pkg install -y proot-distro
    fi
    
    print_success "proot-distro 已就绪"
}

# 安装 Ubuntu
install_ubuntu() {
    print_info "安装 Ubuntu 22.04 (arm64)..."
    
    # 检查是否已安装
    if proot-distro list 2>/dev/null | grep -q "ubuntu"; then
        print_warning "Ubuntu 已安装"
        read -p "是否重新安装？(y/N): " reinstall
        if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
            print_info "跳过 Ubuntu 安装"
            return
        fi
        proot-distro remove ubuntu 2>/dev/null || true
    fi
    
    # 安装 Ubuntu
    proot-distro install ubuntu
    
    print_success "Ubuntu 安装完成"
}

# 配置 Ubuntu 环境
setup_ubuntu_env() {
    print_info "配置 Ubuntu 环境..."
    
    # 创建启动脚本
    cat > "$PROOT_SCRIPT" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# 进入 Ubuntu chroot 环境

# 安装内核编译依赖的脚本
SETUP_SCRIPT='
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
    bc \
    libboost-all-dev \
    libncurses5 \
    libgmp3-dev \
    libmpfr-dev \
    libmpc-dev \
    && rm -rf /var/lib/apt/lists/*
'

# 执行 proot
proot \
    --link2symlink \
    -0 \
    -r "$HOME/ubuntu-rootfs" \
    -b /dev \
    -b /proc \
    -b /sys \
    -w /root \
    /usr/bin/env -i \
    HOME=/root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TERM="$TERM" \
    LANG=C.UTF-8 \
    /bin/bash --login -c "echo '正在配置 Ubuntu 环境...' && eval '$SETUP_SCRIPT' && echo '配置完成!' && /bin/bash"
EOF
    chmod +x "$PROOT_SCRIPT"
    
    print_success "Ubuntu 环境配置完成"
}

# 创建快速启动脚本
create_quick_launch() {
    print_info "创建快速启动脚本..."
    
    cat > "$HOME/ubuntu" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# 快速启动 Ubuntu

proot \
    --link2symlink \
    -0 \
    -r "$HOME/ubuntu-rootfs" \
    -b /dev \
    -b /proc \
    -b /sys \
    -w /root \
    /usr/bin/env -i \
    HOME=/root \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    TERM="$TERM" \
    LANG=C.UTF-8 \
    /bin/bash --login
EOF
    chmod +x "$HOME/ubuntu"
    
    print_success "快速启动脚本创建完成"
    print_info "现在可以使用 'ubuntu' 命令快速进入 Ubuntu 环境"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Ubuntu chroot 环境安装程序${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    install_proot_distro
    install_ubuntu
    setup_ubuntu_env
    create_quick_launch
    
    echo ""
    print_success "Ubuntu chroot 环境安装完成!"
    echo ""
    print_info "使用方法:"
    echo "  1. 运行 'ubuntu' 快速进入 Ubuntu 环境"
    echo "  2. 运行 'bash enter-chroot.sh' 进入环境并配置依赖"
    echo ""
}

# 运行
main "$@"

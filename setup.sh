#!/data/data/com.termux/files/usr/bin/bash
# Termux Android 编译包 - 一键安装脚本
# 用户可以直接在 Termux 中运行此脚本安装

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

# GitHub 仓库地址
REPO_URL="https://github.com/your-username/termux-android-builder.git"
INSTALL_DIR="$HOME/termux-android-builder"

# 检查 Termux 环境
check_termux() {
    if [ ! -d "/data/data/com.termux" ]; then
        print_error "此脚本只能在 Termux 中运行"
        exit 1
    fi
    print_success "Termux 环境检测通过"
}

# 安装基础依赖
install_base_deps() {
    print_info "安装基础依赖..."
    pkg update -y
    pkg install -y git wget curl
    print_success "基础依赖安装完成"
}

# 克隆仓库
clone_repo() {
    print_info "下载编译包..."
    
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "目录已存在: $INSTALL_DIR"
        read -p "是否更新？(y/N): " update
        if [ "$update" = "y" ] || [ "$update" = "Y" ]; then
            cd "$INSTALL_DIR"
            git pull
        else
            print_info "跳过下载"
            return
        fi
    else
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
    
    print_success "下载完成"
}

# 运行安装
run_install() {
    print_info "运行安装脚本..."
    cd "$INSTALL_DIR"
    bash install.sh
}

# 主函数
main() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Termux Android 编译包一键安装${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    check_termux
    install_base_deps
    clone_repo
    run_install
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  安装完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    print_info "使用方法:"
    echo "  cd $INSTALL_DIR"
    echo "  bash build-kernel.sh -k ~/kernel"
    echo ""
}

# 运行
main "$@"

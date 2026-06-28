#!/data/data/com.termux/files/usr/bin/bash
# Android SDK 安装脚本

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

# SDK 安装目录
ANDROID_HOME="$HOME/android-sdk"
ANDROID_CMD_TOOLS_VERSION="9477386"
ANDROID_BUILD_TOOLS_VERSION="34.0.0"

# 下载 Android SDK command-line tools
download_sdk() {
    print_info "下载 Android SDK command-line tools..."
    
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    cd /tmp
    
    # 下载最新的 command-line tools
    SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMD_TOOLS_VERSION}_latest.zip"
    
    if [ ! -f "commandlinetools.zip" ]; then
        wget -q --show-progress "$SDK_URL" -O commandlinetools.zip
    fi
    
    print_info "解压 SDK..."
    unzip -q -o commandlinetools.zip -d /tmp/sdk_temp
    rm -rf "$ANDROID_HOME/cmdline-tools/latest"
    mv /tmp/sdk_temp/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
    rm -rf /tmp/sdk_temp /tmp/commandlinetools.zip
    
    print_success "SDK command-line tools 下载完成"
}

# 安装 SDK 组件
install_sdk_components() {
    print_info "安装 SDK 组件..."
    
    export ANDROID_HOME
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
    
    # 接受许可证
    yes | sdkmanager --licenses > /dev/null 2>&1 || true
    
    # 安装必要的组件
    sdkmanager --install \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        2>/dev/null || {
            print_warning "SDK 组件安装可能需要手动确认"
            yes | sdkmanager --install \
                "platform-tools" \
                "platforms;android-34" \
                "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
        }
    
    print_success "SDK 组件安装完成"
}

# 配置环境变量
setup_environment() {
    print_info "配置 Android SDK 环境变量..."
    
    PROFILE_FILE="$HOME/.bashrc"
    
    # 检查是否已经配置
    if grep -q "ANDROID_HOME" "$PROFILE_FILE" 2>/dev/null; then
        print_warning "Android SDK 环境变量已存在，跳过配置"
        return
    fi
    
    # 添加环境变量
    cat >> "$PROFILE_FILE" << 'EOF'

# Android SDK 环境变量
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:$PATH"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
EOF
    
    print_success "环境变量配置完成"
    print_info "请运行 'source ~/.bashrc' 或重新打开终端以生效"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Android SDK 安装程序${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # 检查是否已安装
    if [ -d "$ANDROID_HOME" ] && [ -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        print_warning "Android SDK 已安装在 $ANDROID_HOME"
        read -p "是否重新安装？(y/N): " reinstall
        if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
            print_info "跳过 SDK 安装"
            return
        fi
    fi
    
    download_sdk
    install_sdk_components
    setup_environment
    
    echo ""
    print_success "Android SDK 安装完成!"
    echo ""
}

# 运行
main "$@"

#!/data/data/com.termux/files/usr/bin/bash
# 环境检查脚本

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

# 检查项计数
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# 检查函数
check() {
    local name="$1"
    local result="$2"
    local message="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    case $result in
        "pass")
            echo -e "  ${GREEN}✓${NC} $name"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            ;;
        "warn")
            echo -e "  ${YELLOW}!${NC} $name: $message"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            ;;
        "fail")
            echo -e "  ${RED}✗${NC} $name: $message"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            ;;
    esac
}

# 检查 Termux 环境
check_termux() {
    echo -e "\n${CYAN}1. Termux 环境${NC}"
    
    if [ -d "/data/data/com.termux" ]; then
        check "Termux 环境" "pass"
    else
        check "Termux 环境" "fail" "此脚本只能在 Termux 中运行"
    fi
    
    if [ -d "/sdcard" ] && [ -r "/sdcard" ]; then
        check "存储权限" "pass"
    else
        check "存储权限" "warn" "存储权限未授予"
    fi
}

# 检查基础工具
check_base_tools() {
    echo -e "\n${CYAN}2. 基础工具${NC}"
    
    local tools=(
        "wget"
        "curl"
        "git"
        "zip"
        "unzip"
        "tar"
        "proot"
        "proot-distro"
        "jq"
        "python"
    )
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            check "$tool" "pass"
        else
            check "$tool" "fail" "未安装"
        fi
    done
}

# 检查 Android SDK
check_android_sdk() {
    echo -e "\n${CYAN}3. Android SDK${NC}"
    
    local sdk_dir="$HOME/android-sdk"
    
    if [ -d "$sdk_dir" ]; then
        check "SDK 目录" "pass"
        
        if [ -f "$sdk_dir/cmdline-tools/latest/bin/sdkmanager" ]; then
            check "SDK Manager" "pass"
        else
            check "SDK Manager" "fail" "未找到 sdkmanager"
        fi
        
        if [ -d "$sdk_dir/platform-tools" ]; then
            check "Platform Tools" "pass"
        else
            check "Platform Tools" "warn" "未安装 platform-tools"
        fi
    else
        check "SDK 目录" "fail" "SDK 未安装"
    fi
}

# 检查工具链
check_toolchain() {
    echo -e "\n${CYAN}4. ARM 交叉编译工具链${NC}"
    
    local toolchain_dir="$HOME/android-toolchain"
    
    if [ -d "$toolchain_dir" ]; then
        check "工具链目录" "pass"
        
        if [ -f "$toolchain_dir/clang/bin/clang" ]; then
            check "Clang 工具链" "pass"
        else
            check "Clang 工具链" "fail" "未找到 clang"
        fi
        
        if [ -d "$toolchain_dir/gcc" ]; then
            check "GCC 工具链" "pass"
        else
            check "GCC 工具链" "warn" "GCC 工具链未安装"
        fi
        
        if [ -d "$toolchain_dir/binutils" ]; then
            check "Binutils" "pass"
        else
            check "Binutils" "warn" "Binutils 未安装"
        fi
    else
        check "工具链目录" "fail" "工具链未安装"
    fi
}

# 检查 Ubuntu 环境
check_ubuntu() {
    echo -e "\n${CYAN}5. Ubuntu chroot 环境${NC}"
    
    if command -v proot-distro &> /dev/null; then
        check "proot-distro" "pass"
        
        if proot-distro list 2>/dev/null | grep -q "ubuntu"; then
            check "Ubuntu" "pass"
        else
            check "Ubuntu" "fail" "Ubuntu 未安装"
        fi
    else
        check "proot-distro" "fail" "proot-distro 未安装"
    fi
}

# 检查 AnyKernel3
check_anykernel3() {
    echo -e "\n${CYAN}6. AnyKernel3${NC}"
    
    local anykernel_dir="$HOME/AnyKernel3"
    
    if [ -d "$anykernel_dir" ]; then
        check "AnyKernel3 目录" "pass"
        
        if [ -f "$anykernel_dir/anykernel.sh" ]; then
            check "AnyKernel3 配置" "pass"
        else
            check "AnyKernel3 配置" "warn" "配置文件不存在"
        fi
        
        if [ -d "$anykernel_dir/device-configs" ]; then
            check "设备配置模板" "pass"
        else
            check "设备配置模板" "warn" "设备配置模板不存在"
        fi
    else
        check "AnyKernel3 目录" "fail" "AnyKernel3 未安装"
    fi
}

# 检查环境变量
check_env_vars() {
    echo -e "\n${CYAN}7. 环境变量${NC}"
    
    if [ -n "$ANDROID_HOME" ]; then
        check "ANDROID_HOME" "pass"
    else
        check "ANDROID_HOME" "warn" "未设置"
    fi
    
    if [ -n "$TOOLCHAIN_DIR" ]; then
        check "TOOLCHAIN_DIR" "pass"
    else
        check "TOOLCHAIN_DIR" "warn" "未设置"
    fi
    
    if [ -n "$ARCH" ] && [ "$ARCH" = "arm64" ]; then
        check "ARCH" "pass"
    else
        check "ARCH" "warn" "未设置为 arm64"
    fi
    
    if [ -n "$CROSS_COMPILE" ]; then
        check "CROSS_COMPILE" "pass"
    else
        check "CROSS_COMPILE" "warn" "未设置"
    fi
}

# 检查系统资源
check_system_resources() {
    echo -e "\n${CYAN}8. 系统资源${NC}"
    
    # 检查内存
    local total_mem=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "0")
    if [ "$total_mem" -gt 4000 ]; then
        check "内存 ($total_mem MB)" "pass"
    elif [ "$total_mem" -gt 2000 ]; then
        check "内存 ($total_mem MB)" "warn" "内存较低，编译可能较慢"
    elif [ "$total_mem" -gt 0 ]; then
        check "内存 ($total_mem MB)" "fail" "内存不足，建议至少 4GB"
    else
        check "内存检测" "warn" "无法检测内存"
    fi
    
    # 检查存储空间
    local free_space=$(df -m /data 2>/dev/null | awk 'NR==2{print $4}' || echo "0")
    if [ "$free_space" -gt 10000 ]; then
        check "存储空间 ($free_space MB)" "pass"
    elif [ "$free_space" -gt 5000 ]; then
        check "存储空间 ($free_space MB)" "warn" "存储空间较低"
    elif [ "$free_space" -gt 0 ]; then
        check "存储空间 ($free_space MB)" "fail" "存储空间不足，建议至少 10GB"
    else
        check "存储空间检测" "warn" "无法检测存储空间"
    fi
}

# 显示总结
show_summary() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}  环境检查总结${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "总检查项: ${TOTAL_CHECKS}"
    echo -e "${GREEN}通过: ${PASSED_CHECKS}${NC}"
    echo -e "${YELLOW}警告: ${WARNING_CHECKS}${NC}"
    echo -e "${RED}失败: ${FAILED_CHECKS}${NC}"
    echo ""
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}✓ 环境检查通过! 可以开始编译内核。${NC}"
    else
        echo -e "${RED}✗ 环境检查未完全通过，请解决上述问题后再编译。${NC}"
    fi
    echo ""
}

# 主函数
main() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Termux Android 编译环境检查${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    check_termux
    check_base_tools
    check_android_sdk
    check_toolchain
    check_ubuntu
    check_anykernel3
    check_env_vars
    check_system_resources
    
    show_summary
}

# 运行
main "$@"

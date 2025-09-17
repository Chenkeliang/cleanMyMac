#!/bin/bash
# Mac 智能系统清理工具
# 适用于所有 macOS 系统的磁盘空间优化
# 版本: 1.0
# 开源项目: https://github.com/Chenkeliang/cleanMyMac

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 全局变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/cleanup_$(date +%Y%m%d_%H%M%S).log"
BACKUP_DIR="$SCRIPT_DIR/backup_$(date +%Y%m%d_%H%M%S)"

# 清理选项 (默认选中安全项目)
CLEANUP_TIMEMACHINE_SNAPSHOTS=1    # Time Machine 本地快照 (默认选中)
CLEANUP_DEV_CACHES=1               # 开发工具缓存 (默认选中)
CLEANUP_SYSTEM_LOGS=1              # 系统日志 (默认选中)
CLEANUP_SLEEP_IMAGE=1              # 休眠镜像 (默认选中)
CLEANUP_SYSTEM_CACHES=1            # 系统缓存 (默认选中)
CLEANUP_APP_CACHES=0               # 应用程序缓存 (默认不选中)
CLEANUP_TRASH=1                    # 废纸篓 (默认选中)
CLEANUP_DOWNLOADS_VIDEOS=0         # Downloads大文件清理 (默认不选中)

# 记录初始状态
INITIAL_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
INITIAL_AVAIL=$(df -h / | tail -1 | awk '{print $4}')
TOTAL_FREED=0

# 日志函数
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    case $level in
        "INFO")  echo -e "${BLUE}ℹ️  $message${NC}" ;;
        "WARN")  echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "ERROR") echo -e "${RED}❌ $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ $message${NC}" ;;
        "PROGRESS") echo -e "${CYAN}🔄 $message${NC}" ;;
    esac
}

# 进度条函数
show_progress() {
    local current=$1
    local total=$2
    local description="$3"
    local progress=$((current * 100 / total))
    local bar_length=50
    local filled_length=$((progress * bar_length / 100))

    printf "\r${CYAN}[${"
    printf "%${filled_length}s" | tr ' ' '='
    printf "%$((bar_length - filled_length))s" | tr ' ' '-'
    printf "}] %3d%% %s${NC}" "$progress" "$description"

    if [ $current -eq $total ]; then
        echo
    fi
}

# 获取文件/目录大小
get_size() {
    local path="$1"
    if [ -e "$path" ]; then
        du -sh "$path" 2>/dev/null | awk '{print $1}' || echo "0B"
    else
        echo "0B"
    fi
}

# 安全删除函数
safe_remove() {
    local path="$1"
    local description="$2"
    local backup_enabled="${3:-0}"

    if [ ! -e "$path" ]; then
        log "WARN" "路径不存在，跳过: $path"
        return 0
    fi

    local size=$(get_size "$path")
    log "PROGRESS" "正在清理: $description ($size)"

    # 备份重要文件 (如果启用)
    if [ "$backup_enabled" = "1" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -R "$path" "$BACKUP_DIR/" 2>/dev/null || log "WARN" "备份失败: $path"
    fi

    # 删除文件/目录
    if rm -rf "$path" 2>/dev/null; then
        log "SUCCESS" "已清理: $description ($size)"
        return 0
    else
        log "ERROR" "清理失败: $description"
        return 1
    fi
}

# 显示清理选项菜单
show_cleanup_menu() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║               Mac 智能系统清理工具 v1.0                      ║${NC}"
    echo -e "${PURPLE}║              释放磁盘空间，优化系统性能                      ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}📊 当前磁盘状态:${NC}"
    echo -e "   使用率: ${INITIAL_USAGE}%"
    echo -e "   可用空间: ${INITIAL_AVAIL}"
    echo
    echo -e "${YELLOW}请选择要执行的清理项目 (默认已选中安全项目):${NC}"
    echo

    # 显示清理选项
    echo -e " 1. [$([ $CLEANUP_TIMEMACHINE_SNAPSHOTS -eq 1 ] && echo '✓' || echo ' ')] Time Machine 本地快照清理     ${GREEN}(推荐, 可释放大量空间)${NC}"
    echo -e " 2. [$([ $CLEANUP_DEV_CACHES -eq 1 ] && echo '✓' || echo ' ')] 开发工具缓存清理               ${GREEN}(安全, 可释放3-5GB)${NC}"
    echo -e " 3. [$([ $CLEANUP_SYSTEM_LOGS -eq 1 ] && echo '✓' || echo ' ')] 系统日志清理                   ${GREEN}(安全, 可释放1-3GB)${NC}"
    echo -e " 4. [$([ $CLEANUP_SLEEP_IMAGE -eq 1 ] && echo '✓' || echo ' ')] 休眠镜像清理                   ${GREEN}(安全, 可释放1GB)${NC}"
    echo -e " 5. [$([ $CLEANUP_SYSTEM_CACHES -eq 1 ] && echo '✓' || echo ' ')] 系统缓存清理                   ${GREEN}(安全, 可释放2-5GB)${NC}"
    echo -e " 6. [$([ $CLEANUP_APP_CACHES -eq 1 ] && echo '✓' || echo ' ')] 应用程序缓存清理               ${YELLOW}(谨慎, 可释放2-3GB)${NC}"
    echo -e " 7. [$([ $CLEANUP_TRASH -eq 1 ] && echo '✓' || echo ' ')] 废纸篓清理                       ${GREEN}(安全)${NC}"
    echo -e " 8. [$([ $CLEANUP_DOWNLOADS_VIDEOS -eq 1 ] && echo '✓' || echo ' ')] Downloads大文件清理             ${YELLOW}(谨慎选择)${NC}"
    echo
    echo -e "${CYAN}操作选项:${NC}"
    echo -e " s) 开始清理 (执行选中的项目)"
    echo -e " a) 全选安全项目"
    echo -e " c) 取消全选"
    echo -e " 1-8) 切换对应项目的选择状态"
    echo -e " q) 退出"
    echo
}

# 处理用户输入
handle_user_input() {
    while true; do
        show_cleanup_menu
        echo -ne "${BLUE}请选择操作: ${NC}"
        read -r choice

        case $choice in
            1) CLEANUP_TIMEMACHINE_SNAPSHOTS=$((1 - CLEANUP_TIMEMACHINE_SNAPSHOTS)) ;;
            2) CLEANUP_DEV_CACHES=$((1 - CLEANUP_DEV_CACHES)) ;;
            3) CLEANUP_SYSTEM_LOGS=$((1 - CLEANUP_SYSTEM_LOGS)) ;;
            4) CLEANUP_SLEEP_IMAGE=$((1 - CLEANUP_SLEEP_IMAGE)) ;;
            5) CLEANUP_SYSTEM_CACHES=$((1 - CLEANUP_SYSTEM_CACHES)) ;;
            6) CLEANUP_APP_CACHES=$((1 - CLEANUP_APP_CACHES)) ;;
            7) CLEANUP_TRASH=$((1 - CLEANUP_TRASH)) ;;
            8) CLEANUP_DOWNLOADS_VIDEOS=$((1 - CLEANUP_DOWNLOADS_VIDEOS)) ;;
            a|A)
                CLEANUP_TIMEMACHINE_SNAPSHOTS=1
                CLEANUP_DEV_CACHES=1
                CLEANUP_SYSTEM_LOGS=1
                CLEANUP_SLEEP_IMAGE=1
                CLEANUP_SYSTEM_CACHES=1
                CLEANUP_TRASH=1
                ;;
            c|C)
                CLEANUP_TIMEMACHINE_SNAPSHOTS=0
                CLEANUP_DEV_CACHES=0
                CLEANUP_SYSTEM_LOGS=0
                CLEANUP_SLEEP_IMAGE=0
                CLEANUP_SYSTEM_CACHES=0
                CLEANUP_APP_CACHES=0
                CLEANUP_TRASH=0
                CLEANUP_DOWNLOADS_VIDEOS=0
                ;;
            s|S) return 0 ;;
            q|Q)
                echo -e "${YELLOW}退出清理工具${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选择，请重试${NC}"
                sleep 1
                ;;
        esac
    done
}

# Time Machine 快照清理
cleanup_timemachine_snapshots() {
    if [ $CLEANUP_TIMEMACHINE_SNAPSHOTS -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理 Time Machine 本地快照..."

    # 获取快照列表
    local snapshots=$(sudo tmutil listlocalsnapshots / 2>/dev/null | grep -v "Snapshot" || true)

    if [ -z "$snapshots" ]; then
        log "INFO" "没有发现本地快照"
        return 0
    fi

    local snapshot_count=$(echo "$snapshots" | wc -l | tr -d ' ')
    log "INFO" "发现 $snapshot_count 个本地快照"

    local current=0
    while IFS= read -r snapshot; do
        if [ -n "$snapshot" ]; then
            current=$((current + 1))
            show_progress $current $snapshot_count "删除快照: $(basename $snapshot)"

            if sudo tmutil deletelocalsnapshots "$(basename "$snapshot")" >/dev/null 2>&1; then
                log "SUCCESS" "已删除快照: $(basename $snapshot)"
            else
                log "ERROR" "删除快照失败: $(basename $snapshot)"
            fi
        fi
    done <<< "$snapshots"

    log "SUCCESS" "Time Machine 快照清理完成"
}

# 开发工具缓存清理
cleanup_dev_caches() {
    if [ $CLEANUP_DEV_CACHES -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理开发工具缓存..."

    local caches=(
        "$HOME/.cache/puppeteer"
        "$HOME/.cache/github-copilot"
        "$HOME/.cache/huggingface"
        "$HOME/.cache/phpactor"
        "$HOME/.cache/vscode-ripgrep"
        "$HOME/.npm"
        "$HOME/Library/Caches/go-build"
        "$HOME/Library/Caches/Homebrew"
    )

    local total=${#caches[@]}
    local current=0

    for cache_path in "${caches[@]}"; do
        current=$((current + 1))
        show_progress $current $total "清理缓存: $(basename "$cache_path")"
        safe_remove "$cache_path" "开发工具缓存: $(basename "$cache_path")"
    done

    # 清理 npm 缓存
    if command -v npm &> /dev/null; then
        log "PROGRESS" "清理 npm 缓存..."
        npm cache clean --force >/dev/null 2>&1 && log "SUCCESS" "npm 缓存已清理" || log "ERROR" "npm 缓存清理失败"
    fi

    # 清理 Homebrew 缓存
    if command -v brew &> /dev/null; then
        log "PROGRESS" "清理 Homebrew 缓存..."
        brew cleanup >/dev/null 2>&1 && log "SUCCESS" "Homebrew 缓存已清理" || log "ERROR" "Homebrew 缓存清理失败"
    fi

    log "SUCCESS" "开发工具缓存清理完成"
}

# 系统日志清理
cleanup_system_logs() {
    if [ $CLEANUP_SYSTEM_LOGS -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理系统日志..."

    # 清理用户日志
    if [ -d "$HOME/Library/Logs" ]; then
        log "PROGRESS" "清理用户日志文件..."
        find "$HOME/Library/Logs" -name "*.log" -mtime +7 -delete 2>/dev/null || true
        find "$HOME/Library/Logs" -name "*.crash" -mtime +7 -delete 2>/dev/null || true
        log "SUCCESS" "用户日志文件已清理"
    fi

    # 清理系统日志 (需要管理员权限)
    log "PROGRESS" "清理系统日志文件 (需要管理员权限)..."
    sudo find /private/var/log -name "*.log.*" -mtime +7 -delete 2>/dev/null || true
    sudo find /private/var/log -name "*.crash" -mtime +7 -delete 2>/dev/null || true

    # 清理诊断报告
    safe_remove "$HOME/Library/Logs/DiagnosticReports" "用户诊断报告"
    sudo rm -rf /Library/Logs/DiagnosticReports/* 2>/dev/null || true

    log "SUCCESS" "系统日志清理完成"
}

# 休眠镜像清理
cleanup_sleep_image() {
    if [ $CLEANUP_SLEEP_IMAGE -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理休眠镜像..."

    local sleep_image="/private/var/vm/sleepimage"
    if [ -f "$sleep_image" ]; then
        local size=$(get_size "$sleep_image")
        log "PROGRESS" "删除休眠镜像文件 ($size)..."
        if sudo rm -f "$sleep_image" 2>/dev/null; then
            log "SUCCESS" "休眠镜像已删除 ($size)"
        else
            log "ERROR" "休眠镜像删除失败"
        fi
    else
        log "INFO" "没有发现休眠镜像文件"
    fi
}

# 系统缓存清理
cleanup_system_caches() {
    if [ $CLEANUP_SYSTEM_CACHES -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理系统缓存..."

    # QuickLook 缓存
    log "PROGRESS" "重置 QuickLook 缓存..."
    qlmanage -r cache >/dev/null 2>&1 && log "SUCCESS" "QuickLook 缓存已重置" || log "ERROR" "QuickLook 缓存重置失败"

    # DNS 缓存
    log "PROGRESS" "清理 DNS 缓存..."
    sudo dscacheutil -flushcache 2>/dev/null && log "SUCCESS" "DNS 缓存已清理" || log "ERROR" "DNS 缓存清理失败"

    # 字体缓存
    log "PROGRESS" "清理字体缓存..."
    sudo atsutil databases -remove >/dev/null 2>&1 && log "SUCCESS" "字体缓存已清理" || log "ERROR" "字体缓存清理失败"

    log "SUCCESS" "系统缓存清理完成"
}

# 应用程序缓存清理
cleanup_app_caches() {
    if [ $CLEANUP_APP_CACHES -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理应用程序缓存..."

    # IDE 扩展缓存
    local ide_caches=(
        "$HOME/Library/Application Support/Code/CachedExtensions"
        "$HOME/Library/Application Support/Cursor/CachedExtensions"
        "$HOME/Library/Application Support/Zed/languages"
        "$HOME/Library/Application Support/Zed/extensions/work"
    )

    local total=${#ide_caches[@]}
    local current=0

    for cache_path in "${ide_caches[@]}"; do
        current=$((current + 1))
        show_progress $current $total "清理应用缓存: $(basename "$cache_path")"
        safe_remove "$cache_path" "IDE缓存: $(basename "$cache_path")" 1
    done

    log "SUCCESS" "应用程序缓存清理完成"
}

# 废纸篓清理
cleanup_trash() {
    if [ $CLEANUP_TRASH -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理废纸篓..."
    safe_remove "$HOME/.Trash/*" "废纸篓内容"
    log "SUCCESS" "废纸篓清理完成"
}

# Downloads大文件清理
cleanup_downloads_videos() {
    if [ $CLEANUP_DOWNLOADS_VIDEOS -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理Downloads大文件..."

    # 查找Downloads目录中的大文件 (>100MB)
    local large_files=$(find "$HOME/Downloads" -type f -size +100M 2>/dev/null || true)

    if [ -z "$large_files" ]; then
        log "INFO" "Downloads目录中没有发现大文件 (>100MB)"
        return 0
    fi

    echo -e "${YELLOW}发现以下大文件:${NC}"
    echo "$large_files" | while read -r file; do
        if [ -n "$file" ]; then
            local size=$(get_size "$file")
            echo "  - $(basename "$file") ($size)"
        fi
    done

    echo -ne "${YELLOW}确认删除这些大文件吗? (y/N): ${NC}"
    read -r confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "$large_files" | while read -r file; do
            if [ -n "$file" ] && [ -f "$file" ]; then
                safe_remove "$file" "Downloads大文件: $(basename "$file")" 1
            fi
        done
        log "SUCCESS" "Downloads大文件清理完成"
    else
        log "INFO" "跳过Downloads大文件清理"
    fi
}

# 生成清理报告
generate_report() {
    local final_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    local final_avail=$(df -h / | tail -1 | awk '{print $4}')
    local freed_percentage=$((INITIAL_USAGE - final_usage))

    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                      清理完成报告                            ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}📊 磁盘使用对比:${NC}"
    echo -e "   清理前: ${INITIAL_USAGE}% (可用: ${INITIAL_AVAIL})"
    echo -e "   清理后: ${final_usage}% (可用: ${final_avail})"

    if [ $freed_percentage -gt 0 ]; then
        echo -e "${GREEN}   ✅ 释放了 ${freed_percentage}% 的磁盘空间！${NC}"
    else
        echo -e "${YELLOW}   ℹ️  磁盘使用率变化较小${NC}"
    fi

    echo
    echo -e "${BLUE}📝 详细日志: ${LOG_FILE}${NC}"
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${BLUE}💾 备份目录: ${BACKUP_DIR}${NC}"
    fi
    echo
    echo -e "${GREEN}🎉 清理任务完成！${NC}"
    echo
    echo -e "${YELLOW}💡 建议:${NC}"
    echo -e "   1. 重启系统以完全释放内存缓存"
    echo -e "   2. 定期运行此脚本保持系统性能"
    echo -e "   3. 监控系统数据是否继续增长"
    echo
}

# 主清理流程
main_cleanup() {
    clear
    echo -e "${BLUE}🚀 开始执行清理任务...${NC}"
    echo

    # 创建日志文件
    mkdir -p "$(dirname "$LOG_FILE")"
    log "INFO" "开始清理任务 - $(date)"
    log "INFO" "初始磁盘使用率: ${INITIAL_USAGE}%"

    # 执行清理任务
    local tasks=()
    [ $CLEANUP_TIMEMACHINE_SNAPSHOTS -eq 1 ] && tasks+=("cleanup_timemachine_snapshots")
    [ $CLEANUP_DEV_CACHES -eq 1 ] && tasks+=("cleanup_dev_caches")
    [ $CLEANUP_SYSTEM_LOGS -eq 1 ] && tasks+=("cleanup_system_logs")
    [ $CLEANUP_SLEEP_IMAGE -eq 1 ] && tasks+=("cleanup_sleep_image")
    [ $CLEANUP_SYSTEM_CACHES -eq 1 ] && tasks+=("cleanup_system_caches")
    [ $CLEANUP_APP_CACHES -eq 1 ] && tasks+=("cleanup_app_caches")
    [ $CLEANUP_TRASH -eq 1 ] && tasks+=("cleanup_trash")
    [ $CLEANUP_DOWNLOADS_VIDEOS -eq 1 ] && tasks+=("cleanup_downloads_videos")

    local total_tasks=${#tasks[@]}

    if [ $total_tasks -eq 0 ]; then
        log "WARN" "没有选择任何清理项目"
        return 1
    fi

    log "INFO" "将执行 $total_tasks 个清理任务"

    for i in "${!tasks[@]}"; do
        local current=$((i + 1))
        echo
        log "INFO" "执行任务 $current/$total_tasks: ${tasks[$i]}"
        show_progress $current $total_tasks "执行清理任务"

        # 执行清理函数
        ${tasks[$i]}
    done

    log "INFO" "所有清理任务完成"
    generate_report
}

# 检查权限和依赖
check_requirements() {
    # 检查是否为macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log "ERROR" "此脚本仅支持 macOS 系统"
        exit 1
    fi

    # 检查必要命令
    local required_commands=("du" "df" "find" "rm")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log "ERROR" "缺少必要命令: $cmd"
            exit 1
        fi
    done

    log "INFO" "系统检查通过"
}

# 主函数
main() {
    # 检查系统要求
    check_requirements

    # 显示欢迎信息
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                 欢迎使用 Mac 智能清理工具                    ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║  智能识别和清理 macOS 系统中的冗余文件                      ║${NC}"
    echo -e "${PURPLE}║  安全、高效地释放磁盘空间，提升系统性能                     ║${NC}"
    echo -e "${PURPLE}║                                                              ║${NC}"
    echo -e "${PURPLE}║  ⚠️  请确保重要数据已备份                                   ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo

    # 显示免责声明
    echo -e "${YELLOW}⚠️  免责声明:${NC}"
    echo -e "   • 此工具会删除系统缓存和临时文件"
    echo -e "   • 建议在执行前备份重要数据"
    echo -e "   • 部分应用可能需要重新配置或登录"
    echo
    echo -ne "${BLUE}是否继续? (y/N): ${NC}"
    read -r confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}用户取消操作${NC}"
        exit 0
    fi

    # 处理用户选择
    handle_user_input

    # 执行清理
    main_cleanup
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
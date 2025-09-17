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
CLEANUP_DEV_CACHES=1               # 开发工具和应用缓存 (默认选中)
CLEANUP_SYSTEM_LOGS=1              # 系统日志 (默认选中)
CLEANUP_SLEEP_IMAGE=1              # 休眠镜像 (默认选中)
CLEANUP_SYSTEM_CACHES=1            # 系统缓存 (默认选中)
CLEANUP_APP_CACHES=0               # 应用程序缓存 (默认不选中)
CLEANUP_TRASH=1                    # 废纸篓 (默认选中)
CLEANUP_DOWNLOADS_VIDEOS=0         # Downloads大文件清理 (默认不选中)

# 清理统计
TOTAL_FREED_BYTES=0

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

    printf "\r${CYAN}["
    printf "%${filled_length}s" | tr ' ' '='
    printf "%$((bar_length - filled_length))s" | tr ' ' '-'
    printf "] %3d%% %s${NC}" "$progress" "$description"

    if [ $current -eq $total ]; then
        echo
    fi
}

# 获取文件/目录大小（返回字节数）
get_size_bytes() {
    local path="$1"
    if [ -e "$path" ]; then
        du -s "$path" 2>/dev/null | awk '{print $1 * 1024}' || echo "0"
    else
        echo "0"
    fi
}

# 获取文件/目录大小（人类可读格式）
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
    local size_bytes=$(get_size_bytes "$path")
    log "PROGRESS" "正在清理: $description ($size)"

    # 备份重要文件 (如果启用)
    if [ "$backup_enabled" = "1" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -R "$path" "$BACKUP_DIR/" 2>/dev/null || log "WARN" "备份失败: $path"
    fi

    # 删除文件/目录
    if rm -rf "$path" 2>/dev/null; then
        log "SUCCESS" "已清理: $description ($size)"
        # 累加释放的字节数
        TOTAL_FREED_BYTES=$((TOTAL_FREED_BYTES + size_bytes))
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
    echo -e "${BLUE}📊 开始清理，释放磁盘空间${NC}"
    echo
    echo -e "${YELLOW}请选择要执行的清理项目 (默认已选中安全项目):${NC}"
    echo

    # 显示清理选项
    echo -e " 1. [$([ $CLEANUP_TIMEMACHINE_SNAPSHOTS -eq 1 ] && echo '✓' || echo ' ')] Time Machine 快照清理 (tmutil)           ${GREEN}(安全, 跳过系统更新快照)${NC}"
    echo -e " 2. [$([ $CLEANUP_DEV_CACHES -eq 1 ] && echo '✓' || echo ' ')] 开发工具和应用缓存清理 (~/.cache, ~/Library/Caches)         ${GREEN}(安全, 可释放5-15GB)${NC}"
    echo -e " 3. [$([ $CLEANUP_SYSTEM_LOGS -eq 1 ] && echo '✓' || echo ' ')] 系统日志清理 (~/Library/Logs, /var/log)                   ${GREEN}(安全, 可释放1-3GB)${NC}"
    echo -e " 4. [$([ $CLEANUP_SLEEP_IMAGE -eq 1 ] && echo '✓' || echo ' ')] 休眠镜像清理 (/var/vm/sleepimage)                   ${GREEN}(安全, 可释放1GB)${NC}"
    echo -e " 5. [$([ $CLEANUP_SYSTEM_CACHES -eq 1 ] && echo '✓' || echo ' ')] 系统缓存清理 (QuickLook, DNS, 字体缓存)                   ${GREEN}(安全, 可释放2-5GB)${NC}"
    echo -e " 6. [$([ $CLEANUP_APP_CACHES -eq 1 ] && echo '✓' || echo ' ')] 应用程序缓存清理 (~/Library/Application Support)               ${YELLOW}(谨慎, 可释放2-3GB)${NC}"
    echo -e " 7. [$([ $CLEANUP_TRASH -eq 1 ] && echo '✓' || echo ' ')] 废纸篓清理 (~/.Trash)                       ${GREEN}(安全)${NC}"
    echo -e " 8. [$([ $CLEANUP_DOWNLOADS_VIDEOS -eq 1 ] && echo '✓' || echo ' ')] Downloads大文件清理 (~/Downloads)             ${YELLOW}(谨慎选择)${NC}"
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

    # 获取所有快照列表
    local all_snapshots=$(tmutil listlocalsnapshots / 2>/dev/null | grep -v "Snapshots for volume" || true)

    if [ -z "$all_snapshots" ]; then
        log "INFO" "没有发现本地快照"
        return 0
    fi

    # 筛选可删除的快照 (只删除 Time Machine 快照，保留系统更新快照)
    local tm_snapshots=$(echo "$all_snapshots" | grep "com.apple.TimeMachine" || true)
    local update_snapshots=$(echo "$all_snapshots" | grep "com.apple.os.update" || true)

    local total_snapshots=$(echo "$all_snapshots" | wc -l | tr -d ' ')
    local tm_count=0
    local update_count=0

    if [ -n "$tm_snapshots" ]; then
        tm_count=$(echo "$tm_snapshots" | wc -l | tr -d ' ')
    fi

    if [ -n "$update_snapshots" ]; then
        update_count=$(echo "$update_snapshots" | wc -l | tr -d ' ')
    fi

    log "INFO" "发现 $total_snapshots 个本地快照："
    log "INFO" "  - Time Machine 快照: $tm_count 个 (可清理)"
    log "INFO" "  - 系统更新快照: $update_count 个 (受保护，跳过)"

    if [ -z "$tm_snapshots" ]; then
        log "INFO" "没有可清理的 Time Machine 快照"
        if [ $update_count -gt 0 ]; then
            echo -e "${YELLOW}💡 系统更新快照已跳过 ($update_count 个)，这些快照由系统自动管理${NC}"
        fi
        return 0
    fi

    # 询问用户是否授权删除 Time Machine 快照
    echo -e "${YELLOW}⚠️  删除 Time Machine 快照需要管理员权限${NC}"
    echo -e "${BLUE}发现 $tm_count 个可清理的 Time Machine 快照${NC}"
    echo -ne "${BLUE}是否授权删除这些快照? (y/N): ${NC}"
    read -r confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        log "INFO" "用户取消删除 Time Machine 快照"
        if [ $update_count -gt 0 ]; then
            echo -e "${YELLOW}💡 系统更新快照已跳过 ($update_count 个)，这些快照由系统自动管理${NC}"
        fi
        return 0
    fi

    # 获取管理员权限
    echo -e "${BLUE}请输入管理员密码以删除 Time Machine 快照...${NC}"

    # 只删除 Time Machine 快照
    local current=0
    local deleted_count=0

    while IFS= read -r snapshot; do
        if [ -n "$snapshot" ]; then
            current=$((current + 1))
            show_progress $current $tm_count "删除 TM 快照: $(basename $snapshot)"

            # 从快照名称提取时间戳
            # com.apple.TimeMachine.2025-09-16-204201.local -> 2025-09-16-204201
            local timestamp=$(echo "$snapshot" | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{6\}')

            if [ -n "$timestamp" ]; then
                # 尝试删除快照，使用时间戳格式
                if sudo tmutil deletelocalsnapshots "$timestamp" >/dev/null 2>&1; then
                    log "SUCCESS" "已删除 Time Machine 快照: $timestamp"
                    deleted_count=$((deleted_count + 1))
                    # Time Machine 快照通常较大，估算释放空间
                    local estimated_size=$((1024 * 1024 * 1024)) # 估算1GB
                    TOTAL_FREED_BYTES=$((TOTAL_FREED_BYTES + estimated_size))
                else
                    log "ERROR" "删除 Time Machine 快照失败: $timestamp"
                fi
            else
                log "ERROR" "无法解析快照时间戳: $snapshot"
            fi
        fi
    done <<< "$tm_snapshots"

    if [ $deleted_count -gt 0 ]; then
        log "SUCCESS" "成功删除 $deleted_count 个 Time Machine 快照"
    elif [ $tm_count -gt 0 ]; then
        log "WARN" "未能删除任何 Time Machine 快照"
    fi

    if [ $update_count -gt 0 ]; then
        echo -e "${YELLOW}💡 系统更新快照已跳过 ($update_count 个)，这些快照由系统自动管理${NC}"
    fi

    log "SUCCESS" "Time Machine 快照清理完成"
}

# 开发工具和应用程序缓存清理
cleanup_dev_caches() {
    if [ $CLEANUP_DEV_CACHES -eq 0 ]; then
        return 0
    fi

    log "INFO" "开始清理开发工具和应用程序缓存..."

    # 开发工具缓存
    local dev_caches=(
        # Node.js 相关
        "$HOME/.npm"
        "$HOME/.cache/npm"
        "$HOME/.yarn/cache"
        "$HOME/.pnpm-store"
        "$HOME/.cache/yarn"

        # Python 相关
        "$HOME/.cache/pip"
        "$HOME/.cache/pipenv"
        "$HOME/Library/Caches/pip"
        "$HOME/Library/Caches/pypoetry"
        "$HOME/.pyenv/cache"
        "$HOME/.conda/pkgs"

        # Go 相关
        "$HOME/go/pkg/mod/cache"
        "$HOME/.cache/go-build"
        "$HOME/Library/Caches/go-build"

        # Rust 相关
        "$HOME/.cargo/registry/cache"
        "$HOME/.cargo/git/db"

        # Java 相关
        "$HOME/.gradle/caches"
        "$HOME/.m2/repository/.cache"

        # Ruby 相关
        "$HOME/.gem/cache"
        "$HOME/.bundle/cache"

        # AI/ML 工具缓存
        "$HOME/.cache/huggingface"
        "$HOME/.cache/github-copilot"
        "$HOME/.cache/ollama"
        "$HOME/.cache/openai"

        # 浏览器自动化
        "$HOME/.cache/puppeteer"
        "$HOME/.cache/playwright"
        "$HOME/.cache/selenium"

        # 包管理器
        "$HOME/Library/Caches/Homebrew"
        "$HOME/.cache/composer"

        # 编辑器/IDE 相关
        "$HOME/.cache/vscode-ripgrep"
        "$HOME/.cache/phpactor"
        "$HOME/.cache/typescript"
    )

    # Adobe 应用程序缓存 (仅清理缓存，保留配置)
    local adobe_caches=(
        "$HOME/Library/Caches/Adobe/After Effects"
        "$HOME/Library/Caches/Adobe/Photoshop"
        "$HOME/Library/Caches/Adobe/Illustrator"
        "$HOME/Library/Caches/Adobe/Premiere Pro"
        "$HOME/Library/Caches/Adobe/InDesign"
        "$HOME/Library/Caches/Adobe/Lightroom"
        "$HOME/Library/Caches/Adobe/Bridge"
        "$HOME/Library/Caches/Adobe/Media Encoder"
        "$HOME/Library/Caches/com.adobe.acc.AdobeCreativeCloud"
    )

    # 其他常用应用程序缓存
    local app_caches=(
        # Microsoft Office
        "$HOME/Library/Caches/Microsoft/Office"
        "$HOME/Library/Caches/com.microsoft.Word"
        "$HOME/Library/Caches/com.microsoft.Excel"
        "$HOME/Library/Caches/com.microsoft.Powerpoint"

        # Google
        "$HOME/Library/Caches/Google/Chrome/Default/Cache"
        "$HOME/Library/Caches/com.google.Chrome"

        # 媒体工具
        "$HOME/Library/Caches/com.apple.FinalCutPro"
        "$HOME/Library/Caches/com.apple.Motion"
        "$HOME/Library/Caches/com.blackmagic-design.DaVinciResolve"

        # 设计工具
        "$HOME/Library/Caches/com.figma.Desktop"
        "$HOME/Library/Caches/com.bohemiancoding.sketch3"
        "$HOME/Library/Caches/com.framerx.framer-x"

        # 通讯工具
        "$HOME/Library/Caches/com.tencent.xinWeChat"
        "$HOME/Library/Caches/com.microsoft.teams"
        "$HOME/Library/Caches/com.discord.Discord"
        "$HOME/Library/Caches/com.slack.Slack"
        "$HOME/Library/Caches/us.zoom.xos"

        # 开发工具
        "$HOME/Library/Caches/com.docker.docker"
        "$HOME/Library/Caches/com.postmanlabs.mac"
        "$HOME/Library/Caches/com.github.GitHubDesktop"
    )

    # 基于用户系统实际安装的应用程序缓存
    local user_installed_app_caches=(
        # JetBrains IDE系列 (已安装: IntelliJ IDEA, DataGrip)
        "$HOME/Library/Caches/JetBrains/IntelliJIdea*"
        "$HOME/Library/Caches/JetBrains/DataGrip*"
        "$HOME/Library/Application Support/JetBrains/IntelliJIdea*/caches"
        "$HOME/Library/Application Support/JetBrains/DataGrip*/caches"
        "$HOME/Library/Application Support/JetBrains/IntelliJIdea*/tmp"
        "$HOME/Library/Application Support/JetBrains/DataGrip*/tmp"

        # 代码编辑器 (已安装: VS Code, Cursor, Zed)
        "$HOME/Library/Caches/com.microsoft.VSCode"
        "$HOME/Library/Caches/com.todesktop.230313mzl4w4u92" # Cursor
        "$HOME/Library/Application Support/Code/CachedExtensions"
        "$HOME/Library/Application Support/Code/logs"
        "$HOME/Library/Application Support/Cursor/CachedExtensions"
        "$HOME/Library/Application Support/Cursor/logs"
        "$HOME/Library/Application Support/Zed/languages/*/cache"
        "$HOME/Library/Application Support/Zed/extensions/*/cache"

        # 浏览器 (已安装: Chrome, Edge, Safari)
        "$HOME/Library/Caches/Google/Chrome/Default/Cache"
        "$HOME/Library/Caches/Google/Chrome/Profile */Cache"
        "$HOME/Library/Caches/com.google.Chrome"
        "$HOME/Library/Caches/com.microsoft.edgemac"
        "$HOME/Library/Caches/com.apple.Safari/Webpage Previews"
        "$HOME/Library/Caches/com.apple.Safari/TouchIconCache"

        # 中国应用 (已安装: 微信, QQ, 钉钉, 企业微信, 网易云音乐, 小红书)
        "$HOME/Library/Caches/com.tencent.xinWeChat" # 微信
        "$HOME/Library/Caches/com.tencent.qq" # QQ
        "$HOME/Library/Caches/com.alibaba.DingTalkMac" # 钉钉
        "$HOME/Library/Caches/com.tencent.WeWorkMac" # 企业微信
        "$HOME/Library/Caches/com.netease.163music" # 网易云音乐
        "$HOME/Library/Caches/com.xingin.discover" # 小红书
        "$HOME/Library/Caches/com.youku.mac" # 优酷
        "$HOME/Library/Caches/com.tencent.tenvideo" # 腾讯视频
        "$HOME/Library/Caches/com.tencent.weread" # 微信读书

        # 开发工具 (已安装: iTerm, Sourcetree, OrbStack)
        "$HOME/Library/Caches/com.googlecode.iterm2"
        "$HOME/Library/Caches/com.torusknot.SourceTreeNotMAS"
        "$HOME/Library/Caches/dev.orbstack.OrbStack"
        "$HOME/Library/Application Support/OrbStack/cache"

        # 媒体和娱乐 (已安装: IINA, Infuse, GarageBand)
        "$HOME/Library/Caches/com.colliderli.iina"
        "$HOME/Library/Caches/com.firecore.infuse"
        "$HOME/Library/Caches/com.apple.garageband10"

        # 实用工具 (已安装: Raycast, Hidden Bar, DaisyDisk)
        "$HOME/Library/Caches/com.raycast.macos"
        "$HOME/Library/Caches/com.dwarvesv.minimalbar"
        "$HOME/Library/Caches/com.daisydiskapp.DaisyDiskStandAlone"
        "$HOME/Library/Caches/com.charliemonroe.Downie"
        "$HOME/Library/Caches/cc.ffitch.shottr"

        # 安全工具 (已安装: Bitwarden, ClashX Pro)
        "$HOME/Library/Caches/com.bitwarden.desktop"
        "$HOME/Library/Caches/com.west2online.ClashX.Pro"

        # 办公软件 (已安装: WPS Office, 腾讯柠檬)
        "$HOME/Library/Caches/com.kingsoft.wpsoffice.mac"
        "$HOME/Library/Caches/com.tencent.Lemon"

        # 通讯工具 (已安装: Telegram, Discord, Lark)
        "$HOME/Library/Caches/ru.keepcoder.Telegram"
        "$HOME/Library/Caches/com.discord.Discord"
        "$HOME/Library/Caches/com.electron.lark"

        # 游戏和娱乐 (已安装: WeGame, MuMu模拟器)
        "$HOME/Library/Caches/com.tencent.start.mac.wegame"
        "$HOME/Library/Caches/com.netease.mumu.nemux"

        # API工具 (已安装: Apifox, Charles)
        "$HOME/Library/Caches/cn.apifox.app"
        "$HOME/Library/Caches/com.xk72.charles"

        # 系统工具 (已安装: Karabiner-Elements, Input Source Pro)
        "$HOME/Library/Caches/org.pqrs.Karabiner-Elements"
        "$HOME/Library/Caches/com.runjuu.InputSourcePro"

        # 其他工具 (已安装: Bob, Logseq, Fig, Qoder)
        "$HOME/Library/Caches/com.ripperhe.Bob"
        "$HOME/Library/Caches/com.logseq.Logseq"
        "$HOME/Library/Caches/com.fig.fig"
        "$HOME/Library/Caches/com.qoder.qoder"
        "$HOME/Library/Application Support/Qoder/SharedClientCache"
    )

    # 合并所有缓存列表
    local all_caches=("${dev_caches[@]}" "${adobe_caches[@]}" "${app_caches[@]}" "${user_installed_app_caches[@]}")
    local total=${#all_caches[@]}
    local current=0
    local cleaned_count=0

    log "INFO" "检查 $total 个缓存位置 (包含您系统已安装的应用)..."

    for cache_path in "${all_caches[@]}"; do
        current=$((current + 1))
        show_progress $current $total "检查缓存: $(basename "$cache_path")"

        if [ -e "$cache_path" ]; then
            local size_before=$(get_size "$cache_path")
            if safe_remove "$cache_path" "应用缓存: $(basename "$cache_path")"; then
                cleaned_count=$((cleaned_count + 1))
                log "SUCCESS" "已清理缓存: $(basename "$cache_path") ($size_before)"
            fi
        fi
    done

    # 清理包管理器缓存命令
    local package_managers=(
        # npm
        "npm cache clean --force"
        # yarn (如果存在)
        "yarn cache clean"
        # pip (如果存在)
        "pip cache purge"
        # conda (如果存在)
        "conda clean --all --yes"
        # Homebrew
        "brew cleanup"
        # gem (如果存在)
        "gem cleanup"
        # cargo (如果存在)
        "cargo cache --autoclean"
    )

    log "INFO" "正在清理包管理器缓存..."

    # npm 缓存清理
    if command -v npm &> /dev/null; then
        log "PROGRESS" "清理 npm 缓存..."
        npm cache clean --force >/dev/null 2>&1 && log "SUCCESS" "npm 缓存已清理" || log "WARN" "npm 缓存清理失败"
    fi

    # Homebrew 缓存清理
    if command -v brew &> /dev/null; then
        log "PROGRESS" "清理 Homebrew 缓存..."
        brew cleanup >/dev/null 2>&1 && log "SUCCESS" "Homebrew 缓存已清理" || log "WARN" "Homebrew 缓存清理失败"
    fi

    # Yarn 缓存清理
    if command -v yarn &> /dev/null; then
        log "PROGRESS" "清理 Yarn 缓存..."
        yarn cache clean >/dev/null 2>&1 && log "SUCCESS" "Yarn 缓存已清理" || log "WARN" "Yarn 缓存清理失败"
    fi

    # pip 缓存清理
    if command -v pip &> /dev/null; then
        log "PROGRESS" "清理 pip 缓存..."
        pip cache purge >/dev/null 2>&1 && log "SUCCESS" "pip 缓存已清理" || log "WARN" "pip 缓存清理失败"
    fi

    # conda 缓存清理
    if command -v conda &> /dev/null; then
        log "PROGRESS" "清理 conda 缓存..."
        conda clean --all --yes >/dev/null 2>&1 && log "SUCCESS" "conda 缓存已清理" || log "WARN" "conda 缓存清理失败"
    fi

    # gem 缓存清理
    if command -v gem &> /dev/null; then
        log "PROGRESS" "清理 gem 缓存..."
        gem cleanup >/dev/null 2>&1 && log "SUCCESS" "gem 缓存已清理" || log "WARN" "gem 缓存清理失败"
    fi

    # Docker 缓存清理 (如果用户选择)
    if command -v docker &> /dev/null; then
        echo -ne "${YELLOW}是否清理 Docker 缓存? 这会删除未使用的镜像和容器 (y/N): ${NC}"
        read -r docker_confirm
        if [[ $docker_confirm =~ ^[Yy]$ ]]; then
            log "PROGRESS" "清理 Docker 缓存..."
            docker system prune -f >/dev/null 2>&1 && log "SUCCESS" "Docker 缓存已清理" || log "WARN" "Docker 缓存清理失败"
        fi
    fi

    log "SUCCESS" "缓存清理完成！已清理 $cleaned_count 个缓存位置"
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

    # 检查废纸篓目录是否存在且不为空
    if [ -d "$HOME/.Trash" ] && [ "$(ls -A "$HOME/.Trash" 2>/dev/null)" ]; then
        local size=$(get_size "$HOME/.Trash")
        log "PROGRESS" "正在清理: 废纸篓内容 ($size)"

        # 删除废纸篓中的所有内容
        if rm -rf "$HOME/.Trash"/* "$HOME/.Trash"/.[!.]* "$HOME/.Trash"/..?* 2>/dev/null; then
            log "SUCCESS" "废纸篓清理完成"
        else
            log "ERROR" "废纸篓清理失败"
        fi
    else
        log "WARN" "废纸篓为空或不存在"
    fi
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
    # 强制同步文件系统
    sync
    sleep 1

    echo
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                      清理完成报告                            ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo

    # 计算释放的空间
    if [ $TOTAL_FREED_BYTES -gt 0 ]; then
        local freed_mb=$((TOTAL_FREED_BYTES / 1024 / 1024))
        local freed_gb_decimal=$(echo "scale=2; $TOTAL_FREED_BYTES / 1000000000" | bc 2>/dev/null || echo "$TOTAL_FREED_BYTES" | awk '{printf "%.2f", $1/1000000000}')

        echo -e "${GREEN}🎉 清理成功！${NC}"
        echo -e "${BLUE}📊 释放空间统计:${NC}"

        if [ $freed_mb -gt 1024 ]; then
            echo -e "   ✅ 已释放: ${freed_gb_decimal}GB 磁盘空间"
        else
            echo -e "   ✅ 已释放: ${freed_mb}MB 磁盘空间"
        fi
    else
        echo -e "${YELLOW}ℹ️  没有找到可清理的文件${NC}"
    fi

    echo
    echo -e "${BLUE}📝 详细日志: ${LOG_FILE}${NC}"
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${BLUE}💾 备份目录: ${BACKUP_DIR}${NC}"
    fi
    echo
    echo -e "${YELLOW}💡 建议:${NC}"
    echo -e "   1. 重启系统以完全释放内存缓存"
    echo -e "   2. 定期运行此脚本保持系统性能"
    echo -e "   3. 检查"关于本机"查看最新磁盘使用情况"
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
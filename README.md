# Mac 智能系统清理工具

适用于所有 macOS 用户的磁盘空间优化解决方案。

## 🎯 功能特性

### 📊 主要清理项目

| 清理项目 | 预估释放空间 | 安全等级 | 默认状态 |
|---------|-------------|----------|----------|
| **Time Machine 本地快照** | 大量空间 | 🟢 安全 | ✅ 默认选中 |
| **应用程序缓存** | 5-15GB | 🟢 安全 | ✅ 默认选中 |
| **系统日志文件** | 1-3GB | 🟢 安全 | ✅ 默认选中 |
| **休眠镜像** | 1GB | 🟢 安全 | ✅ 默认选中 |
| **系统缓存** | 2-5GB | 🟢 安全 | ✅ 默认选中 |
| **IDE扩展缓存** | 2-3GB | 🟡 谨慎 | ❌ 默认不选 |
| **废纸篓** | 变化 | 🟢 安全 | ✅ 默认选中 |
| **Downloads大文件** | 变化 | 🔴 谨慎 | ❌ 默认不选 |

### ✨ 核心特性

- **🔒 安全优先**: 默认只选中100%安全的清理项目
- **📊 实时进度**: 每个步骤都有详细的进度显示
- **📝 完整日志**: 自动记录所有操作和结果
- **💾 智能备份**: 重要文件自动备份
- **🎛️ 交互式选择**: 用户可自定义选择清理项目
- **📈 详细报告**: 清理完成后生成详细的效果报告
- **🌍 通用适配**: 适用于所有 macOS 系统

## 🚀 快速开始

### 1. 下载和安装

```bash
# 方式1: 直接下载脚本
curl -O https://raw.githubusercontent.com/Chenkeliang/cleanMyMac/main/mac_smart_cleanup.sh
chmod +x mac_smart_cleanup.sh

# 方式2: 克隆整个项目
git clone https://github.com/Chenkeliang/cleanMyMac.git
cd cleanMyMac
```

### 2. 运行清理工具

```bash
./mac_smart_cleanup.sh
```

### 3. 按照交互式界面操作

1. **阅读免责声明**并确认继续
2. **选择清理项目** (默认已选中安全项目)
3. **开始清理**并等待完成
4. **查看清理报告**

## 📋 详细说明

### 🔧 清理项目详解

#### 1. Time Machine 本地快照 (强烈推荐)
- **清理内容**: 本地时间机器快照
- **释放空间**: 通常可释放大量空间 (因系统而异)
- **风险**: 无风险，快照会自动重建
- **说明**: 这是最有效的清理方式，通常是"系统数据"占用过大的主要原因

#### 2. 应用程序缓存
- **清理内容**:
  - **开发工具**: Node.js(npm/yarn/pnpm), Python(pip/pipenv/poetry/pyenv/conda), Go, Rust(cargo), Java(gradle/maven), Ruby(gem), Homebrew, Composer
  - **AI/ML工具**: HuggingFace, GitHub Copilot, OpenAI, Ollama
  - **浏览器自动化**: Puppeteer, Playwright, Selenium
  - **Adobe创意套件**: After Effects, Photoshop, Illustrator, Premiere Pro, InDesign, Lightroom, Bridge, Media Encoder, Creative Cloud
  - **开发环境**:
    - **IDE**: IntelliJ IDEA, DataGrip, VS Code, Cursor, Zed
    - **终端工具**: iTerm2, Sourcetree, OrbStack
    - **API工具**: Postman, Apifox, Charles
  - **浏览器**: Google Chrome, Microsoft Edge, Safari
  - **办公软件**: Microsoft Office (Word/Excel/PowerPoint), WPS Office
  - **媒体工具**: Final Cut Pro, Motion, DaVinci Resolve, IINA, Infuse, GarageBand
  - **设计工具**: Figma, Sketch, Framer X
  - **中国应用**: 微信, QQ, 钉钉, 企业微信, 网易云音乐, 小红书, 优酷, 腾讯视频, 微信读书, WeGame, MuMu模拟器
  - **通讯工具**: Teams, Discord, Slack, Zoom, Telegram, Lark
  - **实用工具**: Raycast, Hidden Bar, DaisyDisk, Downie, Shottr, Bitwarden, ClashX Pro, 腾讯柠檬
  - **系统工具**: Docker, GitHub Desktop, Karabiner-Elements, Input Source Pro
  - **其他**: Bob翻译, Logseq, Fig, Qoder
- **释放空间**: 5-15GB (根据安装的工具而定)
- **风险**: 无风险，会自动重新下载或重建缓存

#### 3. 系统日志文件
- **清理内容**:
  - 用户日志文件 (>7天)
  - 系统日志文件 (>7天)
  - 崩溃报告
  - 诊断报告
- **释放空间**: 1-3GB
- **风险**: 无风险

#### 4. 休眠镜像
- **清理内容**: `/private/var/vm/sleepimage`
- **释放空间**: ~1GB
- **风险**: 无风险，重启后重建

#### 5. 系统缓存
- **清理内容**:
  - QuickLook 缩略图缓存
  - DNS 缓存
  - 字体缓存
- **释放空间**: 2-5GB
- **风险**: 无风险，自动重建

#### 6. IDE扩展缓存 (谨慎选择)
- **清理内容**:
  - IDE 扩展缓存
  - 语言服务器缓存
- **释放空间**: 2-3GB
- **风险**: 可能需要重新下载扩展

#### 7. 废纸篓
- **清理内容**: `~/.Trash/` 目录
- **释放空间**: 取决于内容
- **风险**: 无法恢复删除的文件

#### 8. Downloads大文件 (默认不选择)
- **清理内容**: 下载文件夹中的大文件 (>100MB)
- **释放空间**: 取决于文件数量
- **风险**: 用户数据丢失

### 🛡️ 安全机制

#### 备份保护
- 重要文件自动备份到 `backup_[时间戳]` 目录
- 应用程序缓存清理前自动备份
- 备份目录位置会在报告中显示

#### 日志记录
- 完整的操作日志记录
- 每个步骤的成功/失败状态
- 日志文件: `cleanup_[时间戳].log`

#### 权限检查
- 自动检查系统权限
- 安全的文件删除机制
- 错误处理和回滚

### 📊 使用界面

#### 主菜单示例
```
╔══════════════════════════════════════════════════════════════╗
║               Mac 智能系统清理工具 v1.0                      ║
║              释放磁盘空间，优化系统性能                      ║
╚══════════════════════════════════════════════════════════════╝

📊 开始清理，释放磁盘空间

请选择要执行的清理项目 (默认已选中安全项目):

 1. [✓] Time Machine 快照清理 (tmutil)           (安全, 跳过系统更新快照)
 2. [✓] 应用程序缓存清理 (开发工具+常用应用缓存)         (安全, 可释放5-15GB)
 3. [✓] 系统日志清理 (~/Library/Logs, /var/log)                   (安全, 可释放1-3GB)
 4. [✓] 休眠镜像清理 (/var/vm/sleepimage)                   (安全, 可释放1GB)
 5. [✓] 系统缓存清理 (QuickLook, DNS, 字体缓存)                   (安全, 可释放2-5GB)
 6. [ ] IDE扩展缓存清理 (VS Code/Cursor/Zed扩展)               (谨慎, 可释放2-3GB)
 7. [✓] 废纸篓清理 (~/.Trash)                       (安全)
 8. [ ] Downloads大文件清理 (~/Downloads)             (谨慎选择)

操作选项:
 s) 开始清理 (执行选中的项目)
 a) 全选安全项目
 c) 取消全选
 1-8) 切换对应项目的选择状态
 q) 退出

请选择操作:
```

## 🌟 Star History

如果这个工具对你有帮助，请给我们一个 ⭐！

---

**⚠️ 免责声明**: 此工具会修改系统文件，请在使用前备份重要数据。开发者不对数据丢失承担责任。
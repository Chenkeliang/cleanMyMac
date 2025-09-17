# Mac 智能系统清理工具

适用于所有 macOS 用户的磁盘空间优化解决方案。

## 🎯 功能特性

### 📊 主要清理项目

| 清理项目 | 预估释放空间 | 安全等级 | 默认状态 |
|---------|-------------|----------|----------|
| **Time Machine 本地快照** | 大量空间 | 🟢 安全 | ✅ 默认选中 |
| **开发工具和应用缓存** | 5-15GB | 🟢 安全 | ✅ 默认选中 |
| **系统日志文件** | 1-3GB | 🟢 安全 | ✅ 默认选中 |
| **休眠镜像** | 1GB | 🟢 安全 | ✅ 默认选中 |
| **系统缓存** | 2-5GB | 🟢 安全 | ✅ 默认选中 |
| **应用程序缓存** | 2-3GB | 🟡 谨慎 | ❌ 默认不选 |
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

#### 2. 开发工具和应用缓存
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

#### 6. 应用程序缓存 (谨慎选择)
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

### 📱 支持的应用程序 (75+)

本工具智能识别并清理以下应用程序的缓存文件：

#### 开发工具和环境
- **IDE**: IntelliJ IDEA, DataGrip, VS Code, Cursor, Zed
- **语言环境**: Node.js, Python, Go, Rust, Java, Ruby, PHP
- **包管理器**: npm, yarn, pnpm, pip, conda, cargo, gem, homebrew
- **版本控制**: Git, GitHub Desktop, Sourcetree
- **容器**: Docker, OrbStack
- **终端**: iTerm2
- **API工具**: Postman, Apifox, Charles

#### Adobe 创意套件
- After Effects, Photoshop, Illustrator, Premiere Pro
- InDesign, Lightroom, Bridge, Media Encoder
- Creative Cloud

#### 浏览器和网络
- Google Chrome, Microsoft Edge, Safari
- Puppeteer, Playwright, Selenium (自动化工具)

#### AI/ML 工具
- HuggingFace, GitHub Copilot, OpenAI, Ollama

#### 办公和生产力
- Microsoft Office (Word, Excel, PowerPoint)
- WPS Office, 腾讯柠檬

#### 媒体和娱乐
- Final Cut Pro, Motion, DaVinci Resolve
- IINA, Infuse, GarageBand
- 网易云音乐, 优酷, 腾讯视频, 微信读书

#### 设计工具
- Figma, Sketch, Framer X

#### 中国应用生态
- **社交通讯**: 微信, QQ, 钉钉, 企业微信
- **内容平台**: 小红书, 微信读书
- **游戏娱乐**: WeGame, MuMu模拟器

#### 国际通讯工具
- Microsoft Teams, Discord, Slack, Zoom
- Telegram, Lark

#### 实用工具
- Raycast, Hidden Bar, DaisyDisk
- Downie, Shottr, Bob翻译
- Bitwarden, ClashX Pro

#### 系统工具
- Karabiner-Elements, Input Source Pro
- Logseq, Fig, Qoder

> **安全保障**: 所有清理操作仅针对缓存文件，完全保留用户配置、数据和偏好设置。

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
 2. [✓] 开发工具和应用缓存清理 (~/.cache, ~/Library/Caches)         (安全, 可释放5-15GB)
 3. [✓] 系统日志清理 (~/Library/Logs, /var/log)                   (安全, 可释放1-3GB)
 4. [✓] 休眠镜像清理 (/var/vm/sleepimage)                   (安全, 可释放1GB)
 5. [✓] 系统缓存清理 (QuickLook, DNS, 字体缓存)                   (安全, 可释放2-5GB)
 6. [ ] 应用程序缓存清理 (~/Library/Application Support)               (谨慎, 可释放2-3GB)
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

## ⚠️ 注意事项

### 使用前准备
1. **备份重要数据** - 虽然脚本很安全，但建议备份重要文件
2. **关闭重要应用** - 特别是IDE和开发工具
3. **确保有管理员权限** - 某些清理需要sudo权限
4. **连接电源** - 清理过程可能需要较长时间

### 清理后影响
1. **应用重新配置** - 部分应用可能需要重新登录或配置
2. **缓存重建** - 首次使用应用时可能较慢
3. **字体重载** - 字体可能需要重新加载
4. **QuickLook重建** - 文件预览需要重新生成

### 系统兼容性
- **支持系统**: macOS 10.14+
- **测试环境**: macOS Sonoma 14.x, macOS Ventura 13.x
- **架构支持**: Intel 和 Apple Silicon

## 🔧 高级用法

### 定期维护建议
```bash
# 创建月度清理任务
echo "0 0 1 * * $PWD/mac_smart_cleanup.sh --silent" | crontab -

# 手动设置提醒
echo "记得每月运行一次 Mac 清理工具！" > ~/Desktop/清理提醒.txt
```

## 📞 技术支持

### 常见问题

**Q: 脚本安全吗？**
A: 是的，默认只清理100%安全的项目，并且有完整的日志和备份机制。

**Q: Time Machine快照删除后会影响备份吗？**
A: 不会，这只是删除本地快照，不影响Time Machine的正常备份功能。

**Q: 我的系统数据没有280GB那么大，能用吗？**
A: 当然可以！这个工具适用于所有 macOS 系统，无论系统数据大小如何。

**Q: 可以恢复已删除的文件吗？**
A: 重要文件会自动备份到backup目录，可以手动恢复。

**Q: 清理后系统变慢了怎么办？**
A: 这是正常现象，缓存重建需要时间，重启系统可以改善。

### 故障排除

1. **权限错误**: 确保使用管理员权限运行
2. **磁盘空间不足**: 先手动删除一些大文件
3. **脚本执行失败**: 检查日志文件了解具体错误

### 反馈和贡献
- **问题反馈**: [GitHub Issues](https://github.com/Chenkeliang/cleanMyMac/issues)
- **功能建议**: [GitHub Discussions](https://github.com/Chenkeliang/cleanMyMac/discussions)
- **贡献代码**: 欢迎提交 Pull Request

## 📄 许可证

MIT License - 详见 LICENSE 文件

## 🙏 致谢

感谢所有测试用户和贡献者的支持！特别感谢开源社区提供的工具和建议。

## 🌟 Star History

如果这个工具对你有帮助，请给我们一个 ⭐！

---

**⚠️ 免责声明**: 此工具会修改系统文件，请在使用前备份重要数据。开发者不对数据丢失承担责任。
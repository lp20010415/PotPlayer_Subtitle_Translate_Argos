<h4 align="left">
  <b>中文</b> |
  <a href="readme_en.md">English</a>
</h4>

# PotPlayer Subtitle Translate - Argos

一个基于 [Argos Translate](https://github.com/argosopentech/argos-translate) 的 PotPlayer 实时字幕翻译插件。使用本地 AI 翻译引擎，无需联网，完全免费，支持多种语言互译。

## 功能特点

- 完全免费，无需任何 API 密钥或付费服务
- 本地部署，保护隐私，无需联网
- 支持 30+ 种语言互译
- 支持自动语言检测
- 实时翻译字幕
- 简单易用，一键安装

## 支持的语言

Arabic, Azerbaijani, Basque, Catalan, Chinese, Czech, Danish, Dutch, English, Esperanto, Finnish, French, Galician, German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Irish, Italian, Japanese, Kyrgyz, Korean, Malay, Persian, Polish, Portuguese, Portuguese (Brazil), Russian, Slovak, Spanish, Swahili, Swedish, Turkish, Ukrainian, Urdu

## 系统要求

- Windows 操作系统
- PotPlayer 播放器
- Python 3.7+
- 约 500MB 磁盘空间（用于语言包）

## 安装步骤

### 第一步：安装 Python 依赖

```bash
# 克隆项目
git clone https://github.com/your-username/PotPlayer_Subtitle_Translate_Argos.git
cd PotPlayer_Subtitle_Translate_Argos

# 安装依赖
pip install -r requirements.txt
```

### 第二步：下载语言包

```bash
# 运行语言包下载脚本
python argos_package_init.py
```

> 首次运行会自动下载所需语言包，请耐心等待。语言包下载完成后会缓存到本地，后续无需重复下载。

### 第三步：启动翻译服务

```bash
python run.py
```

服务将在 `http://localhost:8989` 启动。

### 第四步：安装 PotPlayer 插件

1. 复制以下两个文件到 PotPlayer 安装目录：
   - `SubtitleTranslate - Argos.as`
   - `SubtitleTranslate - Argos.ico`

2. 插件路径：
   ```
   PotPlayer安装目录\Extention\Subtitle\Translate\
   ```

3. 重启 PotPlayer

### 第五步：配置 PotPlayer

1. 打开一个带外挂字幕的视频
2. 右键点击视频 → 字幕 → 在线字幕翻译 → 实时字幕翻译设置
3. 选择 **ArgosAI翻译**
4. 点击 **账户设置**（虽然不需要密钥，但需要点击确认连接本地服务）
5. 在弹出的对话框中随意输入（如 App ID: 任意, 密钥: 任意）
6. 点击确定，关闭对话框

### 第六步：开始使用

1. 右键点击视频 → 字幕 → 在线字幕翻译 → ArgosAI翻译
2. 选择目标语言
3. 享受实时字幕翻译！

## 常见问题

### 翻译服务无法连接

确保翻译服务已启动：
```bash
python run.py
```

检查服务状态：
```bash
curl http://localhost:8989/api/status
```

### 首次翻译很慢

首次翻译需要加载语言模型，请耐心等待。后续翻译会很快。

### 如何添加更多语言

编辑 `argos_package_init.py` 文件，在 `to_codes` 列表中添加所需语言代码，然后重新运行：
```bash
python argos_package_init.py
```

## 项目结构

```
PotPlayer_Subtitle_Translate_Argos/
├── run.py                          # Flask 翻译服务
├── argos_package_init.py           # 语言包下载脚本
├── list_supported.py               # 查看支持的语言
├── index.json                      # Argos 语言包索引
├── SubtitleTranslate - Argos.as    # PotPlayer 插件脚本
├── SubtitleTranslate - Argos.ico   # 插件图标
├── python_package/                 # Python 包
├── requirements.txt                # Python 依赖
├── LICENSE                         # MIT 许可证
└── readme.md                       # 项目说明
```

## API 接口

### 翻译接口

```
GET /api/translate?fromCode={源语言}&toCode={目标语言}&text={文本}
```

参数说明：
- `fromCode`: 源语言代码（如 `en`, `zh`, `auto` 表示自动检测）
- `toCode`: 目标语言代码
- `text`: 待翻译文本

### 状态接口

```
GET /api/status
```

## 致谢

- [Argos Translate](https://github.com/argosopentech/argos-translate) - 开源机器翻译库
- [PotPlayer](https://potplayer.daum.net/) - 多功能媒体播放器
- 感谢所有贡献者！

## 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！


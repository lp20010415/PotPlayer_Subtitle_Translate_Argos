<h4 align="left">
  <b>中文</b> |
  <a  href="readme_en.md">English</a>
</h4>

# PotPlayer Subtitle Translate - Argos

一个基于 [Argos Translate](https://github.com/argosopentech/argos-translate) 的 PotPlayer 实时字幕翻译插件。

本项目通过 PotPlayer 的 AngelScript 插件连接本地 Flask 翻译服务，并使用 Argos Translate 在本机完成字幕翻译。翻译过程无需调用在线翻译 API，不需要 API Key，也不需要付费订阅。

## 功能特点

- **完全免费**：无需 API Key，无需付费服务。
- **本地翻译**：使用 Argos Translate 本地翻译模型，保护隐私。
- **离线运行**：完成依赖和语言包安装后，翻译过程无需联网。
- **多语言翻译**：支持多种语言之间互译，具体取决于已安装的语言包和服务端配置。
- **自动语言检测**：支持自动识别字幕源语言。
- **实时字幕翻译**：通过 PotPlayer 实时字幕翻译功能显示翻译结果。
- **翻译缓存**：缓存已经翻译过的文本，减少重复计算。
- **任务队列**：通过后台 Worker 顺序处理翻译任务，避免多个任务同时调用翻译引擎。
- **简单易用**：配置完成后即可在 PotPlayer 中使用。

## 工作原理

项目由 PotPlayer 插件、本地 Flask 服务和 Argos Translate 翻译引擎组成。

```text
PotPlayer
    |
    | Faster-Whisper-XXL 语音识别  或 已有的字幕文件
    v
字幕文本
    |
    v
AngelScript 翻译插件
    |
    | HTTP 请求
    v
本地 Flask 服务
    |
    | 语言检测 / 缓存查询 / 任务调度
    v
后台 Translation Worker
    |
    v
Argos Translate
    |
    | 返回翻译结果
    v
Flask 服务
    |
    | HTTP 响应
    v
PotPlayer 双语字幕显示
```

工作流程：

1. PotPlayer 使用语音识别功能生成字幕。
2. AngelScript 插件获取字幕文本。
3. 插件通过 HTTP 请求将文本发送到本地 Flask 服务。
4. Flask 服务进行语言检测，并检查翻译缓存。
5. 未命中缓存的任务进入后台翻译队列。
6. 后台 Worker 调用 Argos Translate 执行翻译。
7. 翻译结果返回给 Flask 服务。
8. Flask 将结果响应给 PotPlayer，由播放器显示翻译字幕。

**说明：** 翻译队列由 Flask 服务内部管理，PotPlayer 插件不直接访问 Python 队列。`/api/queue` 是队列状态监控接口，不是翻译任务提交接口。

## 支持的语言

当前服务端配置的语言代码包括：

| 语言 | 代码 |
|---|---|
| 自动检测 | `auto` |
| 阿拉伯语 | `ar` |
| 保加利亚语 | `bg` |
| 捷克语 | `cs` |
| 丹麦语 | `da` |
| 德语 | `de` |
| 希腊语 | `el` |
| 英语 | `en` |
| 西班牙语 | `es` |
| 爱沙尼亚语 | `et` |
| 芬兰语 | `fi` |
| 法语 | `fr` |
| 匈牙利语 | `hu` |
| 意大利语 | `it` |
| 日语 | `ja` |
| 韩语 | `ko` |
| 荷兰语 | `nl` |
| 波兰语 | `pl` |
| 葡萄牙语 | `pt` |
| 罗马尼亚语 | `ro` |
| 俄语 | `ru` |
| 斯洛伐克语 | `sk` |
| 瑞典语 | `sv` |
| 泰语 | `th` |
| 简体中文 | `zh` |
| 繁体中文 | `zt` |
| 越南语 | `vi` |

实际可翻译的语言组合取决于 Argos Translate 已安装的语言包。并非所有语言之间都一定存在直接翻译模型。

如需增加语言，请同时检查：

- Argos Translate 是否提供对应语言包。
- `argos_package_init.py` 是否安装所需语言包。
- Flask 服务中的 `SUPPORTED_LANGUAGES` 和语言代码映射是否已更新。
- PotPlayer 插件中的语言代码映射是否正确。

## 系统要求

- Windows 操作系统
- PotPlayer 播放器
- Python 环境
- 网络连接（仅首次安装依赖和下载语言包时需要）
- 足够的磁盘空间用于存储 Python 依赖和语言包

具体 Python 版本要求请以项目 `requirements.txt` 中的依赖兼容性为准。

## 安装步骤

### 第一步：获取项目

```bash
git clone https://github.com/lp20010415/PotPlayer_Subtitle_Translate_Argos.git

cd PotPlayer_Subtitle_Translate_Argos
```

### 第二步：安装 Python 依赖

```bash
pip install -r requirements.txt
```

建议在独立的 Python 虚拟环境中安装依赖，避免与其他 Python 项目发生冲突。

### 第三步：下载 Argos 语言包

运行语言包初始化脚本：

```bash
python argos_package_init.py
```

首次运行时，脚本会下载配置中指定的 Argos Translate 语言包。

下载完成后，语言包会保存在本地。后续翻译时无需重复下载。

**注意：** 首次下载需要联网，请确保网络连接正常。

### 第四步：启动本地翻译服务

运行：

```bash
python run.py
```

默认服务地址：

```text
http://127.0.0.1:8989
```

服务启动后，可以通过以下地址检查服务状态：

```text
http://127.0.0.1:8989/api/status
```

如果服务正常运行，应返回服务状态信息。

请保持翻译服务运行，不要关闭对应的命令行窗口。

### 第五步：安装 PotPlayer 插件

将以下两个文件复制到 PotPlayer 安装目录：

```text
SubtitleTranslate - Argos.as
SubtitleTranslate - Argos.ico
```

插件目录：

```text
PotPlayer安装目录\Extention\Subtitle\Translate\
```

如果目录不存在，请按照上述路径创建。

复制完成后，重新启动 PotPlayer。

### 第六步：配置 PotPlayer

1. 打开 PotPlayer。
2. 播放一个带有字幕的视频。
3. 右键点击播放画面。
4. 进入：

   `字幕 → 在线字幕翻译 → 实时字幕翻译设置`

5. 选择 **ArgosAI翻译**。
6. 点击 **账户设置**。
7. 在弹出的对话框中输入任意内容，例如：

   ```text
   App ID: 任意内容
   密钥: 任意内容
   ```

8. 点击确定，完成配置。

这里的账户信息仅用于通过 PotPlayer 的插件配置流程，不代表需要注册在线翻译账户，也不需要真实 API Key。

### 第七步：开始翻译

1. 打开带字幕的视频。
2. 右键点击播放画面。
3. 进入：

   `字幕 → 在线字幕翻译 → ArgosAI翻译`

4. 选择目标语言。
5. 开始播放，即可使用实时字幕翻译。

## API 接口

本项目通过本地 Flask 服务提供 HTTP 接口。

默认地址：

```text
http://127.0.0.1:8989
```

### 1. 翻译接口

```http
GET /api/translate?fromCode={源语言}&toCode={目标语言}&text={文本}
```

参数：

| 参数 | 说明 | 示例 |
|---|---|---|
| `fromCode` | 源语言代码 | `en`、`ja`、`auto` |
| `toCode` | 目标语言代码 | `zh` |
| `text` | 需要翻译的文本 | `Hello world` |

示例：

```text
http://127.0.0.1:8989/api/translate?fromCode=en&toCode=zh&text=Hello%20world
```

建议使用支持 URL 编码的 HTTP 客户端传递文本，避免特殊字符、空格和非 ASCII 字符导致请求参数解析错误。

成功响应示例：

```json
{
  "status": "success",
  "message": "你好，世界"
}
```

具体错误响应以服务端实际实现为准。

### 2. 服务状态接口

```http
GET /api/status
```

用于检查 Flask 翻译服务是否正常运行。

### 3. 队列监控接口

```http
GET /api/queue
```

用于查看后台翻译队列的运行状态，例如队列长度、已完成任务数和失败任务数。

此接口仅用于监控，不负责提交翻译任务。

## 翻译缓存与任务队列

为了提高实时字幕翻译效率，服务端使用了缓存和后台任务队列。

### 翻译缓存

- 对已经翻译过的文本进行缓存。
- 相同源语言、目标语言和文本可以直接返回缓存结果。
- 缓存具有有效期和容量限制。
- 缓存命中时不需要再次调用 Argos Translate。

### 后台任务队列

- 未命中缓存的翻译任务进入内部队列。
- 后台 Worker 按队列顺序处理任务。
- 使用单个 Worker 避免多个任务同时调用 Argos 翻译引擎。
- 相同翻译任务可以共享正在执行的结果，减少重复翻译。

队列属于 Flask 服务内部实现，PotPlayer 只需要调用翻译 HTTP 接口并接收结果。

## 常见问题

### 1. 翻译服务无法连接

首先确认 Flask 服务已经启动：

```bash
python run.py
```

检查服务状态：

```text
http://127.0.0.1:8989/api/status
```

如果无法访问，请检查：

- Flask 服务是否正常启动。
- 端口 `8989` 是否被其他程序占用。
- 防火墙或安全软件是否阻止本地连接。
- PotPlayer 插件中的服务地址是否正确。

### 2. 首次翻译速度较慢

首次翻译可能涉及模型加载和翻译引擎初始化，因此耗时可能较长。

后续翻译通常会更快。相同文本还可以直接使用缓存结果。

### 3. 某些语言无法翻译

请检查：

- 对应语言包是否已经安装。
- `argos_package_init.py` 是否包含所需语言。
- Flask 服务是否允许对应语言代码。
- Argos Translate 是否存在该语言组合的直接翻译模型。

### 4. 如何添加更多语言

首先确认 Argos Translate 是否提供所需语言包。

然后编辑 `argos_package_init.py`，将对应语言代码加入语言包安装配置中。

重新运行：

```bash
python argos_package_init.py
```

最后，根据需要更新 Flask 服务中的语言列表和语言映射，以及 PotPlayer 插件中的语言代码映射。

### 5. 翻译结果没有显示

请检查：

- 本地 Flask 服务是否正在运行。
- PotPlayer 是否选择了 ArgosAI翻译。
- 目标语言是否正确。
- `/api/translate` 是否能够正常返回翻译结果。
- 服务端是否出现翻译异常或任务超时。

可以先通过浏览器或 HTTP 客户端测试翻译接口，以确定问题出在 Flask 服务还是 PotPlayer 插件。

### 6. 是否需要联网？

正常翻译时不需要联网。

但是首次安装 Python 依赖和下载 Argos 语言包时需要联网。完成安装后，可以在本地离线使用。

## 项目结构

```text
PotPlayer_Subtitle_Translate_Argos/
│
├── run.py                          # Flask 本地翻译服务
├── argos_package_init.py           # Argos 语言包初始化脚本
├── list_supported.py               # 查看支持的语言
├── index.json                      # Argos 语言包索引
│
├── SubtitleTranslate - Argos.as    # PotPlayer AngelScript 插件
├── SubtitleTranslate - Argos.ico   # 插件图标
│
├── python_package/                 # Python 相关文件
├── requirements.txt                # Python 依赖
│
├── LICENSE                         # MIT 许可证
├── readme.md                       # 中文项目说明
└── readme_en.md                    # English documentation
```

## 致谢

- [Argos Translate](https://github.com/argosopentech/argos-translate) - 开源本地机器翻译工具。
- [PotPlayer](https://potplayer.tv) - 多功能媒体播放器。
- 感谢所有开源项目作者和贡献者。

## 许可证

本项目采用 MIT License 开源协议，详情请参阅 [LICENSE](LICENSE)。

## 贡献

欢迎提交 Issue 和 Pull Request。

如果你发现问题、希望增加语言支持或有改进建议，欢迎参与项目贡献。
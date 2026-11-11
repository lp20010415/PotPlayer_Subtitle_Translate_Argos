<h4 align="left">
  <a href="readme.md">中文</a> |
  <b>English</b>
</h4>

# PotPlayer Subtitle Translate - Argos

A real-time subtitle translation plugin for PotPlayer powered by [Argos Translate](https://github.com/argosopentech/argos-translate).

This project connects a PotPlayer AngelScript plugin to a local Flask translation service and uses Argos Translate to perform subtitle translation locally. No online translation API, API key, or paid subscription is required.

## Features

- **Completely Free**: No API keys or paid services required.
- **Local Translation**: Uses local Argos Translate models to protect your privacy.
- **Offline Operation**: Translation works without an internet connection after dependencies and language packages have been installed.
- **Multilingual Translation**: Supports translation between multiple languages, depending on the installed language packages and server configuration.
- **Automatic Language Detection**: Automatically detects the source language of subtitles.
- **Real-Time Subtitle Translation**: Displays translated subtitles through PotPlayer's real-time subtitle translation feature.
- **Translation Cache**: Caches previously translated text to reduce redundant processing.
- **Task Queue**: Uses a background Worker to process translation tasks sequentially, preventing multiple tasks from invoking the translation engine simultaneously.
- **Easy to Use**: Once configured, the plugin can be used directly in PotPlayer.

## How It Works

The project consists of a PotPlayer plugin, a local Flask service, and the Argos Translate translation engine.

```text
PotPlayer
    |
    | Faster-Whisper-XXL Speech Recognition
    | or Existing Subtitle Files
    v
Subtitle Text
    |
    v
AngelScript Translation Plugin
    |
    | HTTP Request
    v
Local Flask Service
    |
    | Language Detection / Cache Lookup / Task Scheduling
    v
Background Translation Worker
    |
    v
Argos Translate
    |
    | Return Translation Result
    v
Flask Service
    |
    | HTTP Response
    v
Bilingual Subtitles Displayed in PotPlayer
```

Translation workflow:

1. PotPlayer generates subtitles using its speech recognition feature or loads an existing subtitle file.
2. The AngelScript plugin receives the subtitle text.
3. The plugin sends the text to the local Flask service through an HTTP request.
4. The Flask service detects the source language and checks the translation cache.
5. Tasks that are not found in the cache are added to the background translation queue.
6. The background Worker calls Argos Translate to perform the translation.
7. The translation result is returned to the Flask service.
8. The Flask service sends the result back to PotPlayer, where the translated subtitles are displayed.

**Note:** The translation queue is managed internally by the Flask service. The PotPlayer plugin does not directly access the Python queue. `/api/queue` is an endpoint for monitoring queue status, not for submitting translation tasks.

## Supported Languages

The current server configuration includes the following language codes:

| Language | Code |
|---|---|
| Automatic Detection | `auto` |
| Arabic | `ar` |
| Bulgarian | `bg` |
| Czech | `cs` |
| Danish | `da` |
| German | `de` |
| Greek | `el` |
| English | `en` |
| Spanish | `es` |
| Estonian | `et` |
| Finnish | `fi` |
| French | `fr` |
| Hungarian | `hu` |
| Italian | `it` |
| Japanese | `ja` |
| Korean | `ko` |
| Dutch | `nl` |
| Polish | `pl` |
| Portuguese | `pt` |
| Romanian | `ro` |
| Russian | `ru` |
| Slovak | `sk` |
| Swedish | `sv` |
| Thai | `th` |
| Simplified Chinese | `zh` |
| Traditional Chinese | `zt` |
| Vietnamese | `vi` |

The actual available translation pairs depend on the Argos Translate language packages installed. Not every language pair necessarily has a direct translation model available.

To add more languages, make sure to check the following:

- Whether Argos Translate provides the corresponding language packages.
- Whether `argos_package_init.py` installs the required language packages.
- Whether `SUPPORTED_LANGUAGES` and the language code mappings in the Flask service have been updated.
- Whether the language code mappings in the PotPlayer plugin are correct.

## System Requirements

- Windows operating system
- PotPlayer media player
- Python environment
- Internet connection (only required for the initial installation of dependencies and language packages)
- Sufficient disk space for Python dependencies and language packages

The specific Python version requirement depends on the compatibility of the dependencies listed in `requirements.txt`.

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/lp20010415/PotPlayer_Subtitle_Translate_Argos.git

cd PotPlayer_Subtitle_Translate_Argos
```

### Step 2: Install Python Dependencies

```bash
pip install -r requirements.txt
```

It is recommended to install the dependencies in a dedicated Python virtual environment to avoid conflicts with other Python projects.

### Step 3: Download Argos Language Packages

Run the language package initialization script:

```bash
python argos_package_init.py
```

On the first run, the script downloads the Argos Translate language packages specified in the configuration.

After downloading, the language packages are stored locally. They do not need to be downloaded again for subsequent translations.

**Note:** An internet connection is required for the initial download. Make sure your network connection is working properly.

### Step 4: Start the Local Translation Service

Run:

```bash
python run.py
```

Default service address:

```text
http://127.0.0.1:8989
```

After the service starts, you can check its status at:

```text
http://127.0.0.1:8989/api/status
```

If the service is running correctly, it should return service status information.

Keep the translation service running. Do not close the corresponding command-line window while using the plugin.

### Step 5: Install the PotPlayer Plugin

Copy the following two files into the PotPlayer installation directory:

```text
SubtitleTranslate - Argos.as
SubtitleTranslate - Argos.ico
```

Plugin directory:

```text
PotPlayer installation directory\Extention\Subtitle\Translate\
```

If the directory does not exist, create it using the path shown above.

Restart PotPlayer after copying the files.

### Step 6: Configure PotPlayer

1. Open PotPlayer.
2. Play a video with subtitles.
3. Right-click the playback window.
4. Navigate to:

   `Subtitles → Online Subtitle Translation → Real-time Subtitle Translation Settings`

5. Select **ArgosAI Translation**.
6. Click **Account Settings**.
7. Enter any values in the dialog box, for example:

   ```text
   App ID: Any value
   Secret Key: Any value
   ```

8. Click OK to complete the configuration.

The account information is only used to pass through PotPlayer's plugin configuration process. You do not need to register for an online translation account or provide a real API key.

### Step 7: Start Translating

1. Open a video with subtitles.
2. Right-click the playback window.
3. Navigate to:

   `Subtitles → Online Subtitle Translation → ArgosAI Translation`

4. Select the target language.
5. Start playback to enjoy real-time subtitle translation.

## API Endpoints

This project provides HTTP endpoints through a local Flask service.

Default address:

```text
http://127.0.0.1:8989
```

### 1. Translation Endpoint

```http
GET /api/translate?fromCode={source_language}&toCode={target_language}&text={text}
```

Parameters:

| Parameter | Description | Example |
|---|---|---|
| `fromCode` | Source language code | `en`, `ja`, `auto` |
| `toCode` | Target language code | `zh` |
| `text` | Text to be translated | `Hello world` |

Example:

```text
http://127.0.0.1:8989/api/translate?fromCode=en&toCode=zh&text=Hello%20world
```

It is recommended to use an HTTP client that supports URL encoding when sending text. This helps prevent request parsing errors caused by special characters, spaces, and non-ASCII characters.

Example of a successful response:

```json
{
  "status": "success",
  "message": "你好，世界"
}
```

The actual error response format depends on the server implementation.

### 2. Service Status Endpoint

```http
GET /api/status
```

Used to check whether the Flask translation service is running properly.

### 3. Queue Monitoring Endpoint

```http
GET /api/queue
```

Used to monitor the status of the background translation queue, such as the queue length, number of completed tasks, and number of failed tasks.

This endpoint is for monitoring only. It does not submit translation tasks.

## Translation Cache and Task Queue

To improve real-time subtitle translation performance, the server uses a translation cache and a background task queue.

### Translation Cache

- Previously translated text is cached.
- Requests with the same source language, target language, and text can directly return cached results.
- The cache has expiration and capacity limits.
- When a cache hit occurs, Argos Translate does not need to be called again.

### Background Task Queue

- Translation tasks that are not found in the cache are added to the internal queue.
- The background Worker processes tasks in queue order.
- A single Worker is used to prevent multiple tasks from invoking the Argos translation engine simultaneously.
- Identical translation tasks can share the result of an ongoing translation to reduce redundant processing.

The queue is an internal implementation of the Flask service. PotPlayer only needs to call the translation HTTP endpoint and receive the result.

## Frequently Asked Questions

### 1. Cannot Connect to the Translation Service

First, make sure the Flask service has started:

```bash
python run.py
```

Check the service status:

```text
http://127.0.0.1:8989/api/status
```

If the endpoint cannot be accessed, check the following:

- Whether the Flask service has started successfully.
- Whether port `8989` is already being used by another application.
- Whether the firewall or security software is blocking local connections.
- Whether the service address configured in the PotPlayer plugin is correct.

### 2. The First Translation Is Slow

The first translation may take longer because the translation model needs to be loaded and the translation engine needs to be initialized.

Subsequent translations are usually faster. Previously translated text can also be returned directly from the cache.

### 3. Some Languages Cannot Be Translated

Please check the following:

- Whether the corresponding language packages have been installed.
- Whether `argos_package_init.py` includes the required languages.
- Whether the Flask service allows the requested language codes.
- Whether Argos Translate provides a direct translation model for the selected language pair.

### 4. How to Add More Languages

First, make sure Argos Translate provides the required language packages.

Then edit `argos_package_init.py` and add the corresponding language codes to the language package installation configuration.

Run the script again:

```bash
python argos_package_init.py
```

Finally, update the language list and language mappings in the Flask service, as well as the language code mappings in the PotPlayer plugin, as needed.

### 5. Translated Subtitles Are Not Displayed

Please check the following:

- Whether the local Flask service is running.
- Whether ArgosAI Translation is selected in PotPlayer.
- Whether the target language is correct.
- Whether `/api/translate` can return translation results successfully.
- Whether the server reports translation errors or task timeouts.

You can test the translation endpoint using a browser or HTTP client to determine whether the problem is caused by the Flask service or the PotPlayer plugin.

### 6. Does Translation Require an Internet Connection?

An internet connection is not required during normal translation.

However, an internet connection is required for the initial installation of Python dependencies and downloading Argos language packages. Once installation is complete, the service can run locally and work offline.

## Project Structure

```text
PotPlayer_Subtitle_Translate_Argos/
│
├── run.py                          # Local Flask translation service
├── argos_package_init.py           # Argos language package initialization script
├── list_supported.py               # List supported languages
├── index.json                      # Argos language package index
│
├── SubtitleTranslate - Argos.as    # PotPlayer AngelScript plugin
├── SubtitleTranslate - Argos.ico   # Plugin icon
│
├── python_package/                 # Python-related files
├── requirements.txt                # Python dependencies
│
├── LICENSE                         # MIT License
├── README.md                       # Chinese documentation
└── README_EN.md                    # English documentation
```

## Acknowledgements

- [Argos Translate](https://github.com/argosopentech/argos-translate) - An open-source local machine translation tool.
- [PotPlayer](https://potplayer.tv) - A versatile media player.
- Thanks to all open-source project authors and contributors.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests are welcome.

If you find a bug, would like to add language support, or have suggestions for improvement, feel free to contribute.
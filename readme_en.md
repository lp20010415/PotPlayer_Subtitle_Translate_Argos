<h4 align="left">
  <a href="readme.md">中文</a> |
  <b>English</b>
</h4>

# PotPlayer Subtitle Translate - Argos

A real-time subtitle translation plugin for PotPlayer powered by [Argos Translate](https://github.com/argosopentech/argos-translate). Uses local AI translation engine, no internet required, completely free, supports multiple languages.

## Features

- Completely free, no API keys or paid services required
- Local deployment, privacy-friendly, no internet needed
- Supports 30+ languages for mutual translation
- Automatic language detection
- Real-time subtitle translation
- Easy to install and use

## Supported Languages

Arabic, Azerbaijani, Basque, Catalan, Chinese, Czech, Danish, Dutch, English, Esperanto, Finnish, French, Galician, German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Irish, Italian, Japanese, Kyrgyz, Korean, Malay, Persian, Polish, Portuguese, Portuguese (Brazil), Russian, Slovak, Spanish, Swahili, Swedish, Turkish, Ukrainian, Urdu

## System Requirements

- Windows OS
- PotPlayer media player
- Python 3.7+
- ~500MB disk space (for language packs)

## Installation

### Step 1: Install Python Dependencies

```bash
# Clone the repository
git clone https://github.com/your-username/PotPlayer_Subtitle_Translate_Argos.git
cd PotPlayer_Subtitle_Translate_Argos

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Download Language Packs

```bash
# Run the language pack download script
python argos_package_init.py
```

> First run will automatically download required language packs. Please be patient. Language packs are cached locally after download.

### Step 3: Start Translation Service

```bash
python run.py
```

Service will start at `http://localhost:8989`.

### Step 4: Install PotPlayer Plugin

1. Copy these two files to PotPlayer installation directory:
   - `SubtitleTranslate - Argos.as`
   - `SubtitleTranslate - Argos.ico`

2. Plugin path:
   ```
   PotPlayer_Dir\Extention\Subtitle\Translate\
   ```

3. Restart PotPlayer

### Step 5: Configure PotPlayer

1. Open a video with external subtitles
2. Right-click video → Subtitles → Online Subtitle Translation → Real-time Translation Settings
3. Select **ArgosAI Translate**
4. Click **Account Settings** (no actual credentials needed, just confirm local service connection)
5. Enter any values in the dialog (e.g., App ID: anything, Secret: anything)
6. Click OK, close the dialog

### Step 6: Start Using

1. Right-click video → Subtitles → Online Subtitle Translation → ArgosAI Translate
2. Select target language
3. Enjoy real-time subtitle translation!

## FAQ

### Translation Service Connection Failed

Ensure the translation service is running:
```bash
python run.py
```

Check service status:
```bash
curl http://localhost:8989/api/status
```

### First Translation is Slow

First translation requires loading the language model. Please wait patiently. Subsequent translations will be fast.

### How to Add More Languages

Edit `argos_package_init.py`, add language codes to the `to_codes` list, then run:
```bash
python argos_package_init.py
```

## Project Structure

```
PotPlayer_Subtitle_Translate_Argos/
├── run.py                          # Flask translation service
├── argos_package_init.py           # Language pack download script
├── list_supported.py               # List supported languages
├── index.json                      # Argos language pack index
├── SubtitleTranslate - Argos.as    # PotPlayer plugin script
├── SubtitleTranslate - Argos.ico   # Plugin icon
├── python_package/                 # Python packages
├── requirements.txt                # Python dependencies
├── LICENSE                         # MIT License
└── readme.md                       # Project documentation
```

## API

### Translation Endpoint

```
GET /api/translate?fromCode={source_lang}&toCode={target_lang}&text={text}
```

Parameters:
- `fromCode`: Source language code (e.g., `en`, `zh`, `auto` for auto-detection)
- `toCode`: Target language code
- `text`: Text to translate

### Status Endpoint

```
GET /api/status
```

## Acknowledgments

- [Argos Translate](https://github.com/argosopentech/argos-translate) - Open-source machine translation library
- [PotPlayer](https://potplayer.tv) - Multimedia player
- Thanks to all contributors!

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Contributing

Issues and Pull Requests are welcome!

"""
支持的语言
Arabic, Azerbaijani, Basque, Catalan, Chinese, Czech, Danish, Dutch, English, Esperanto, Finnish, French, Galician, German, 
Greek, Hebrew, Hindi, Hungarian, Indonesian, Irish, Italian, Japanese, Kyrgyz, Korean, Malay, Persian, Polish, Portuguese, 
Portuguese (Brazil), Russian, Slovak, Spanish, Swahili, Swedish, Turkish, Ukrainian, Urdu
"""

from collections import OrderedDict
from flask import Flask, request, jsonify
from langdetect import detect_langs, DetectorFactory
from concurrent.futures import Future, TimeoutError
import re
import time
import queue
import logging
import threading
import unicodedata
import argostranslate.translate

"""
Argos Translate Package Index
https://www.argosopentech.com/argospm/index/
"""


SUPPORTED_LANGUAGES = [
    "auto", # 自动检测
    "en", # 英语
    "zh", # 中文
    "zt", # 繁体中文
    "ja", # 日文
    "ko", # 韩文
    "fr", # 法文
    "es", # 西班牙文
    "th", # 泰文
    "ar", # 阿拉伯文
    "ru", # 俄文
    "pt", # 葡萄牙文
    "de", # 德文
    "it", # 意大利文
    "el", # 希腊文
    "nl", # 荷兰文
    "pl", # 波兰文
    "bg", # 保加利亚文
    "et", # 爱沙尼亚文
    "da", # 丹麦文
    "fi", # 芬兰文
    "cs", # 捷克文
    "ro", # 罗马尼亚文
    "sk", # 斯洛伐克文
    "sv", # 瑞典文
    "hu", # 匈牙利文
    "vi", # 越南文
]

# langdetect 到 Argos 的语言映射（与 AS 脚本的 GetLang 对应）
LANG_DETECT_TO_ARGOS = {
    'zh-cn': 'zh',      # 简体中文
    'zh-tw': 'zt',      # 繁体中文
    'zh': 'zh',         # 中文（默认简体）
    'ja': 'ja',         # 日语
    'ko': 'ko',         # 韩语
    'fr': 'fr',         # 法语
    'es': 'es',         # 西班牙语
    'th': 'th',         # 泰语
    'ar': 'ar',         # 阿拉伯语
    'ru': 'ru',         # 俄语
    'pt': 'pt',         # 葡萄牙语
    'de': 'de',         # 德语
    'it': 'it',         # 意大利语
    'el': 'el',         # 希腊语
    'nl': 'nl',         # 荷兰语
    'pl': 'pl',         # 波兰语
    'bg': 'bg',         # 保加利亚语
    'et': 'et',         # 爱沙尼亚语
    'da': 'da',         # 丹麦语
    'fi': 'fi',         # 芬兰语
    'cs': 'cs',         # 捷克语
    'ro': 'ro',         # 罗马尼亚语
    'sk': 'sk',         # 斯洛伐克语
    'sv': 'sv',         # 瑞典语
    'hu': 'hu',         # 匈牙利语
    'vi': 'vi',         # 越南语
    'en': 'en',         # 英语
}

app = Flask(__name__)

app.logger.setLevel(logging.INFO)

DetectorFactory.seed = 0

HOST = "127.0.0.1"
PORT = 8989

# 翻译缓存多少条
CACHE_MAX_SIZE = 2000
# 缓存保存多少秒
CACHE_TTL_SECONDS = 7200

# 单词字幕最大长度，防止异常请求
MAX_TEXT_LENGTH = 5000

# 自动识别不确定时的默认语言
AUTO_FALLBACK_LANG = "en"       # 主要看什么视频，就对照上面映射表改成相应的
# 自动翻译成的语言
AUTO_TRANSLATED_LANG = "zh"

TRADITIONAL_CHARS = set(
    "體國學習萬與為這個來時會說對發現後裡開關點"
    "書車門風雲電腦網絡臺灣香港歡樂愛"
)

def normalize_language(code):
    code = (code or "").strip().lower()
    return LANG_DETECT_TO_ARGOS.get(code, code)


def detect_language(text):
    """
    检测文本语言，返回 Argos 支持的语言代码
    """
    """
    优先通过文字特征识别中文、韩文、日文、泰文、阿拉伯文等。
    其他语言再交给langdetect
    """

    text = text.strip()

    if not text:
        return AUTO_FALLBACK_LANG

    # 日文假名(由于日文中可能包含中文，所以需要先判断)
    if re.search(r"[\u3040-\u30ff]", text):
        return "ja"

    # 韩文(由于韩文中可能包含中文，所以需要先判断)
    if re.search(r"[\uac00-\ud7af]", text):
        return "ko"

    # 中文汉字
    if re.search(r"[\u4e00-\u9fff]", text):
        if any(ch in TRADITIONAL_CHARS for ch in text):
            return "zt"
        return "zh"

    # 俄文等西里尔文字
    if re.search(r"[\u0400-\u04ff]", text):
        try:
            results = detect_langs(text)
            if results:
                return normalize_language(results[0].lang)
        except Exception:
            pass
        return "ru"


    # 泰文
    if re.search(r"[\u0e00-\u0e7f]", text):
        return "th"

    # 阿拉伯文
    if re.search(r"[\u0600-\u06ff]", text):
        return "ar"

    # 太短的文本通常无法可靠判断语言
    if len(text) < 4:
        return AUTO_FALLBACK_LANG

    try:
        # langdetect 返回检测结果列表，按概率排序
        results = detect_langs(text)

        if not results:
            return AUTO_FALLBACK_LANG
        best = results[0]

        # 低置信度时默认使用默认语言
        if best.prob < 0.55:
            return AUTO_FALLBACK_LANG
        result = normalize_language(best.lang)

        if result not in SUPPORTED_LANGUAGES:
            return AUTO_FALLBACK_LANG

        return result

        # if detections:
        #     detected_lang = detections[0].lang  # 取最可能的语言
        #     # 映射到 Argos 支持的语言代码
        #     argos_lang = LANG_DETECT_TO_ARGOS.get(detected_lang, 'en')
        #     return argos_lang
    except Exception as e:
        app.logger.exception(f"语言检测失败: {e}")
        return AUTO_FALLBACK_LANG


"""
    翻译缓存
"""

cache = OrderedDict()
cache_lock = threading.Lock()

def make_cache_key(src, dst, text):
    # Unicode规范化，避免相同文字因编码形式不同缓存失败
    normalized_text = unicodedata.normalize("NFC", text.strip())
    return src, dst, normalized_text


def get_cache(key):
    now = time.monotonic()

    with cache_lock:
        item = cache.get(key)

        if item is None:
            return None

        translated, created_at = item

        if now - created_at > CACHE_TTL_SECONDS:
            del cache[key]
            return None

        cache.move_to_end(key)
        return translated


def set_cache(key, translated):
    with cache_lock:
        cache[key] = (translated, time.monotonic())
        cache.move_to_end(key)

        while len(cache) > CACHE_MAX_SIZE:
            cache.popitem(last=False)


"""
    请求去重
"""
TRANSLATION_QUEUE_SIZE = 1000

TRANSLATION_WAIT_TIMEOUT = 120

translation_queue = queue.Queue(maxsize=TRANSLATION_QUEUE_SIZE)

in_flight = {}
in_flight_lock = threading.Lock()

# 记录队列任务数量和运行状态
queue_stats_lock = threading.Lock()
completed_tasks = 0
failed_tasks = 0

def validate_translation(original, translated):
    """
    检查 Argos 返回的翻译是否可用。
    """

    if not isinstance(translated, str):
        return False

    translated = translated.strip()

    if not translated:
        return False

    # 检查明显的错误信息
    invalid_prefixes = (
        "error:",
        "error_msg=",
        "exception:",
        "traceback",
        "翻译失败",
        "翻译错误",
    )

    if translated.lower().startswith(invalid_prefixes):
        return False

    # 过长结果通常意味着模型输出异常
    if len(translated) > MAX_TEXT_LENGTH * 3:
        return False

    # 防止返回完全没有内容的特殊字符
    if not any(ch.isalnum() for ch in translated):
        return False

    return True


def translation_worker():

    global completed_tasks, failed_tasks

    app.logger.info("翻译队列开始")

    while True:

        # FIFO 获取任务
        task = translation_queue.get()
        key = None
        future = None
        src = None
        dst = None
        try:
            key, src, dst, text, future = task

            # 调用 Argos
            translated = argostranslate.translate.translate(text, src, dst)

            # 检查翻译结果
            if not validate_translation(text, translated):
                raise RuntimeError("Invalid translation result")

            result = {
                "message": translated,
                "status": "success",
                "cached": False,
                "queued": True
            }

            # 只有成功结果才缓存
            set_cache(key, translated)

            with queue_stats_lock:
                completed_tasks += 1

            future.set_result(result)

        except Exception as e:
            app.logger.exception(f"翻译错误: {src} -> {dst}, 报错: {e}")

            result = {
                "message": "",
                "status": "error"
            }

            with queue_stats_lock:
                failed_tasks += 1

        finally:
            if future is not None and not future.done():
                try:
                    future.set_result(result)
                except Exception as e:
                    app.logger.exception(f"设置Future结果失败, 报错: {e}")

            if key is not None and future is not None:
                with in_flight_lock:
                    if in_flight.get(key) is future:
                        in_flight.pop(key, None)

            translation_queue.task_done()


def translate_once(src, dst, text):
    """
    相同src、dst、text的并发请求只执行一次Argos翻译
    其他请求等待同一个Future的结果
    """

    key = make_cache_key(src, dst, text)

    cached = get_cache(key)

    if cached is not None:
        return {
            "message": cached,
            "status": "success",
            "cached": True
        }


    with in_flight_lock:
        future = in_flight.get(key)

        if future is None:
            future = Future()
            in_flight[key] = future
            is_owner = True
        else:
            is_owner = False

    if is_owner:
        try:
            translation_queue.put((key, src, dst, text, future), timeout=5)
        except Exception as e:
            with in_flight_lock:
                if in_flight.get(key) is future:
                    in_flight.pop(key, None)
            app.logger.exception(f"加入翻译队列失败: {e}")

            return {
                "message": "",
                "status": "error"
            }

    # 等待翻译结果
    try:
        result = future.result(timeout=TRANSLATION_WAIT_TIMEOUT)
        result = dict(result)

        if not is_owner:
            result["deduplicated"] = True
        return result
    except TimeoutError:
        app.logger.error(f"翻译等待超时: {text[:100]}")

        return {
            "message": "",
            "status": "error"
        }
    except Exception as e:
        app.logger.error(f"获取翻译结果失败: {text[:100]}, 报错: {e}")

        return {
            "message": "",
            "status": "error"
        }


"""
    翻译请求
"""

def handle_translation_request(from_code, to_code, text):
    if not text or not text.strip():
        return {
            'message': '字幕内容为空',
            'status': 'error'
        }

    if len(text) > MAX_TEXT_LENGTH:
        return {
            'message': '字幕文本过长',
            'status': 'error'
        }

    src = normalize_language(from_code)
    dst = normalize_language(to_code)

    if src == "auto":
        src = detect_language(text)

    if src not in SUPPORTED_LANGUAGES:
        return {
            "message": f"不支持的源语言: {src}",
            "status": "error"
        }

    if dst == "auto" or  dst not in SUPPORTED_LANGUAGES:
        return {
            "message": f"不支持的目标语言: {dst}",
            "status": "error"
        }

    # 相同语言无需翻译
    if src == dst:
        return {
            "message": text,
            "status": "success",
            "cached": False
        }

    return translate_once(src, dst, text)
    # try:
    #     translated_text = translate_text(from_code, to_code, text)
    # except Exception as e:
    #     print(f"翻译异常: {e}")
    #     return jsonify({
    #         "message": str(e),
    #         "status": "error"
    #     })
    #
    # if translated_text is not None:
    #     return jsonify({
    #         'message': translated_text,
    #         'status': 'success'
    #     })
    # else:
    #     return jsonify({
    #         'message': f'无法找到从 {from_code} 到 {to_code} 的翻译器',
    #         'status': 'error'
    #     })


@app.route('/api/translate', methods=['GET'])
def handle_translate():
    
    fromCode = request.args.get("fromCode", "auto") # 源语言
    toCode = request.args.get("toCode", AUTO_TRANSLATED_LANG)     # 目标语言
    text = request.args.get("text", "")         # 待翻译文本

    try:
        result = handle_translation_request(fromCode, toCode, text)
        return jsonify(result)
    except Exception as e:
        app.logger.exception(f"未知报错: {e}")

        return jsonify({
            "message": "",
            "status": "error"
        })


@app.route("/api/queue", methods=["GET"])
def api_queue():

    with queue_stats_lock:
        completed = completed_tasks
        failed = failed_tasks

    return jsonify({
        "status": "success",
        "queue_size": translation_queue.qsize(),
        "completed": completed,
        "failed": failed
    })


@app.route('/api/status', methods=['GET'])
def handle_status():
    return jsonify({
        'message': 'API is running',
        'status': 'success'
    })


if __name__ == '__main__':
    worker_thread = threading.Thread(
        target=translation_worker,
        daemon=True,
        name="ArgosTranslationWorker"
    )

    worker_thread.start()

    app.run(debug=False, host=HOST, port=PORT, threaded=True)

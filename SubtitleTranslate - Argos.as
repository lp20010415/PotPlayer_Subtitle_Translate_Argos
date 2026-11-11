/*
    real time subtitle translate for PotPlayer using Argos Translate AI
*/

// string GetTitle()                                                         -> get title for UI
// string GetVersion                                                        -> get version for manage
// string GetDesc()                                                            -> get detail information
// string GetLoginTitle()                                                    -> get title for login dialog
// string GetLoginDesc()                                                    -> get desc for login dialog
// string ServerLogin(string User, string Pass)                                -> login
// string ServerLogout()                                                    -> logout
// array<string> GetSrcLangs()                                                 -> get source language
// array<string> GetDstLangs()                                                 -> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang)     -> do translate !!

//必须配置的部分，不过现在已经移交到“实时字幕翻译”中了
//它的位置是： 打开任意视频或者点击左上角的PolPlayer -> 字幕 -> 实时字幕翻译 -> 实时字幕翻译设置 -> 选中百度翻译 -> 点右边的 “账户设置”
string appId = "";//appid
string toKen = "";//密钥

//可选配置，一般而言是不用修改的！
int coolTime = 0;//冷却时间，这里的单位是毫秒，1秒钟=1000毫秒，如果提示 error:54003, 那么就加大这个数字，建议一次加100
string userAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";//这个是可选配置，一般不用修改！

//执行环境，请不要修改！
int NULL = 0;
string translateUrl = "http://127.0.0.1:8989/api/translate?";//本地部署的翻译AI的地址
string statusUrl = "http://127.0.0.1:8989/api/status";//本地部署的翻译AI的状态地址


/** 获取当前插件的版本号*/
string GetVersion(){
    return "1";
}

/** 获取当前插件的标题 */
string GetTitle(){
    return "{$CP950=ArgosAI翻译$}{$CP936=ArgosAI翻译$}{$CP0=ArgosAI_Translate$}";
}


/** 获取当前插件的表述信息 */
string GetDesc(){
    return "https://github.com/lp20010415/PotPlayer_Subtitle_Translate_Argos";
}

/** 获取登录的标题 */
string GetLoginTitle(){
    return "请输入配置";
}

/** 获取登录的描述信息 */
string GetLoginDesc(){
    return "请输入AppId和密钥！";
}


/** 获取登录时，用户输入框的标签名称 */
string GetUserText(){
    return "App ID:";
}

/** 获取登录时，密码输入框的标签名称 */
string GetPasswordText(){
    return "密钥:";
}


/** 获取支持的语言列表 - 源语言 */
array<string> GetSrcLangs(){
    array<string> ret = GetLangTable();
    
    ret.insertAt(0, ""); // empty is auto
    return ret;
}

/** 获取支持的语言列表 - 目标语言 */
array<string> GetDstLangs(){
    return GetLangTable();
}

/** 登录账号入口
 *  因为本地部署翻译AI，所以不需要登录账号了，直接返回成功即可
 * @param appIdStr appid 字符串
 * @param toKenStr 秘钥字符串
 */
string ServerLogin(string appIdStr, string toKenStr){
    
    string html = HostUrlGetString(statusUrl, userAgent);

    if (html.empty()){ // 如果没能成功取得 Html 内容
        return "error_msg=无法连接到本地部署的翻译AI，请检查是否已启动！";
    }

    //记录到全局变量中
    appId = appIdStr;
    toKen = toKenStr;
    return "200 ok";
}



/** 获取语言 */
string GetLang(string &in lang){
    string result = lang;

    if (result.empty()){//空字符串
        result = "auto";
    } else if (result == "zh-CN"){//简体中文
        result = "zh";
    } else if (result == "zh-TW"){//繁体中文
        result = "zt";
    } else if (result == "kor"){//韩文
        result = "ko";
    } else if (result == "fra"){//法文
        result = "fr";
    } else if (result == "spa"){//西班牙文
        result = "es";
    } else if (result == "ara"){//阿拉伯文
        result = "ar";
    } else if (result == "bul"){//保加利亚文
        result = "bg";
    } else if (result == "est"){//爱沙尼亚文
        result = "et";
    } else if (result == "dan"){//丹麦文
        result = "da";
    } else if (result == "fin"){//芬兰文
        result = "fi";
    } else if (result == "cs"){//捷克文
        result = "cs";
    } else if (result == "slo"){//斯洛伐克文
        result = "sk";
    } else if (result == "swe"){//瑞典文
        result = "sv";
    } else if (result == "vie"){//越南文
        result = "vi";
    };

    return result;
}


/** 解析Json数据
 * @param json 服务器返回的Json字符串
 */
string JsonParse(string json){
    string ret = "";//返回值
    JsonReader reader;
    JsonValue root;

    // JSON解析失败
    if (!reader.parse(json, root)) {
        return "";
    }

    if (!root.isObject()) {
        return "";
    }

    JsonValue status = root["status"];

    if (!status.isString()) {
        return "";
    }

    if (status.asString() != "success") {
        return "";
    }

    JsonValue message = root["message"];
    if (!message.isString()) {
        return "";
    }

    ret = message.asString();
    if (ret.empty()) {
        return "";
    }

    return ret;
}


/** 翻译的入口
 * @param text 待翻译的原文
 * @param srcLang 当前语言
 * @param dstLang 目标语言
 */
string Translate(string text, string &in srcLang, string &in dstLang){
    string ret = "";
    if(!text.empty()){
        // 有内容需要翻译才有必要继续
        // 开发文档。需要App id 等信息
        // HostOpenConsole();    // for debug
        
        //语言选择
        srcLang = GetLang(srcLang);       // 源语言
        dstLang = GetLang(dstLang);       // 目标语言
        
        //对原文进行 url 编码
        string enc = HostUrlEncode(text);
        
        string parames = "fromCode=" + srcLang + "&toCode=" + dstLang + "&text=" + enc;
        // 构建请求的 url 地址
        string url = translateUrl + parames;

        string html = "";

        string requestResult = HostUrlGetString(url, userAgent);

        if (requestResult.empty()) {
            return "";
        }

        // 解析翻译结果
        ret = JsonParse(requestResult);

        if (ret.empty() || ret == "error_msg") {
            return "";
        }

        if (ret.length() >= 10) {
            if (ret.substr(0, 10) == "error_msg=") {
                return "";
            }
        }

        // 相同译文
        if (text == ret){
            if (srcLang == "zh" && dstLang == "cht"){
                // 简体 转 繁体 不进行任何处理
            } else if(srcLang == "cht" && dstLang == "zh"){
                // 繁体 转 简体 不进行任何处理
            } else{
                ret = "";// 那么忽略这个字幕
            }
        }

        if (!ret.empty() && ret != ""){
            srcLang = "UTF8";
            dstLang = "UTF8";
        }
    }
    return ret;
}


/** 支持的语言列表 */
array<string> langTable = {
    "zh-CN",//->zh
    "zh-TW",//->(简体转繁体)/zt
    "en",
    "ja",
    "kor",
    "fra",
    "spa",
    "th",
    "ara",
    "ru",
    "pt",
    "de",
    "it",
    "el",
    "nl",
    "pl",
    "bul",
    "est",
    "dan",
    "fin",
    "cs",
    "ro",
    "slo",
    "swe",
    "hu",
    "vie",
};

/** 获取支持语言 */
array<string>  GetLangTable(){
    return langTable;
}
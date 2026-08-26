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
int coolTime = 1300;//冷却时间，这里的单位是毫秒，1秒钟=1000毫秒，如果提示 error:54003, 那么就加大这个数字，建议一次加100
string userAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36";//这个是可选配置，一般不用修改！

//执行环境，请不要修改！
int NULL = 0;
int executeThreadId = NULL;//这个变量的命名是我的目标，不过，暂时没能实现!只是做了个还有小bug的临时替代方案
int nextExecuteTime = 0;//下次执行代码的时间
string translateUrl = "http://localhost:8989/api/translate?";//本地部署的翻译AI的地址
string statusUrl = "http://localhost:8989/api/status";//本地部署的翻译AI的状态地址


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
        string q = text;
        string enc = HostUrlEncode(q);
        
        string parames = "fromCode=" + srcLang + "&toCode=" + dstLang + "&text=" + enc;
        // 构建请求的 url 地址
        string url = translateUrl + parames;

        // 线程同步 - 独占锁
        acquireExclusiveLock();

        // 计算冷却时间，应百度翻译新版API要求，加入频率设定
        int tickCount = HostGetTickCount();
        int sleepTime = nextExecuteTime - tickCount;

        // 冷却处理
        if(sleepTime > 0){//如果冷却时间还没到，有需要休息的部分
            HostSleep(sleepTime);//那么就休息这些时间
        }

        string html = HostUrlGetString(url, userAgent);

        // 更新下次执行任务的时间
        nextExecuteTime = coolTime + HostGetTickCount();//上面 HostUrlGetString 需要时间执行，所以需要重新获取 TickCount

        // 线程同步 - 释放独占锁
        releaseExclusiveLock();

        // 解析翻译结果
        if(!html.empty()){// 如果成功取得 Html 内容
          ret = JsonParse(html);//那么解析这个 HTML 里面的 json 内容
        }

        // 翻译结果特殊处理
        if(text == ret){// 如果翻译后的译文，跟原文一致
            if(srcLang == "zh" && dstLang == "cht"){// 简体 转 繁体
                // 不进行任何处理
            }else if(srcLang == "cht" && dstLang == "zh"){// 繁体 转 简体
                // 不进行任何处理
            }else{
                ret = " ";// 那么忽略这个字幕
            }
        }

        if(ret.length() > 0){// 如果有翻译结果
            srcLang = "UTF8";
            dstLang = "UTF8";
        }
    }
    return ret;
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
    } else if (result == "ja"){//日语
        result = "jp";
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

/** 解析Json数据
 * @param json 服务器返回的Json字符串
 */
string JsonParse(string json){
    string ret = "";//返回值
    JsonReader reader;
    JsonValue root;
    
    if (reader.parse(json, root)){//如果成功解析了json内容
        if(root.isObject()){//要求是对象模式
            array<string> keys = root.getKeys();//获取json root对象中所有的key
            JsonValue message = root["message"];//取得翻译结果
            ret = message.asString();
            //查找是否存在错误
            JsonValue status = root["status"];
            if(status.isString() && status.asString() == "error"){//如果发生了错误
                ret = "error_msg=" + ret;
            }
        }
    } 
    return ret;
}


/** 上独占锁 
 * - 当前仅仅只是模拟版，还有 bug ,不过暂时可临时使用
 */
void acquireExclusiveLock(){
    int tickCount1 = HostGetTickCount();//取得第一个时刻
    HostSleep(1);
    int tickCount2 = HostGetTickCount();//取得第二个时刻
    /**
    注意：
    1、这是一个临时的方案
    2、因为我本地尝试：HostLoadLibrary("Kernel32.dll") 没能正常工作，所以才采用当前这个临时方案
    3、key 原本应该是唯一的，不然可能存在多个线程得到的是同一个tickCount。会导致多个线程同时执行，意味着这多个线程只能成功一个翻译，虽然已经做了部分防御，但是不能确保万一！
    4、当然，上方的触发的概率不高，不过确实存在这个bug。
    5、所以当前只能作为临时方案，有更好的方案时，必须替换掉
    */
    int key = tickCount1 << 16 + (tickCount2 & 0xFFFF);//两个时刻合并，使得多线程重复相同数字的概率下降，但还是有可能重复，当前这个算法，仅仅能作为临时的解决方案而已！

    while(executeThreadId != key){
        if(executeThreadId == NULL){//如果没其他任务在执行了
            executeThreadId = key;//尝试注册当前任务为执行任务
        }

        HostSleep(1);//休息下，看看有没有抢着注册的其他线程任务，或者等待正在执行的任务解除锁

        if(executeThreadId == key){//如果没被其他线程抢注册了
            HostSleep(1);//再次休息下
            if(executeThreadId == key){//二次确认，确保原子性
                break;//成功抢到执行权限，不必再等待了
            }
        }
    }
}

/** 释放独占锁 
 * - 当前仅仅只是模拟版，还有 bug ,不过暂时可临时使用
 */
void releaseExclusiveLock(){
    executeThreadId = NULL;//解除锁
}
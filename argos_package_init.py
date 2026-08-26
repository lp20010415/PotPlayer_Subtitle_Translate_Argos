
import argostranslate.package

""" 
请根据index.json(https://github.com/argosopentech/argospm-index/blob/main/index.json)增删语言包
from_code 是源语言代码
to_code 是目标语言代码
from_name 是源语言英文
to_name 是目标语言英文

ArgosAI，如果在上面没有找到直转，也支持跨语言翻译(例如: 中文转俄文，但实际上是中文转英文 英文转中文)，但是翻译质量会下降

"""

from_code = "en"
to_codes = [
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

available_packages = argostranslate.package.get_available_packages()
installed_packages = argostranslate.package.get_installed_packages()


# 下载和安装Argos Translate的语言包
def download_and_install_package(f_code, t_code):
    global available_packages, installed_packages


    if next(
        filter(lambda p: p.from_code == f_code and p.to_code == t_code, installed_packages), None
    ):
        print(f"{f_code} -> {t_code} 语言包已安装")
        return True

    # 查找匹配的语言包
    package_to_install = next(
        filter(lambda p: p.from_code == f_code and p.to_code == t_code, available_packages)
    )
    
    if package_to_install is not None:
        # 下载并安装语言包
        print(f"正在下载 {f_code} -> {t_code} 语言包...")
        argostranslate.package.install_from_path(package_to_install.download())
        installed_packages = argostranslate.package.get_installed_packages()
        print(f"{f_code} -> {t_code} 语言包安装成功！")
        return True
    else:
        return False

# 
# for t in to_codes:
#     download_and_install_package(from_code, t)
# 转英语
for t in to_codes:
    download_and_install_package(t, from_code)

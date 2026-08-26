import json

file_name = "index.json"

with open(file_name, "r") as f:
    datas = json.dumps(f.read())

supported_languages = []
for d in datas:
    print(d)

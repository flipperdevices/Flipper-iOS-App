#!/usr/bin/env python3
"""Запускать из корня репозитория. Сам находит папку с Flipper.xcodeproj."""
import re, pathlib, shutil, sys, os

proj = next(pathlib.Path(".").rglob("Flipper.xcodeproj"), None)
if proj is None:
    print("ERROR: Flipper.xcodeproj not found. Содержимое корня:")
    for p in sorted(pathlib.Path(".").iterdir()):
        print("  ", p)
    sys.exit(1)
base = proj.parent
print("Project found:", proj)

# 1. положить русский перевод в папку iOS
ios = base / "iOS"
if not ios.is_dir():
    print("ERROR: нет папки", ios); sys.exit(1)
dst = ios / "ru.lproj"
dst.mkdir(exist_ok=True)
shutil.copy(pathlib.Path(__file__).parent / "Localizable.strings", dst / "Localizable.strings")

# 2. склеить строки вида "a " + "b", чтобы SwiftUI мог их перевести
join = re.compile(r'"\s*\+\s*\n\s*"')
n = 0
for p in base.rglob("*.swift"):
    s = p.read_text(encoding="utf-8")
    t = join.sub("", s)
    if t != s:
        p.write_text(t, encoding="utf-8"); n += 1
print("joined in", n, "files")

# 3. добавить ru в список языков проекта
pb = proj / "project.pbxproj"
s = pb.read_text(encoding="utf-8")
if "\t\t\t\tru,\n" not in s:
    s = s.replace("knownRegions = (\n\t\t\t\ten,\n", "knownRegions = (\n\t\t\t\ten,\n\t\t\t\tru,\n", 1)
    pb.write_text(s, encoding="utf-8")
print("ru in knownRegions:", "\t\t\t\tru,\n" in s)

# 4. сообщить workflow путь к проекту
with open(os.environ.get("GITHUB_ENV", os.devnull), "a") as f:
    f.write("PROJ_PATH=%s\n" % proj)

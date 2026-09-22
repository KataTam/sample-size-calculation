"""Reject invalid UTF-8 and common broken typography in maintained source files."""
from pathlib import Path
import re
import subprocess

root = Path(__file__).resolve().parents[1]
paths = subprocess.check_output(["git", "ls-files", "--cached", "--others",
    "--exclude-standard", "-z"], cwd=root).decode("utf-8").split("\0")
text_types = {".md", ".Rmd", ".R", ".py", ".yml", ".cff", ".bib", ".css", ".Rproj", ".json", ".csv"}
broken = re.compile(r"[\ufffd]|\u00e2\u20ac|\u00c3[\u0080-\u00bf]|\u00c2\u00a0")
errors = []
count = 0
for name in sorted(set(filter(None, paths))):
    file = root / name
    if not file.is_file() or file.suffix not in text_types:
        continue
    try:
        text = file.read_bytes().decode("utf-8")
    except UnicodeDecodeError:
        errors.append(f"{name}: not UTF-8")
        continue
    count += 1
    for number, line in enumerate(text.splitlines(), 1):
        if broken.search(line):
            errors.append(f"{name}:{number}: possible broken text encoding")
if errors:
    raise SystemExit("\n".join(errors))
print(f"UTF-8 and typography checks passed for {count} source files.")

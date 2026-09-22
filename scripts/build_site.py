"""Assemble the tutorial, apps, readable supporting pages and source download."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import html
import json
import os
import re
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "_site"
if SITE.is_symlink() or SITE.resolve().parent != ROOT:
    raise RuntimeError("Unsafe site output path")
for required in ["docs/apps/index.html", "docs/book/index.html"]:
    if not (ROOT / required).is_file():
        raise RuntimeError(f"Build {required} first; see README.md")
# Rebuild into a fresh directory so removed resources cannot survive publication.
if SITE.exists():
    if os.name == "nt":
        subprocess.run(["powershell", "-NoProfile", "-Command",
            "Remove-Item -LiteralPath $env:SAMPLE_SIZE_SITE_OUTPUT -Recurse -Force"],
            env={**os.environ, "SAMPLE_SIZE_SITE_OUTPUT": str(SITE)}, check=True)
    else:
        shutil.rmtree(SITE)
shutil.copytree(ROOT / "docs/apps", SITE)
shutil.copytree(ROOT / "docs/book", SITE / "book")
folders = ["teaching", "case-studies", "student-materials", "documentation", "figures", "data"]
for folder in folders:
    shutil.copytree(ROOT / folder, SITE / folder)
for name in ["README.md", "CONTRIBUTING.md", "LICENSE", "LICENSE-code.md", "CITATION.cff"]:
    shutil.copy2(ROOT / name, SITE / name)
(SITE / "module").mkdir(exist_ok=True)
shutil.copy2(ROOT / "module/references.bib", SITE / "module/references.bib")
shutil.copy2(ROOT / "site/styles.css", SITE / "styles.css")
(SITE / ".nojekyll").touch()

pandoc = shutil.which("pandoc")
if not pandoc:
    pandoc = subprocess.check_output(["Rscript", "-e", "cat(rmarkdown::pandoc_exec())"],
        cwd=ROOT).decode().strip()

def page(source, target):
    title = next((line[2:].strip() for line in source.read_text(encoding="utf-8").splitlines()
                  if line.startswith("# ")), source.stem)
    css = os.path.relpath(SITE / "styles.css", target.parent).replace(os.sep, "/")
    subprocess.run([pandoc, str(source), "--from=gfm", "--to=html5", "--standalone",
        "--metadata", "pagetitle=" + title, "--css", css, "--mathjax", "--output", str(target)], check=True)
    text = target.read_text(encoding="utf-8")
    # Website readers get HTML; repository readers keep Markdown links.
    def web_link(match):
        target_url = match.group(1)
        parsed = urlsplit(html.unescape(target_url))
        if not parsed.scheme and not parsed.netloc and parsed.path.endswith(".md"):
            return 'href="' + target_url.replace(".md", ".html", 1) + '"'
        return match.group(0)
    text = re.sub(r'href="([^"]+)"', web_link, text)
    target.write_text(text, encoding="utf-8")

for folder in folders:
    for source in (ROOT / folder).rglob("*.md"):
        page(source, (SITE / source.relative_to(ROOT)).with_suffix(".html"))
page(ROOT / "site/index.md", SITE / "index.html")
page(ROOT / "README.md", SITE / "README.html")
page(ROOT / "CONTRIBUTING.md", SITE / "CONTRIBUTING.html")
page(ROOT / "LICENSE-code.md", SITE / "LICENSE-code.html")
# The book links to supporting Markdown in source; make those links readable online.
for target in (SITE / "book").glob("*.html"):
    text = target.read_text(encoding="utf-8")
    text = re.sub(r'(href="[^"]+?)\.md([#?][^"]*|)(")', r'\1.html\2\3', text)
    target.write_text(text, encoding="utf-8")

# Maintain old documentation and case-study website addresses after the source moves.
aliases = json.loads((ROOT / "site/legacy-paths.json").read_text(encoding="utf-8"))
base = "https://katatam.github.io/sample-size-calculation/"
for previous, current in aliases.items():
    old = SITE / previous
    old.parent.mkdir(parents=True, exist_ok=True)
    destination = base + current.removesuffix(".md") + ".html"
    old.write_text(f"This page has moved: [Open the current page]({destination}).\n", encoding="utf-8")
    relative = os.path.relpath(SITE / current, old.parent).replace(os.sep, "/").removesuffix(".md") + ".html"
    old.with_suffix(".html").write_text('<!doctype html><html lang="en"><meta charset="utf-8">'
        f'<meta http-equiv="refresh" content="0;url={html.escape(relative, quote=True)}">'
        f'<title>Page moved</title><a href="{html.escape(relative, quote=True)}">Open the current page</a></html>', encoding="utf-8")

paths = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode("utf-8").split("\0")
with zipfile.ZipFile(SITE / "sample-size-calculation-source.zip", "w", zipfile.ZIP_DEFLATED) as archive:
    for name in sorted(filter(None, paths)):
        file = ROOT / name
        if file.is_file() and not file.is_symlink():
            archive.write(file, f"sample-size-calculation/{name}")
shutil.copy2(SITE / "sample-size-calculation-source.zip", SITE / "sample-size-oer-source.zip")

# Validate local links and images in maintained pages, not third-party runtime internals.
errors = []
class LocalLinks(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key not in {"href", "src"} or not value:
                continue
            url = urlsplit(value)
            if url.scheme or url.netloc or not url.path:
                continue
            path = (SITE / unquote(url.path.lstrip("/"))) if url.path.startswith("/") else current_page.parent / unquote(url.path)
            if not path.exists():
                errors.append(f"{current_page.relative_to(SITE)}: {value}")
for current_page in SITE.rglob("*.html"):
    rel = current_page.relative_to(SITE)
    if rel.parts[0] in {"shinylive", "two_means", "two_proportions", "power_explorer", "dropout_adjustment"} or "libs" in rel.parts:
        continue
    LocalLinks().feed(current_page.read_text(encoding="utf-8"))
if errors:
    raise RuntimeError("Broken local website targets:\n" + "\n".join(sorted(set(errors))))
print(f"Website assembled and local links checked: {SITE}")

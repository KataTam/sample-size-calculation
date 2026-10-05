"""Assemble the tutorial, apps, readable supporting pages and source download."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import html
import json
import os
import re
import shutil
import stat
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
    def remove_readonly(function, path, error_info):
        error = error_info[1]
        if not isinstance(error, PermissionError):
            raise error
        resolved = Path(path).resolve()
        if resolved != SITE.resolve() and SITE.resolve() not in resolved.parents:
            raise RuntimeError("Unsafe cleanup target")
        os.chmod(path, stat.S_IWRITE | stat.S_IREAD)
        function(path)
    if os.name == "nt":
        shutil.rmtree(SITE, onerror=remove_readonly)
    else:
        shutil.rmtree(SITE)
shutil.copytree(ROOT / "docs/apps", SITE)
shutil.copytree(ROOT / "docs/book", SITE / "book")
# Only the full tutorial is downloadable; do not copy retired chapter artifacts.
retired = SITE / "book/downloads"
if retired.exists():
    if retired.resolve().parent != (SITE / "book").resolve():
        raise RuntimeError("Unsafe retired downloads path")
    shutil.rmtree(retired)
(SITE / "book/chapter-downloads.json").unlink(missing_ok=True)

folders = ["teaching", "case-studies", "student-materials", "documentation", "figures", "data"]
for folder in folders:
    shutil.copytree(ROOT / folder, SITE / folder)
for name in ["README.md", "CONTRIBUTING.md", "LICENSE", "LICENSE-code.md", "CITATION.cff"]:
    shutil.copy2(ROOT / name, SITE / name)
(SITE / "module").mkdir(exist_ok=True)
shutil.copy2(ROOT / "module/references.bib", SITE / "module/references.bib")
shutil.copy2(ROOT / "site/styles.css", SITE / "styles.css")
shutil.copy2(ROOT / "site/link-behavior.js", SITE / "link-behavior.js")
shutil.copytree(ROOT / "site/study", SITE / "study")
shutil.copytree(ROOT / "site/assumptions_report", SITE / "assumptions_report")
(SITE / ".nojekyll").touch()

# The lesson and apps use one registry, including the same seed and replications.
subprocess.run(["Rscript", "-e", 'source("R/teaching_cases.R"); '
    'jsonlite::write_json(teaching_cases(), "_site/teaching-cases.json", auto_unbox=TRUE, pretty=TRUE)'],
    cwd=ROOT, check=True)

pandoc = shutil.which("pandoc")
if not pandoc:
    pandoc = subprocess.check_output(["Rscript", "-e", "cat(rmarkdown::pandoc_exec())"],
        cwd=ROOT).decode().strip()

def page(source, target):
    title = next((line[2:].strip() for line in source.read_text(encoding="utf-8").splitlines()
                  if line.startswith("# ")), source.stem)
    title = re.sub(r"\s+\{#[^}]+\}\s*$", "", title)
    css = os.path.relpath(SITE / "styles.css", target.parent).replace(os.sep, "/")
    reader = "markdown" if source.name in {"glossary.md", "common-mistakes.md", "study-design-guide.md"} else "gfm"
    subprocess.run([pandoc, str(source), "--from=" + reader, "--to=html5", "--standalone",
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
page(ROOT / "site/apps.md", SITE / "apps.html")
page(ROOT / "README.md", SITE / "README.html")
page(ROOT / "CONTRIBUTING.md", SITE / "CONTRIBUTING.html")
page(ROOT / "LICENSE-code.md", SITE / "LICENSE-code.html")
# The book links to supporting Markdown in source; make those links readable online.
for target in (SITE / "book").glob("*.html"):
    text = target.read_text(encoding="utf-8")
    text = re.sub(r'(href="[^"]+?)\.md([#?][^"]*|)(")', r'\1.html\2\3', text)
    target.write_text(text, encoding="utf-8")

# Resolve case links to chapters without maintaining duplicate chapter filenames.
chapter_anchors = {}
class ChapterAnchors(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for key, value in attrs:
            if key == "id" and value:
                chapter_anchors.setdefault(value, str(chapter.relative_to(SITE)).replace("\\", "/") + "#" + value)
for chapter in sorted((SITE / "book").glob("*.html")):
    if chapter.name != "Sample_size_open_module.html":
        ChapterAnchors().feed(chapter.read_text(encoding="utf-8"))
(SITE / "chapter-anchors.json").write_text(json.dumps(chapter_anchors, indent=2), encoding="utf-8")

# The help sources also live inside the book. On their separate pages, chapter
# fragments must point back to the book while their own headings stay local.
for name in ["glossary", "common-mistakes", "study-design-guide"]:
    target = SITE / "student-materials" / (name + ".html")
    text = target.read_text(encoding="utf-8")
    local_ids = set(re.findall(r'\bid="([^"]+)"', text))
    def help_link(match):
        anchor = match.group(1)
        if anchor in local_ids or anchor not in chapter_anchors:
            return match.group(0)
        chapter_path, fragment = chapter_anchors[anchor].split("#", 1)
        relative = os.path.relpath(SITE / chapter_path, target.parent).replace(os.sep, "/")
        return 'href="' + relative + '#' + fragment + '"'
    text = re.sub(r'href="#([^"]+)"', help_link, text)
    target.write_text(text, encoding="utf-8")

cases = json.loads((SITE / "teaching-cases.json").read_text(encoding="utf-8"))
for case in cases.values():
    app = case.get("app")
    if not (SITE / app / "index.html").is_file():
        raise RuntimeError(f"Missing app for case {case['id']}: {app}")
    anchor = urlsplit(case.get("return_path", "")).fragment
    if anchor and anchor not in chapter_anchors:
        raise RuntimeError(f"Missing tutorial anchor for case {case['id']}: {anchor}")

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

paths = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=ROOT).decode("utf-8").split("\0")
with zipfile.ZipFile(SITE / "sample-size-calculation-source.zip", "w", zipfile.ZIP_DEFLATED) as archive:
    for name in sorted(set(filter(None, paths))):
        file = ROOT / name
        if file.is_file() and not file.is_symlink():
            archive.write(file, f"sample-size-calculation/{name}")
shutil.copy2(SITE / "sample-size-calculation-source.zip", SITE / "sample-size-oer-source.zip")

# Apply new-tab resource links to maintained HTML, including the standalone book.
# Native chapter/toolbar navigation and interactive disclosure controls stay local.
class NewTabLinks(HTMLParser):
    navigation_classes = {"book-summary", "book-header", "navigation-prev", "navigation-next", "tocify", "toc"}
    control_classes = {"anchor-section", "anchor", "shiny-download-link", "shiny-tab-input", "action-button", "dropdown-toggle", "toggle-dropdown"}
    void_elements = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}

    def __init__(self, source):
        super().__init__()
        self.stack, self.replacements = [], []
        self.line_offsets = [0]
        for match in re.finditer("\n", source):
            self.line_offsets.append(match.end())

    def handle_starttag(self, tag, attrs):
        attr = dict(attrs)
        classes = set((attr.get("class") or "").split())
        navigation = bool(classes & self.navigation_classes or attr.get("id") == "TOC" or attr.get("data-link-navigation") == "same-tab")
        inside_navigation = navigation or any(item[1] for item in self.stack)
        href = (attr.get("href") or "").strip()
        control = bool(classes & self.control_classes or attr.get("role") == "button" or any(key in attr for key in ["download", "data-question", "data-toggle", "data-bs-toggle"]))
        if tag == "a" and href and href != "#" and not re.match(r"(?:javascript|mailto|tel|data|blob):", href, re.I) and not inside_navigation and not control:
            original = self.get_starttag_text()
            updated = re.sub(r'\s+target\s*=\s*(?:"[^"]*"|\x27[^\x27]*\x27|[^\s>]+)', "", original, flags=re.I)
            updated = re.sub(r'\s+rel\s*=\s*(?:"[^"]*"|\x27[^\x27]*\x27|[^\s>]+)', "", updated, flags=re.I)
            rel = " ".join(dict.fromkeys((attr.get("rel") or "").split() + ["noopener"]))
            updated = updated[:-1] + ' target="_blank" rel="' + html.escape(rel, quote=True) + '">'
            line, column = self.getpos()
            self.replacements.append((self.line_offsets[line - 1] + column, original, updated))
        if tag not in self.void_elements:
            self.stack.append((tag, navigation))

    def handle_endtag(self, tag):
        for index in range(len(self.stack) - 1, -1, -1):
            if self.stack[index][0] == tag:
                del self.stack[index:]
                break

for target in SITE.rglob("*.html"):
    rel = target.relative_to(SITE)
    if rel.parts[0] in {"shinylive", "two_means", "two_proportions", "power_explorer", "dropout_adjustment", "prevalence_precision", "sampling_distributions"} or "libs" in rel.parts:
        continue
    text = target.read_text(encoding="utf-8")
    # Same-project links also work in the author's private localhost preview.
    def local_project_link(match):
        url = urlsplit(html.unescape(match.group(1)))
        locations = [urlsplit(base), urlsplit("http://127.0.0.1:8769/")]
        location = next((candidate for candidate in locations
            if url.netloc.lower() == candidate.netloc.lower() and
            (url.path == candidate.path.rstrip("/") or url.path.startswith(candidate.path.rstrip("/") + "/"))), None)
        if location is None:
            return match.group(0)
        prefix = location.path.rstrip("/")
        path = SITE / url.path[len(prefix):].lstrip("/")
        relative = os.path.relpath(path, target.parent).replace(os.sep, "/")
        if url.path.endswith("/") or url.path == prefix:
            relative += "/"
        if url.query:
            relative += "?" + url.query
        if url.fragment:
            relative += "#" + url.fragment
        return 'href="' + html.escape(relative, quote=True) + '"'
    text = re.sub(r'href="([^"]+)"', local_project_link, text)
    parser = NewTabLinks(text)
    parser.feed(text)
    for offset, original, updated in reversed(parser.replacements):
        text = text[:offset] + updated + text[offset + len(original):]
    script_path = os.path.relpath(SITE / "link-behavior.js", target.parent).replace(os.sep, "/")
    script = '<script src="' + script_path + '"></script>'
    text = text.replace("</body>", script + "\n</body>") if "</body>" in text else text + script
    target.write_text(text, encoding="utf-8")

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
    if rel.parts[0] in {"shinylive", "two_means", "two_proportions", "power_explorer", "dropout_adjustment", "prevalence_precision", "sampling_distributions"} or "libs" in rel.parts:
        continue
    LocalLinks().feed(current_page.read_text(encoding="utf-8"))
if errors:
    raise RuntimeError("Broken local website targets:\n" + "\n".join(sorted(set(errors))))
print(f"Website assembled and local links checked: {SITE}")

"""Assemble the generated book, apps and reusable sources for GitHub Pages."""
from pathlib import Path
import html
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
if SITE.exists():
    shutil.rmtree(SITE)
shutil.copytree(ROOT / "docs/apps", SITE)
shutil.copytree(ROOT / "docs/book", SITE / "book")
for folder in ["teaching", "cases", "figures", "data", "intro_review"]:
    shutil.copytree(ROOT / folder, SITE / folder)
for name in ["README.md", "REFERENCES.md", "LICENSE", "LICENSE-code.md",
             "CITATION.cff", "THIRD_PARTY_NOTICES.md", "REUSE_AND_CITATION.md",
             "OER_METADATA.md"]:
    shutil.copy2(ROOT / name, SITE / name)
(SITE / ".nojekyll").touch()

# Use tracked paths so caches, shell histories and unpublished local files stay out.
paths = subprocess.check_output(
    ["git", "ls-files", "-z"], cwd=ROOT).decode("utf-8").split("\0")
with zipfile.ZipFile(SITE / "sample-size-calculation-source.zip", "w",
                     zipfile.ZIP_DEFLATED) as archive:
    for name in sorted(filter(None, paths)):
        file = ROOT / name
        if file.is_file() and not file.is_symlink():
            archive.write(file, f"sample-size-calculation/{name}")
shutil.copy2(SITE / "sample-size-calculation-source.zip",
             SITE / "sample-size-oer-source.zip")

links = "\n".join(
    f'<li><a href="{html.escape(file.name, quote=True)}">{html.escape(file.name)}</a></li>'
    for file in sorted((SITE / "intro_review").iterdir()) if file.is_file())
(SITE / "intro_review/index.html").write_text(
    '<!doctype html><html lang="en"><meta charset="utf-8">'
    '<meta name="viewport" content="width=device-width, initial-scale=1">'
    '<title>Collaborator review materials</title><h1>Collaborator review materials</h1>'
    f'<ul>{links}</ul><p><a href="../book/">Read the tutorial</a></p></html>',
    encoding="utf-8")

index = SITE / "index.html"
text = index.read_text(encoding="utf-8")
text = text.replace("sample-size-oer-source.zip", "sample-size-calculation-source.zip")
text = text.replace("Sample Size Calculation Apps", "Sample Size Calculation")
text = text.replace("</body>", '<p><a href="intro_review/">Collaborator review materials</a>'
    ' · <a href="https://github.com/KataTam/sample-size-calculation">Source and contributions</a></p></body>')
index.write_text(text, encoding="utf-8")
print(f"Website assembled at {SITE}")

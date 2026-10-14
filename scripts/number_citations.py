"""Compact parenthetical APA citations; retain narrative citations and source text.

Numbers follow the alphabetical bibliography, consistently across all chapters.
This is a presentation option, not a claim to use a numbered journal style.
"""
import html
import re
from pathlib import Path


def number_citations(folder):
    reference = (folder / "references.html").read_text(encoding="utf-8")
    ids = re.findall(r'<div id="(ref-[^"]+)" class="csl-entry"', reference)
    if not ids or len(ids) != len(set(ids)):
        raise ValueError("Expected unique bibliography entries")
    numbers = {key: i + 1 for i, key in enumerate(ids)}
    for file in folder.glob("*.html"):
        text = file.read_text(encoding="utf-8")
        def compact(match):
            body = match.group(1)
            if not body.lstrip().startswith("(") or not body.rstrip().endswith(")"):
                return match.group(0)
            def link(m):
                attrs, target, label = m.groups()
                key = target.split("#")[-1]
                if key not in numbers:
                    return m.group(0)
                short = html.unescape(re.sub('<[^>]+>', '', label))
                accessible = html.escape(f"Reference {numbers[key]}: {short}", quote=True)
                return (f'<a {attrs}href="{target}" data-citation-label="{html.escape(short, quote=True)}" '
                        f'aria-label="{accessible}">{numbers[key]}</a>')
            body = re.sub(r'<a ([^>]*?)href="([^"]*#ref-[^"]+)"[^>]*>(.*?)</a>', link, body, flags=re.S)
            return '<span class="citation citation-numbered">' + body + '</span>'
        text = re.sub(r'<span class="citation">(.*?)</span>', compact, text, flags=re.S)
        for key, number in numbers.items():
            opening = f'<div id="{key}" class="csl-entry"'
            text = re.sub(re.escape(opening) + r'([^>]*>)',
                lambda m, n=number: opening + m.group(1) + f'<span class="reference-number">[{n}]</span> ', text)
        file.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    import sys
    number_citations(Path(sys.argv[1]))

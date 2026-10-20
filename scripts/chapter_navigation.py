"""Add consistent reading navigation after the complete chapter content using Bookdown's own chapter order and route classes."""
from pathlib import Path
from html import escape, unescape
import re


def add_chapter_navigation(book):
    chapters = {}
    for path in Path(book).glob('*.html'):
        source = path.read_text(encoding='utf-8')
        if 'class="book-summary"' not in source:
            continue
        level = re.search(r'<div[^>]+class="([^"]*\blevel1\b[^"]*)"', source)
        heading = re.search(r'<h1[^>]*>(.*?)</h1>', source[level.end():], re.S) if level else None
        next_link = re.search(r'<link rel="next" href="([^"]+)"', source)
        if not heading or not level:
            continue
        title = unescape(re.sub(r'<[^>]+>', '', heading.group(1))).strip()
        chapters[path.name] = dict(path=path, source=source, title=title,
            core='core-heading' in level.group(1), advanced='advanced-heading' in level.group(1),
            next=next_link.group(1) if next_link else None)
    for name, chapter in chapters.items():
        links = []
        previous = re.search(r'<link rel="prev" href="([^"]+)"', chapter['source'])
        for direction, destination, arrow in [('prev', previous.group(1) if previous else None, '&#8592;'), ('next', chapter['next'], '&#8594;')]:
            if destination:
                label = ('Previous chapter: ' if direction == 'prev' else 'Next chapter: ') + chapters[destination]['title']
                links.append(f'<a class="chapter-arrow chapter-arrow-{direction}" href="{escape(destination)}" aria-label="{escape(label)}" title="{escape(label)}"><span aria-hidden="true">{arrow}</span></a>')
        nav = '<nav class="chapter-end-nav" aria-label="Chapter navigation" data-link-navigation="same-tab">' + ''.join(links) + '</nav>\n'
        source = chapter['source']
        if source.count('</section>') != 1:
            raise ValueError(f'Expected one chapter content section in {name}')
        # Remove older forward chapter shortcuts so there is one consistent control.
        later, cursor = set(), chapter['next']
        while cursor and cursor not in later:
            later.add(cursor)
            cursor = chapters[cursor]['next']
        def keep_section_shortcut(match):
            destination = re.search(r'href="([^"#]+)', match.group(0))
            return '' if destination and destination.group(1) in later else match.group(0)
        source = re.sub(r'<div class="core-next">.*?</div>', keep_section_shortcut, source, flags=re.S)
        position = source.index('</section>')
        source = source[:position] + nav + source[position:]
        chapter['path'].write_text(source, encoding='utf-8')

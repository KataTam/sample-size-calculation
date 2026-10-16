"""Add consistent reading navigation before the closing chapter material using Bookdown's own chapter order and route classes."""
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
        next_name = chapter['next']
        if next_name:
            following = chapters[next_name]
            route = ' (advanced)' if following['advanced'] else ' (core)' if following['core'] else ''
            links.append(f'<a href="{escape(next_name)}">Next chapter{route}: {escape(following["title"])}</a>')
            if chapter['advanced'] or following['advanced']:
                core_name, visited = next_name, set()
                while core_name and not chapters[core_name]['core']:
                    if core_name in visited:
                        raise ValueError('Circular chapter navigation')
                    visited.add(core_name)
                    core_name = chapters[core_name]['next']
                if core_name and core_name != next_name:
                    links.append(f'<a href="{escape(core_name)}">Continue with the next core chapter: {escape(chapters[core_name]["title"])}</a>')
        else:
            links.append('<a href="index.html">Return to the tutorial overview</a>')
        nav = '<nav class="chapter-end-nav" aria-label="Continue reading" data-link-navigation="same-tab">' + ''.join(links) + '</nav>\n'
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
        recap = source.find('<div class="chapter-recap">')
        if recap >= 0:
            position = recap
        else:
            sections = list(re.finditer(r'<div[^>]+class="[^"\n]*\bsection level2\b[^"\n]*"[^>]*>', source))
            if not sections:
                raise ValueError(f'No closing chapter section in {name}')
            position = sections[-1].start()
        source = source[:position] + nav + source[position:]
        chapter['path'].write_text(source, encoding='utf-8')

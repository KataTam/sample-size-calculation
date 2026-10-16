"""Add page-end navigation using Bookdown's own chapter order and route classes."""
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
        nav = '<nav class="chapter-end-nav" aria-label="Continue reading" data-link-navigation="same-tab"><ul>' + ''.join('<li>'+link+'</li>' for link in links) + '</ul></nav>\n'
        source = chapter['source']
        if source.count('</section>') != 1:
            raise ValueError(f'Expected one chapter content section in {name}')
        chapter['path'].write_text(source.replace('</section>', nav+'</section>', 1), encoding='utf-8')

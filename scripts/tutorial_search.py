"""Index all chapter text by heading, including collapsed explanations."""
from html.parser import HTMLParser
from pathlib import Path
import json
import re


class ChapterParser(HTMLParser):
    def __init__(self, filename):
        super().__init__()
        self.filename = filename
        self.active = False
        self.stack = []
        self.heading = None
        self.chapter = ''
        self.section = ''
        self.entries = []
        self.current = None
        self.ignored = []

    def handle_starttag(self, tag, attrs):
        if tag in ('script', 'style', 'template'):
            self.ignored.append(tag)
        if self.ignored:
            return
        attrs = dict(attrs)
        if tag == 'section' and 'normal' in attrs.get('class', '').split():
            self.active = True
        if not self.active or self.ignored:
            return
        if tag in ('div', 'details'):
            self.stack.append((tag, attrs.get('id', '')))
        if tag in ('h1', 'h2', 'h3', 'h4', 'summary'):
            self.heading = [tag, [], next((i for _, i in reversed(self.stack) if i), '')]

    def handle_data(self, data):
        if not self.active or self.ignored:
            return
        if self.heading is not None:
            self.heading[1].append(data)
        elif self.current:
            self.current['parts'].append(data)

    def handle_endtag(self, tag):
        if self.ignored:
            if tag == self.ignored[-1]:
                self.ignored.pop()
            return
        if not self.active:
            return
        if self.heading is not None and tag == self.heading[0]:
            kind, text, anchor = self.heading
            title = ' '.join(''.join(text).split())
            if kind == 'h1':
                self.chapter = title
            if kind in ('h2', 'h3', 'h4'):
                self.section = title
            if kind == 'summary' and self.section:
                title = self.section + ' — ' + title
            self.current = dict(chapter=self.chapter, section=title,
                                url=self.filename + ('#' + anchor if anchor else ''), parts=[])
            self.entries.append(self.current)
            self.heading = None
        if tag in ('div', 'details') and self.stack:
            self.stack.pop()
        if tag == 'section':
            self.active = False


def build_tutorial_search(book, script):
    entries = []
    for path in sorted(Path(book).glob('*.html')):
        source = path.read_text(encoding='utf-8')
        if 'class="book-summary"' not in source:
            continue
        # Navigation is excluded from searchable teaching content.
        content = source.split('<nav class="chapter-end-nav"')[0] + '</section>'
        parser = ChapterParser(path.name)
        parser.feed(content)
        for entry in parser.entries:
            entry['text'] = ' '.join(' '.join(entry.pop('parts')).split())
            entries.append(entry)
        source = source.replace('</body>', '<script src="tutorial-search.js"></script>\n</body>')
        path.write_text(source, encoding='utf-8')
    def chapter_order(entry):
        number = re.match(r'(?:Chapter\s+)?(\d+)\b', entry['chapter'])
        return int(number[1]) if number else 0
    entries.sort(key=chapter_order)
    (Path(book) / 'tutorial-search-index.json').write_text(json.dumps(entries, ensure_ascii=False), encoding='utf-8')
    (Path(book) / 'tutorial-search.js').write_text(Path(script).read_text(encoding='utf-8'), encoding='utf-8')

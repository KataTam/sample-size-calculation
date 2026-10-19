"""Build simple Anki packages and Quizlet text imports from the maintained cards.

Original software: MIT. Card content: CC BY-SA 4.0.
Install scripts/flashcard-requirements.txt before running.
"""
from collections import Counter
from contextlib import closing
from html import escape
import json
from pathlib import Path
import sqlite3
import tempfile
from urllib.parse import urlsplit, unquote
import zipfile

import genanki

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'student-materials' / 'flashcards'
MODEL_ID = 2026101901
ROOT_ID, CORE_ID, ADVANCED_ID = 2026101902, 2026101903, 2026101904
BASE = 'https://katatam.github.io/sample-size-calculation/book/'
LICENSE = 'https://creativecommons.org/licenses/by-sa/4.0/'


def build():
    data = json.loads((ROOT / 'data/flashcards.json').read_text(encoding='utf-8'))
    cards = data['cards']
    assert len({c['id'] for c in cards}) == len(cards), 'Duplicate card IDs'
    assert len({c['front'].casefold() for c in cards}) == len(cards), 'Duplicate questions'
    for c in cards:
        assert c['level'] in ('core', 'advanced')
        assert all(c[k].strip() and not any(x in c[k] for x in '\t\r\n')
                   for k in ('id', 'front', 'back', 'source'))
        assert c['source'].startswith(BASE)
        # Check explanations against the rendered book, before publishing a deck.
        url = urlsplit(c['source'])
        page = ROOT / 'docs/book' / Path(url.path).name
        assert page.is_file(), f"Missing explanation for {c['id']}: {page}"
        if url.fragment:
            assert 'id="' + unquote(url.fragment) + '"' in page.read_text(encoding='utf-8'), c['source']

    OUT.mkdir(parents=True, exist_ok=True)
    model = genanki.Model(
        MODEL_ID, 'Sample size tutorial - question and answer',
        fields=[{'name': n} for n in ('CardID', 'Question', 'Answer', 'Source', 'Level')],
        sort_field_index=1,
        templates=[{
            'name': 'Question and answer',
            'qfmt': '<div class="level {{Level}}">{{Level}}</div><div class="question">{{Question}}</div>',
            'afmt': '{{FrontSide}}<hr id="answer"><div class="answer">{{Answer}}</div>'
                    '<div class="source"><a href="{{Source}}">Explanation in the tutorial</a>'
                    '<br>Katalin Tamási · <a href="' + LICENSE + '">CC BY-SA 4.0</a></div>',
        }],
        css='.card { font-family:Arial,sans-serif; font-size:21px; text-align:left; '
            'line-height:1.5; color:#243746; background:#fff; max-width:750px; margin:24px auto; padding:0 18px; }'
            '.level { display:inline-block; font-size:13px; padding:3px 9px; border-radius:4px; margin-bottom:15px; text-transform:capitalize; }'
            '.core { background:#dbe9fb; color:#173d5b; } .advanced { background:#e7dcf6; color:#49316d; }'
            '.question { font-size:23px; } #answer { border:0; border-top:1px solid #aab7c2; margin:22px 0; }'
            '.source { font-size:13px; margin-top:24px; color:#526574; } a { color:#17658a; }'
            '.nightMode.card { background:#20252c; color:#eef3fa; } .nightMode .source { color:#bdc9d3; }'
            '.nightMode a { color:#9ccfff; }',
    )
    description = ('Simple question-and-answer cards accompanying Katalin Tamási\'s sample size tutorial. '
                   'All numerical cases are hypothetical teaching examples. '
                   '<a href="' + BASE + '">Tutorial</a>. Teaching content: '
                   '<a href="' + LICENSE + '">CC BY-SA 4.0</a>. Original build software: '
                   '<a href="https://opensource.org/license/mit">MIT</a>. '
                   'Study Core for the core route; select Sample size tutorial to study both subdecks. '
                   'Shared stable note IDs preserve existing core cards when adding Advanced.')
    packages = {}
    for stem, levels in [('sample-size-core', {'core'}),
                         ('sample-size-core-and-advanced', {'core', 'advanced'})]:
        chosen = [c for c in cards if c['level'] in levels]
        decks = {'root': genanki.Deck(ROOT_ID, 'Sample size tutorial', description=description),
                 'core': genanki.Deck(CORE_ID, 'Sample size tutorial::Core', description=description)}
        if 'advanced' in levels:
            decks['advanced'] = genanki.Deck(ADVANCED_ID, 'Sample size tutorial::Advanced', description=description)
        for c in chosen:
            note = genanki.Note(model=model,
                               fields=[c['id'], escape(c['front']), escape(c['back']), c['source'], c['level']],
                               guid=genanki.guid_for('katatam-sample-size-flashcards-v1', c['id']),
                               tags=['sample_size_tutorial', c['level']],
                               due=cards.index(c) + 1)
            decks[c['level']].add_note(note)
        genanki.Package(list(decks.values())).write_to_file(str(OUT / (stem + '.apkg')))
        # Quizlet import requires exactly two columns with no heading row.
        # Keep attribution and a source link with each answer when cards are reused.
        text = '\n'.join(c['front'] + '\t' + c['back'] + ' [Katalin Tamási; CC BY-SA 4.0: '
                         + LICENSE + '; tutorial: ' + c['source'] + ']' for c in chosen) + '\n'
        (OUT / (stem + '-quizlet.txt')).write_text(text, encoding='utf-8')
        assert all(len(line.split('\t')) == 2 for line in text.splitlines())
        packages[stem] = validate_package(OUT / (stem + '.apkg'), chosen)
    core = packages['sample-size-core']
    combined = packages['sample-size-core-and-advanced']
    assert core.items() <= combined.items(), 'Core notes must retain GUIDs and content in the combined package'
    review = ['# Sample size flashcards: all cards', '',
              'These cards summarize the tutorial. Numerical examples are hypothetical. '
              'Each answer links to its explanation; the linked chapter supplies the supporting references.', '',
              '[Downloads and import instructions](index.md)', '',
              'Katalin Tamási. Teaching content: [CC BY-SA 4.0](' + LICENSE + '). '
              'Original build software: [MIT](https://opensource.org/license/mit).', '']
    counts = Counter(c['level'] for c in cards)
    for level in ('core', 'advanced'):
        review += ['## ' + level.capitalize() + ' (' + str(counts[level]) + ' cards)', '']
        for c in cards:
            review += ['### ' + c['id'] + '. ' + c['front'], '', c['back'], '',
                       '[Explanation in the tutorial](' + c['source'] + ')', '']
    (OUT / 'cards.md').write_text('\n'.join(review), encoding='utf-8')
    print(f"Built and checked {len(cards)} cards: {counts['core']} core and {counts['advanced']} advanced; two Anki and two Quizlet imports.")


def validate_package(path, expected):
    with tempfile.TemporaryDirectory() as tmp:
        with zipfile.ZipFile(path) as z:
            assert z.testzip() is None
            db = Path(tmp) / 'collection.anki2'
            db.write_bytes(z.read('collection.anki2'))
            assert json.loads(z.read('media')) == {}
        with closing(sqlite3.connect(db)) as conn:
            assert conn.execute('pragma integrity_check').fetchone()[0] == 'ok'
            notes = conn.execute('select guid, flds from notes').fetchall()
            assert len(notes) == len(expected)
            assert conn.execute('select count(*) from cards').fetchone()[0] == len(expected)
            assert conn.execute('select count(*) from revlog').fetchone()[0] == 0
            assert all(len(fields.split('\x1f')) == 5 for _, fields in notes)
            assert {fields.split('\x1f')[0] for _, fields in notes} == {c['id'] for c in expected}
            assert conn.execute('select count(*) from cards where type != 0 or queue != 0').fetchone()[0] == 0
            return dict(notes)


if __name__ == '__main__':
    build()

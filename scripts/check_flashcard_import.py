"""Optional integration check using Anki's official Python package.

Run with anki installed (validated with 26.9.3). Uses temporary collections only.
Original software: MIT.
"""
from html import escape
import json
from pathlib import Path
import tempfile

from anki.collection import Collection, ImportAnkiPackageRequest
from anki.import_export_pb2 import ImportAnkiPackageOptions

ROOT = Path(__file__).resolve().parents[1]
FILES = ROOT / 'student-materials/flashcards'
QA = ROOT / 'build/flashcard-checks'
QA.mkdir(parents=True, exist_ok=True)
expected = json.loads((ROOT / 'data/flashcards.json').read_text(encoding='utf-8'))['cards']
core_count = sum(c['level'] == 'core' for c in expected)


def load(col, stem):
    col.import_anki_package(ImportAnkiPackageRequest(
        package_path=str(FILES / (stem + '.apkg')),
        options=ImportAnkiPackageOptions(with_scheduling=False, with_deck_configs=False)))


with tempfile.TemporaryDirectory(prefix='anki-', dir=QA) as tmp:
    col = Collection(str(Path(tmp) / 'collection.anki2'))
    try:
        load(col, 'sample-size-core')
        assert col.db.scalar('select count(*) from notes') == core_count
        assert col.db.scalar('select count(*) from cards') == core_count
        cid = col.db.scalar('select id from cards order by id limit 1')
        card = col.get_card(cid)
        card.type = 2
        card.queue = 2
        card.ivl = 7
        card.due = 42
        card.reps = 3
        col.update_card(card)
        before = col.db.first('select id, nid, type, queue, ivl, due, reps from cards where id=?', cid)
        load(col, 'sample-size-core-and-advanced')
        assert col.db.scalar('select count(*) from notes') == len(expected)
        assert col.db.scalar('select count(*) from cards') == len(expected)
        assert col.db.first('select id, nid, type, queue, ivl, due, reps from cards where id=?', cid) == before
        load(col, 'sample-size-core-and-advanced')
        assert col.db.scalar('select count(*) from cards') == len(expected)
        load(col, 'sample-size-core')
        assert col.db.scalar('select count(*) from cards') == len(expected)
        assert col.db.first('select id, nid, type, queue, ivl, due, reps from cards where id=?', cid) == before
        assert len(col.find_cards('tag:core')) == core_count
        assert len(col.find_cards('tag:advanced')) == len(expected) - core_count
        examples = []
        for c in expected:
            matches = col.find_cards('CardID:' + c['id'])
            assert len(matches) == 1, c['id']
            card = col.get_card(matches[0])
            q, a = card.question(), card.answer()
            assert escape(c['front']) in q
            assert escape(c['back']) in a
            assert c['source'] in a
            assert '{{' not in q + a, c['id']
            if c['id'] in ('C001', 'C049', 'A014', 'A050'):
                examples.append('<section>' + a + '</section>')
        (QA / 'rendered-cards.html').write_text('<!doctype html><html lang="en"><meta charset="utf-8">'
            '<title>Anki-rendered flashcard checks</title><style>body{font-family:Arial;max-width:750px;margin:20px auto;padding:20px}'
            'section{border:1px solid #adb7c5;padding:24px;margin:25px 0;font-size:21px;line-height:1.5}'
            '.level,.source{font-size:13px}.source{margin-top:20px}.question{font-size:23px}</style>'
            + ''.join(examples) + '</html>', encoding='utf-8')
    finally:
        col.close()
with tempfile.TemporaryDirectory(prefix='anki-full-', dir=QA) as tmp:
    col = Collection(str(Path(tmp) / 'collection.anki2'))
    try:
        load(col, 'sample-size-core-and-advanced')
        assert col.db.scalar('select count(*) from notes') == len(expected)
        assert col.db.scalar('select count(*) from cards') == len(expected)
    finally:
        col.close()
print(f'Anki import checks passed: {core_count} core, {len(expected)} combined; no duplicates; existing core scheduling preserved; all fronts and backs render.')

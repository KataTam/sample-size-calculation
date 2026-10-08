"""Verify contents links and page labels in the completed book PDF."""
from pathlib import Path
import json
from pypdf import PdfReader
root=Path(__file__).resolve().parents[1]
r=PdfReader(root/'output/pdf/Sample_size_open_module.pdf')
headings=json.loads((root/'build/pdf/headings.json').read_text(encoding='utf-8'))
labels=r.page_labels
offset=labels.index('1')
assert offset>=2
assert 'Contents' in r.pages[1].extract_text()
links=[a.get_object() for page in r.pages[1:offset] for a in page.get('/Annots',[]) if a.get_object().get('/Subtype')=='/Link']
assert len(links)==len(headings),(len(links),len(headings))
refs={page.indirect_reference.idnum:i for i,page in enumerate(r.pages)}
for link in links:
 dest=link.get('/Dest') or link['/A']['/D']
 assert refs[dest[0].idnum]>=offset
assert len(r.outline)>=13
assert 'Welcome' in r.pages[offset].extract_text()
assert len(r.pages)>offset+20
print(f'PDF checks passed: {len(links)} contents links, Roman front matter, body page 1 and chapter bookmarks.')

"""Verify contents links and page labels in the completed book PDF."""
from pathlib import Path
import json
import re
import sys
from pypdf import PdfReader
from collections import Counter
from urllib.parse import unquote, urlsplit
root=Path(__file__).resolve().parents[1]
r=PdfReader(Path(sys.argv[1]) if len(sys.argv)>1 else root/'output/pdf/Sample_size_open_module.pdf')
headings=json.loads((root/'build/pdf/headings.json').read_text(encoding='utf-8'))
assert '/StructTreeRoot' in r.trailer['/Root'], 'PDF lost its accessibility structure'
assert r.trailer['/Root'].get('/Lang') == 'en-US'
labels=r.page_labels
offset=labels.index('1')
assert offset>=2
assert 'Contents' in r.pages[1].extract_text()
links=[a.get_object() for page in r.pages[1:offset] for a in page.get('/Annots',[]) if a.get_object().get('/Subtype')=='/Link']
assert len(links)==len(headings),(len(links),len(headings))
refs={page.indirect_reference.idnum:i for i,page in enumerate(r.pages)}
target_pages=[]
for link in links:
 dest=link.get('/Dest') or link['/A']['/D']
 assert refs[dest[0].idnum]>=offset
 target_pages.append(refs[dest[0].idnum])
# Repeated subsection titles must resolve within their own chapter, including
# both the clickable contents entries and the PDF's sidebar bookmarks.
chapter_indices=[i for i,h in enumerate(headings) if h['level']==0]
compact=lambda text: re.sub(r'\s+', '', text)
for pos,start in enumerate(chapter_indices):
 end=chapter_indices[pos+1] if pos+1<len(chapter_indices) else len(headings)
 first=target_pages[start]
 last=target_pages[end] if end<len(headings) else len(r.pages)
 for i in range(start,end):
  target=target_pages[i]
  assert first<=target<last, f"Wrong chapter destination: {headings[i]['title']} -> {target}"
  assert compact(headings[i]['title']) in compact(r.pages[target].extract_text()), f"Heading absent at destination: {headings[i]['title']}"
bookmarks=[]
def collect_bookmarks(items):
 for item in items:
  if isinstance(item,list): collect_bookmarks(item)
  else: bookmarks.append(item)
collect_bookmarks(r.outline)
assert len(bookmarks)==len(headings)+2
for heading,target,bookmark in zip(headings,target_pages,bookmarks[2:]):
 assert compact(bookmark.title)==compact(heading['title'])
 assert r.get_destination_page_number(bookmark)==target
assert 'Draft version' in r.pages[0].extract_text()
assert len(r.outline)>=13
assert 'Welcome' in r.pages[offset].extract_text()
assert len(r.pages)>offset+20
print(f'PDF checks passed: {len(links)} contents links and matching bookmarks resolve to their headings within the correct chapters; draft title, Roman front matter and body page 1 verified.')

# Check body links against the intended HTML content, not just the existence of
# a named PDF destination. This includes definitions anchored inside paragraphs.
audit=json.loads((root/'build/pdf/internal-links.json').read_text(encoding='utf-8'))
targets={target['id']:target for target in audit['targets']}
semantic=lambda text: re.sub(r'[^a-z0-9]', '', text.lower())
raw_page_text=[page.extract_text() for page in r.pages]
assert not any(re.search(r'<U\+[0-9A-Fa-f]{4,6}>', text) for text in raw_page_text), 'PDF contains an escaped Unicode label'
roadmap_pages=[text for text in raw_page_text if 'Roadmap' in text and 'Flashcards' in text]
assert len(roadmap_pages)==1, 'The roadmap must remain legible text on one page'
for label in ['Chapters 1-4', 'Chapters 5-8', 'Flashcards: review and recall']:
 assert label in roadmap_pages[0].replace(chr(0x2013), '-'), f'Missing or damaged roadmap label: {label}'
page_text=[semantic(text) for text in raw_page_text]
chapter_bounds={}
for pos,start in enumerate(chapter_indices):
 end=chapter_indices[pos+1] if pos+1<len(chapter_indices) else len(headings)
 chapter_bounds[compact(headings[start]['title'])]=(target_pages[start],target_pages[end] if end<len(headings) else len(r.pages))
for key,target in targets.items():
 destination=r.named_destinations.get('/'+key)
 assert destination is not None, f'Missing internal PDF destination: #{key}'
 page=r.get_destination_page_number(destination)
 first,last=chapter_bounds[compact(target['chapter'])]
 assert first<=page<last, f'#{key} points outside its chapter'
 expected=semantic((target.get('referenceNumber','') if target['kind']=='reference' else '')+target['text'])
 assert expected and expected in page_text[page], f'#{key} points to a page without its intended text: {target["text"]}'
for link in audit['links']:
 target=targets[link['target']]
 if target['kind'] in ('figure','table') and re.fullmatch(r'\d+\.\d+',link['label']):
  assert target['text'].startswith(target['kind'].title()+' '+link['label']+':'), link
 if target['kind']=='reference' and link['numberedCitation']:
  assert target['referenceNumber']=='['+link['label']+']', link
body_links=0
for page in r.pages[offset:]:
 for ref in page.get('/Annots',[]):
  annotation=ref.get_object()
  if annotation.get('/Subtype')!='/Link': continue
  action=annotation.get('/A',{})
  destination=annotation.get('/Dest') or (action.get('/D') if action.get('/S')=='/GoTo' else None)
  if destination is not None:
   assert isinstance(destination,str), f'Unrecorded direct body destination: {destination}'
   assert unquote(destination.lstrip('/')) in targets, f'Unaudited PDF body link: {destination}'
   body_links+=1
  elif action.get('/S')=='/URI':
   url=urlsplit(action['/URI'])
   assert url.hostname not in ('127.0.0.1','localhost'), f'Local-only PDF link: {url.geturl()}'
   assert not (url.hostname=='katatam.github.io' and url.path.startswith('/sample-size-calculation/book/')), f'Tutorial reference leaves the PDF: {url.geturl()}'
  else: raise AssertionError(f'Unsupported PDF link action: {annotation}')
assert body_links>0
counts=Counter(t['kind'] for t in targets.values())
print(f'Internal PDF checks passed: {body_links} body link annotations; {len(targets)} verified targets ({dict(counts)}). Figure/table labels and citation numbers agree with their destinations.')

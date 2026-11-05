"""Check exported report content, editable Word structure and PDF tags/links."""
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from zipfile import ZipFile
from pypdf import PdfReader

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path('build/report-downloads')
normalize = lambda text: re.sub(r'\s+', ' ', text).strip()
ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
for source in root.glob('*.model.json'):
    stem = source.name.removesuffix('.model.json')
    model = json.loads(source.read_text(encoding='utf-8'))
    reader = PdfReader(root / (stem + '.pdf'))
    text = normalize(' '.join(re.sub(r'-[ \t]*\n\s*', '-',
        re.sub(r'(?m)^Page \d+ of \d+\s*$', '', page.extract_text())) for page in reader.pages))
    # PDF line wrapping may split a DOI or other unbroken string. Compare all
    # substantive characters; inspect wrapping and spacing in the rendered pages.
    pdf_content = re.sub(r'\s+', '', text)
    assert reader.metadata.title == model['title'], stem
    assert reader.trailer['/Root']['/Lang'] == 'en-US', stem
    assert reader.trailer['/Root']['/MarkInfo']['/Marked'], stem
    structure = reader.trailer['/Root']['/StructTreeRoot']
    roles = []
    def walk(node):
        if hasattr(node, 'get_object'):
            node = node.get_object()
        if isinstance(node, list):
            for item in node: walk(item)
        elif isinstance(node, dict):
            if '/S' in node: roles.append(str(node['/S']))
            if '/K' in node: walk(node['/K'])
    walk(structure)
    assert {'/Document', '/H1', '/P'} <= set(roles), (stem, roles)
    uris = {str(a.get_object().get('/A', {}).get('/URI')) for page in reader.pages for a in page.get('/Annots', [])}
    for url in ['https://creativecommons.org/licenses/by-sa/4.0/', 'https://opensource.org/license/mit']:
        assert url in uris, (stem, 'PDF link', url)
    with ZipFile(root / (stem + '.docx')) as archive:
        doc = ET.fromstring(archive.read('word/document.xml'))
        word_text = normalize(' '.join(''.join('\n' if el.tag == '{'+ns['w']+'}br' else el.text or ''
            for el in paragraph.iter() if el.tag in ('{'+ns['w']+'}t', '{'+ns['w']+'}br'))
            for paragraph in doc.findall('.//w:p', ns)))
        style_ids = {el.attrib.get('{'+ns['w']+'}val') for el in doc.findall('.//w:pStyle', ns)}
        assert 'Title' in style_ids, (stem, style_ids)
        relationships = ET.fromstring(archive.read('word/_rels/document.xml.rels'))
        links = {el.attrib.get('Target') for el in relationships if el.attrib.get('TargetMode') == 'External'}
        assert 'https://creativecommons.org/licenses/by-sa/4.0/' in links, stem
        assert 'https://opensource.org/license/mit' in links, stem
        for block in model['blocks']:
            cells = [cell for row in block['rows'] for cell in row] if block['type'] == 'table' else [block]
            for cell in cells:
                expected = normalize(''.join(run['text'] for run in cell['runs']))
                assert re.sub(r'\s+', '', expected) in pdf_content, (stem, 'PDF missing', expected[:130])
                assert expected in word_text, (stem, 'Word missing', expected[:130])
            if block['type'] == 'table':
                assert {'/Table', '/TH', '/TD'} <= set(roles), (stem, roles)
                assert doc.findall('.//w:tblHeader', ns), stem
    assert 'private-backup' not in text and 'private-backup' not in word_text, stem
    print(f'{stem}: PDF ({len(reader.pages)} pages) and Word content, structure, Unicode and license links passed.')

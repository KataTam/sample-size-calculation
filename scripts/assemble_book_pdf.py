"""Add paginated, linked book front matter to the rendered tutorial body."""
from pathlib import Path
from io import BytesIO
import json
import re
from xml.sax.saxutils import escape
from pypdf import PdfReader, PdfWriter
from pypdf.annotations import Link
from pypdf.generic import NameObject, TextStringObject
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph

ROOT = Path(__file__).resolve().parents[1]
body = PdfReader(ROOT / 'build/pdf/tutorial-body.pdf')
headings = json.loads((ROOT / 'build/pdf/headings.json').read_text(encoding='utf-8'))
def normalize(text):
    return re.sub(r'\s+', ' ', text).strip()
destinations = {}
def collect(items, chapter=None):
    current_chapter = chapter
    for item in items:
        if isinstance(item, list):
            collect(item, current_chapter)
        else:
            title = re.sub(r'\s+', '', item.title)
            if chapter is None:
                current_chapter = title
            key = (current_chapter, title)
            destinations.setdefault(key, []).append(body.get_destination_page_number(item))
collect(body.outline)
chapter = None
for heading in headings:
    title = re.sub(r'\s+', '', heading['title'])
    if heading['level'] == 0:
        chapter = title
    matches = destinations.get((chapter, title), [])
    if not matches:
        raise RuntimeError(f'No PDF destination in {chapter} for heading: {title}')
    heading['page'] = matches.pop(0)

width, height = A4
margin = 62
buffer = BytesIO()
c = Canvas(buffer, pagesize=A4)
c.setTitle('How many patients do you need for your study?')
style = ParagraphStyle('title', fontName='Times-Roman', fontSize=29, leading=35, textColor='#243746')
p = Paragraph('How many patients<br/>do you need for<br/>your study?', style)
w,h=p.wrap(width-2*margin, height); p.drawOn(c, margin, height-170-h)
c.setStrokeColorRGB(.2,.35,.5); c.line(margin, height-345, width-margin,height-345)
c.setFont('Times-Roman',15); c.drawString(margin,height-380,'Sample size calculation tutorial')
c.setFont('Times-Roman',12); c.drawString(margin,height-410,'For healthcare professionals')
c.setFont('Times-Roman',12); c.drawString(margin,height-435,'Draft version')
c.setFont('Times-Roman',14); c.drawString(margin,210,'Katalin Tamasi'.replace('Tamasi','Tamási'))
c.setFont('Times-Roman',11); c.drawString(margin,188,'University Medical Center Groningen')
metadata=json.loads((ROOT/'build/pdf/metadata.json').read_text(encoding='utf-8'))
c.setFont('Times-Roman',11); c.drawString(margin,167,'Updated '+metadata['date'])
license_style = ParagraphStyle('licenses', fontName='Times-Roman', fontSize=10, leading=14)
license_note = Paragraph('Teaching materials: <a href="https://creativecommons.org/licenses/by-sa/4.0/" color="#17658a">CC BY-SA 4.0</a> | Code: <a href="https://opensource.org/license/mit" color="#17658a">MIT</a>', license_style)
license_note.wrap(width-2*margin, 40)
license_note.drawOn(c, margin, 95)
c.showPage()
links=[]; toc_page=1; y=height-margin
chapter_style=ParagraphStyle('chapter',fontName='Times-Bold',fontSize=11,leading=14)
section_style=ParagraphStyle('section',fontName='Times-Roman',fontSize=10,leading=13)
def start_contents(continued=False):
    global y
    c.setFont('Times-Bold',23); c.drawString(margin,height-margin,'Contents' + (' (continued)' if continued else ''))
    y=height-margin-38

def finish_contents():
    c.setFont('Times-Roman',10); c.drawCentredString(width/2,34,['i','ii','iii','iv','v','vi','vii','viii','ix','x'][toc_page-1])
    c.showPage()
start_contents()
for heading in headings:
    level=heading['level']; indent=14*level
    para=Paragraph(escape(normalize(heading['title'])),section_style if level else chapter_style)
    pw,ph=para.wrap(width-2*margin-indent-38,100)
    gap=6 if level else 12
    if y-ph-gap<margin:
        finish_contents(); toc_page+=1; start_contents(True)
    y-=gap
    para.drawOn(c,margin+indent,y-ph)
    c.setFont('Times-Roman',10); c.drawRightString(width-margin,y-11,str(heading['page']+1))
    links.append((toc_page,(margin+indent,y-ph-2,width-margin,y+2),heading['page']))
    y-=ph
finish_contents(); c.save()
front=PdfReader(BytesIO(buffer.getvalue())); offset=len(front.pages)
# Preserve the browser's structure tree and page associations when adding front matter.
writer=PdfWriter(); writer.clone_document_from_reader(body)
if '/Outlines' in writer._root_object: del writer._root_object['/Outlines']
for i, page in enumerate(front.pages): writer.insert_page(page, i)
writer._root_object[NameObject('/Lang')] = TextStringObject('en-US')
writer.add_outline_item('Title page',0)
writer.add_outline_item('Contents',1)
parent=None
for heading in headings:
    item=writer.add_outline_item(normalize(heading['title']),offset+heading['page'],parent=parent if heading['level'] else None)
    if heading['level']==0: parent=item
for page,rect,dest in links:
    writer.add_annotation(page,Link(rect=rect,target_page_index=offset+dest))
    writer.pages[page]["/Annots"][-1].get_object()["/Dest"][0] = writer.pages[offset+dest].indirect_reference
writer.set_page_label(0,0,prefix='Title')
writer.set_page_label(1,offset-1,style='/r',start=1)
writer.set_page_label(offset,len(writer.pages)-1,style='/D',start=1)
writer.add_metadata({'/Title':'How many patients do you need for your study?','/Author':'Katalin Tamási','/Subject':'Sample size calculation tutorial for healthcare professionals'})
writer.write(ROOT/'build/pdf/tutorial-complete.pdf')
print(f'Book PDF: title page, {offset-1} contents pages, {len(body.pages)} body pages; {len(headings)} linked entries.')

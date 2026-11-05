/* Browser-local, editable report exports. Original software: MIT. */
(() => {
  'use strict';
  if (window.ReportExports) return;
  const scriptURL = document.currentScript?.src;
  const pending = new Map();
  function assetURL(name) {
    const base = window.SampleSizeReportAssets || new URL('vendor/reports/',
      window.SampleSizeSiteRoot || (scriptURL ? new URL('./', scriptURL) : new URL('../', location.href))).href;
    return new URL(name, base).href;
  }
  function library(name) {
    const url = assetURL(name);
    if (!pending.has(url)) pending.set(url, new Promise((resolve, reject) => {
      const script = document.createElement('script'); script.src = url;
      script.onload = resolve;
      script.onerror = () => { script.remove(); pending.delete(url); reject(Error('The report exporter could not load. Please check your connection and try again.')); };
      document.head.append(script);
    }));
    return pending.get(url);
  }
  async function fontData() {
    const url = assetURL('DejaVuSans.ttf');
    if (!pending.has(url)) pending.set(url, fetch(url).then(response => {
      if (!response.ok) throw Error('The report font could not load.');
      return response.arrayBuffer();
    }).catch(error => { pending.delete(url); throw error; }));
    return pending.get(url);
  }
  function safeLink(value) {
    try {
      const url = new URL(value, window.SampleSizeSiteRoot || location.href);
      return ['http:', 'https:', 'mailto:'].includes(url.protocol) ? url.href : null;
    } catch (_) { return null; }
  }
  function runs(element) {
    const result = [], mixed = element.childElementCount > 0;
    function visit(node, link = null) {
      if (node.nodeType === Node.TEXT_NODE) {
        const text = mixed ? node.textContent.replace(/\s+/g, ' ') : node.textContent.replace(/\r\n?/g, '\n');
        if (text) result.push({text, link});
      } else if (node.nodeType === Node.ELEMENT_NODE) {
        if (node.matches('script,style,button,input,textarea')) return;
        if (node.tagName === 'BR') result.push({text:'\n', link});
        else node.childNodes.forEach(child => visit(child, node.tagName === 'A' ? safeLink(node.getAttribute('href')) : link));
      }
    }
    element.childNodes.forEach(node => visit(node));
    if (result.length) {
      result[0].text = result[0].text.trimStart();
      result[result.length-1].text = result[result.length-1].text.trimEnd();
    }
    return result.filter(run => run.text);
  }
  function parse(html) {
    const document = new DOMParser().parseFromString(html, 'text/html');
    const title = document.querySelector('h1')?.textContent.trim() || document.title || 'Activity report';
    const blocks = [];
    let titleSkipped = false;
    function visit(element) {
      if (element.matches('script,style,noscript,button,input,textarea')) return;
      if (/^H[1-6]$/.test(element.tagName)) {
        if (!titleSkipped && element.tagName === 'H1' && element.textContent.trim() === title) { titleSkipped = true; return; }
        blocks.push({type:'heading', level:Number(element.tagName[1]), runs:runs(element)});
      } else if (element.tagName === 'TABLE') {
        const caption = element.querySelector('caption');
        if (caption) blocks.push({type:'caption', runs:runs(caption)});
        blocks.push({type:'table', rows:[...element.querySelectorAll('tr')].map(row =>
          [...row.children].filter(cell => /^(TH|TD)$/.test(cell.tagName)).map(cell => ({header:cell.tagName==='TH', runs:runs(cell)})))});
      } else if (['P','LI','PRE'].includes(element.tagName)) {
        const inline = runs(element);
        if (inline.length) blocks.push({type:'paragraph', runs:element.tagName === 'LI' ? [{text:'• '}, ...inline] : inline});
      } else [...element.children].forEach(visit);
    }
    [...document.body.children].forEach(visit);
    const headings = blocks.filter(block => block.type === 'heading');
    const firstLevel = Math.min(6, ...headings.map(block => block.level));
    headings.forEach(block => { block.level = Math.min(3, 2 + block.level - firstLevel); });
    return {title, blocks};
  }
  const plain = block => block.runs.map(run => run.text).join('');
  async function pdf(model) {
    await library('pdfkit-0.20.2.js');
    const font = await fontData();
    const PDFDocument = window.PDFDocument.PDFDocument || window.PDFDocument;
    const doc = new PDFDocument({font:null, size:'A4', margin:62, bufferPages:true,
      tagged:true, lang:'en-US', displayTitle:true, pdfVersion:'1.7',
      info:{Title:model.title, Creator:'Sample size calculation tutorial report exporter'}});
    const chunks = [];
    const finished = new Promise((resolve, reject) => {
      doc.on('data', chunk => chunks.push(chunk));
      doc.on('end', () => resolve(new Blob(chunks, {type:'application/pdf'})));
      doc.on('error', reject);
    });
    doc.registerFont('Report', font).font('Report');
    const structure = doc.struct('Document'); doc.addStructure(structure);
    const width = doc.page.width - 124;
    function paragraph(block, size=10.5, tag='P', color='#20343e') {
      const parent = doc.struct(tag); structure.add(parent);
      doc.font('Report').fontSize(size).fillColor(color); doc.x = 62;
      block.runs.forEach((run, index) => {
        const final = index === block.runs.length - 1;
        const text = run.text + (final ? ' ' : '');
        const draw = () => doc.fillColor(run.link ? '#17547b' : color).text(text, {
          width, lineGap:3, features:{kern:false,liga:false}, continued:!final, link:run.link || null, underline:!!run.link});
        if (run.link) parent.add(doc.struct('Link', draw)); else parent.add(draw);
      });
      parent.end(); doc.moveDown(.55);
    }
    paragraph({runs:[{text:model.title}]}, 21, 'H1', '#000000');
    for (const block of model.blocks) {
      if (block.type === 'heading') {
        const height = doc.fontSize(13).heightOfString(plain(block), {width, lineGap:3});
        if (doc.y + height + 38 > doc.page.height - 62) doc.addPage();
        doc.moveDown(.25);
        paragraph(block, block.level === 2 ? 13 : 11.5, 'H'+block.level, '#17547b');
      } else if (block.type === 'table') {
        doc.font('Report').fontSize(9.5).fillColor('#20343e'); doc.x = 62;
        const data = block.rows.map(row => row.map(cell => ({text:plain(cell)+' ',
          type:cell.header?'TH':'TD', scope:cell.header?'Column':undefined,
          textOptions:{features:{kern:false,liga:false}},
          backgroundColor:cell.header?'#e5eef5':undefined})));
        doc.table({data, maxWidth:width, structParent:structure,
          defaultStyle:{padding:7, border:[0,0,.5,0], borderColor:'#b8cbd4'}});
        doc.moveDown(.8);
      } else paragraph(block, block.type === 'caption' ? 9.5 : 10.5);
    }
    structure.end();
    const pages = doc.bufferedPageRange();
    for (let i=0;i<pages.count;i++) {
      doc.switchToPage(i);
      const bottom = doc.page.margins.bottom;
      doc.page.margins.bottom = 0;
      doc.markContent('Artifact', {type:'Pagination', attached:['Bottom']});
      doc.font('Report').fontSize(8).fillColor('#52616b').text(`Page ${i+1} of ${pages.count}`, 62, doc.page.height-39,
        {width, lineBreak:false, align:'right'});
      doc.endMarkedContent();
      doc.page.margins.bottom = bottom;
    }
    doc.end();
    return finished;
  }
  async function word(model) {
    await library('docx-9.6.1.js');
    const d = window.docx;
    function inline(items) {
      return items.flatMap(run => run.text.split('\n').flatMap((line,index) => {
        const result = index ? [new d.TextRun({break:1})] : [];
        if (line) result.push(run.link ? new d.ExternalHyperlink({link:run.link,
          children:[new d.TextRun({text:line, style:'Hyperlink'})]}) : new d.TextRun(line));
        return result;
      }));
    }
    const children = [new d.Paragraph({text:model.title, heading:d.HeadingLevel.TITLE})];
    for (const block of model.blocks) {
      if (block.type === 'table') {
        const count = Math.max(...block.rows.map(row=>row.length));
        children.push(new d.Table({width:{size:100,type:d.WidthType.PERCENTAGE}, layout:d.TableLayoutType.FIXED,
          columnWidths:Array(count).fill(Math.floor(9412/count)),
          rows:block.rows.map(row => new d.TableRow({tableHeader:row.every(cell=>cell.header),
            children:row.map(cell => new d.TableCell({children:[new d.Paragraph({children:inline(cell.runs),spacing:{after:40}})],
              margins:{top:100,bottom:100,left:100,right:100},
              shading:cell.header?{fill:'E5EEF5'}:undefined}))}))}));
        children.push(new d.Paragraph({text:'', spacing:{after:80}}));
      } else children.push(new d.Paragraph({children:inline(block.runs),
        heading:block.type==='heading' ? (block.level===2 ? d.HeadingLevel.HEADING_1 : d.HeadingLevel.HEADING_2) : undefined,
        keepNext:block.type==='heading' || block.type==='caption', widowControl:true}));
    }
    const document = new d.Document({title:model.title, creator:'Sample size calculation tutorial',
      description:'Current activity assumptions, results and learner responses',
      styles:{default:{document:{run:{font:'Calibri',size:22,color:'20343E',language:{value:'en-US'}},
        paragraph:{spacing:{after:150,line:288},widowControl:true}},
        title:{run:{font:'Calibri',size:42,bold:false,color:'000000'},paragraph:{spacing:{before:0,after:260},keepNext:true}},
        heading1:{run:{font:'Calibri',size:27,bold:true,color:'17547B'},paragraph:{spacing:{before:220,after:120},keepNext:true}},
        heading2:{run:{font:'Calibri',size:24,bold:true,color:'17547B'},paragraph:{spacing:{before:180,after:100},keepNext:true}}}},
      sections:[{properties:{page:{size:{width:11906,height:16838},margin:{top:1247,bottom:1247,left:1247,right:1247}}},
        footers:{default:new d.Footer({children:[new d.Paragraph({alignment:d.AlignmentType.RIGHT,
          children:[new d.TextRun({children:['Page ',d.PageNumber.CURRENT,' of ',d.PageNumber.TOTAL_PAGES],size:18,color:'52616B'})]})]})},children}]});
    return d.Packer.toBlob(document);
  }
  function saveBlob(blob, name) {
    const url = URL.createObjectURL(blob), link = document.createElement('a');
    link.href=url; link.download=name; document.body.append(link); link.click(); link.remove();
    setTimeout(()=>URL.revokeObjectURL(url),60000);
  }
  async function download(html, format='pdf', filename='activity-report') {
    if (!['pdf','docx'].includes(format)) throw Error('Choose PDF or Word for your report.');
    const model = parse(html);
    if (!model.blocks.length) throw Error('The report has no content yet.');
    const blob = await (format==='pdf' ? pdf(model) : word(model));
    const name = filename.replace(/\.(html?|pdf|docx)$/i,'') + '.' + format;
    saveBlob(blob, name);
    return name;
  }
  window.ReportExports = {parse, pdf, word, download, saveBlob};
})();

// Run after render_resource.R and build_site.py, with the loopback preview running.
// Browser printing keeps computed tables, figures and mathematical notation together.
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
if (!['127.0.0.1', 'localhost'].includes(new URL(base).hostname)) throw Error('Use the private loopback preview.');
const allChapters = ['index', 'clinical-question', 'power', 'calculations', 'curves', 'simulation', 'feasibility', 'exercises', 'study-designs', 'glossary', 'common-mistakes', 'appendix', 'references'];
// CHAPTERS=feasibility refreshes only that chapter's downloads after a text edit.
const chapters = process.env.CHAPTERS ? process.env.CHAPTERS.split(',') : allChapters;
if (chapters.some(slug => !allChapters.includes(slug))) throw Error('Unknown chapter requested.');
const css = fs.readFileSync('module/styles.css', 'utf8') + `
body { font: 16px/1.65 Arial, sans-serif; color: #26343d; margin: 0 auto; padding: 28px; max-width: 920px; }
h1 { font-size: 30px; line-height: 1.3; } h2 { font-size: 23px; margin-top: 1.8em; } h3 { font-size: 19px; }
table { border-collapse: collapse; width: 100%; margin: 1.4em 0; font-size: 14px; }
th, td { padding: 8px; text-align: left; vertical-align: top; border-bottom: 1px solid #d8e1e7; }
caption, .caption { text-align: left; font-size: 14px; color: #465562; margin: .6em 0; }
img, svg { max-width: 100%; } .figure { margin: 1.5em 0; } pre { white-space: pre-wrap; overflow-wrap: anywhere; font-size: 12px; }
a { color: #17658a; } .chapter-downloads { display: none; }
@media print {
 body { padding: 0; font-size: 10pt; line-height: 1.5; max-width: none; }
 h1 { font-size: 22pt; } h2 { font-size: 16pt; } h3 { font-size: 13pt; }
 h1, h2, h3, h4, summary, caption { break-after: avoid; }
 table { font-size: 8pt; } thead { display: table-header-group; } tr { break-inside: avoid; }
 .figure { break-inside: avoid; } .figure img { max-height: 210mm; object-fit: contain; }
 .learning-goals, .misconception { break-inside: avoid; }
 details:not(.r-code-output) > summary { list-style: none; font-weight: bold; }
 .reference-preview-button, .chapter-downloads, details.r-code-output { display: none !important; }
 .MathJax_SVG_Display { overflow: visible !important; }
}
`;
const readerScripts = fs.readFileSync('module/toolbar-help.html', 'utf8');
let browser;
(async () => {
  for (const folder of ['docs/book/downloads', '_site/book/downloads', 'output/pdf']) fs.mkdirSync(folder, {recursive: true});
  browser = await chromium.launch({headless: true, ...(process.platform === 'win32' ? {channel:'msedge'} : {})});
  const page = await browser.newPage();
  const manifestFile='docs/book/chapter-downloads.json';
  const manifest = fs.existsSync(manifestFile) ? JSON.parse(fs.readFileSync(manifestFile,'utf8')).filter(item=>!chapters.includes(item.slug)) : [];
  for (const slug of chapters) {
    const response = await page.goto(`${base}/book/${slug}.html`, {waitUntil:'networkidle'});
    if (!response.ok()) throw Error(`Missing chapter ${slug}`);
    await page.evaluate(async () => {
      if (window.MathJax && MathJax.Hub) await new Promise(resolve => MathJax.Hub.Queue(['setRenderer', MathJax.Hub, 'SVG'], ['Rerender', MathJax.Hub], resolve));
      await Promise.all(Array.from(document.images).map(img => img.decode().catch(() => {})));
    });
    const extracted = await page.evaluate(async () => {
      const normal = document.querySelector('.page-inner .normal');
      if (!normal) throw Error('Chapter body not found');
      const clone = normal.cloneNode(true);
      clone.querySelectorAll('.chapter-downloads, .reference-preview-button, script, .MathJax_Preview').forEach(el => el.remove());
      for (const img of clone.querySelectorAll('img')) {
        const response = await fetch(img.src); if (!response.ok) throw Error('Missing image '+img.src);
        const blob = await response.blob();
        img.src = await new Promise(resolve => { const reader = new FileReader(); reader.onload = () => resolve(reader.result); reader.readAsDataURL(blob); });
      }
      clone.querySelectorAll('a[href]').forEach(a => { const url=new URL(a.getAttribute('href'), location.href); a.setAttribute('href', url.pathname===location.pathname && url.hash ? url.hash : url.href); a.target='_blank'; a.rel='noopener'; });
      const glyphs = document.querySelector('#MathJax_SVG_glyphs');
      const mathCSS=Array.from(document.querySelectorAll('style')).map(el=>el.textContent).filter(text=>/MathJax|MJX_Assistive/.test(text)).join('\n');
      const glyphSVG=glyphs && glyphs.closest('svg').cloneNode(true);
      if(glyphSVG) { glyphSVG.setAttribute('style','position:absolute;width:0;height:0;overflow:hidden'); glyphSVG.setAttribute('aria-hidden','true'); }
      return {title: clone.querySelector('h1').textContent.trim(), mathCSS, html: (glyphSVG ? glyphSVG.outerHTML : '')+clone.innerHTML};
    });
    const safeTitle = extracted.title.replace(/[&<>"']/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]));
    const html = `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${safeTitle}</title><style>${css}\n${extracted.mathCSS}</style></head><body><main>${extracted.html}</main>${readerScripts}</body></html>`;
    fs.writeFileSync(`docs/book/downloads/${slug}.html`, html);
    fs.writeFileSync(`_site/book/downloads/${slug}.html`, html);
    await page.setContent(html, {waitUntil:'load'});
    await page.evaluate(async () => {
      document.querySelectorAll('details:not(.r-code-output)').forEach(el => el.open=true);
      await Promise.all(Array.from(document.images).map(img => img.decode().catch(() => {})));
      await document.fonts.ready;
    });
    const pdf = await page.pdf({format:'A4', printBackground:true, margin:{top:'16mm',right:'16mm',bottom:'18mm',left:'16mm'}, displayHeaderFooter:true, headerTemplate:'<span></span>', footerTemplate:'<div style="font:9px Arial;width:100%;text-align:center;color:#586572">Katalin Tamási · Sample size calculation tutorial · <span class="pageNumber"></span> / <span class="totalPages"></span></div>'});
    for (const folder of ['docs/book/downloads', '_site/book/downloads', 'output/pdf']) fs.writeFileSync(`${folder}/${slug}.pdf`, pdf);
    manifest.push({slug,title:extracted.title,html:`downloads/${slug}.html`,pdf:`downloads/${slug}.pdf`});
    console.log(`Exported ${slug}: HTML and PDF`);
  }
  manifest.sort((a,b)=>allChapters.indexOf(a.slug)-allChapters.indexOf(b.slug));
  for (const folder of ['docs/book','_site/book']) {
    fs.writeFileSync(`${folder}/chapter-downloads.json`, JSON.stringify(manifest,null,2));
    for (const chapter of manifest) {
      const file=path.join(folder,chapter.slug+'.html');
      let html=fs.readFileSync(file,'utf8');
      html=html.replace(/<nav class="chapter-downloads"[\s\S]*?<\/nav>/g,'');
      html=html.replace(/(<h1[^>]*>[\s\S]*?<\/h1>)/,`$1\n<nav class="chapter-downloads" aria-label="Download this chapter"><strong>Download this chapter:</strong><a href="${chapter.html}" download target="_blank" rel="noopener">HTML</a><a href="${chapter.pdf}" download target="_blank" rel="noopener">PDF</a></nav>`);
      fs.writeFileSync(file,html);
    }
  }
  // Assemble the full print edition from the same learner-facing chapter exports.
  // This preserves formatted results and math while hiding technical code/output.
  if (allChapters.every(slug => fs.existsSync(`docs/book/downloads/${slug}.html`))) {
    const sections = allChapters.map(slug => {
      const html = fs.readFileSync(`docs/book/downloads/${slug}.html`, 'utf8');
      const main = html.match(/<main>([\s\S]*?)<\/main>/)[1];
      const mathCSS = html.match(/<style>([\s\S]*?)<\/style>/)[1];
      return `<section class="print-chapter"><style>${mathCSS}</style>${main}</section>`;
    }).join('\n');
    await page.setContent(`<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Sample size calculation tutorial</title><style>${css}\n@media print {.print-chapter + .print-chapter {break-before:page;}}</style></head><body>${sections}</body></html>`, {waitUntil:'load'});
    await page.evaluate(async () => {
      document.querySelectorAll('details:not(.r-code-output)').forEach(el => el.open=true);
      await Promise.all(Array.from(document.images).map(img => img.decode().catch(() => {})));
      await document.fonts.ready;
    });
    const complete = await page.pdf({format:'A4',printBackground:true,margin:{top:'16mm',right:'16mm',bottom:'18mm',left:'16mm'},displayHeaderFooter:true,headerTemplate:'<span></span>',footerTemplate:'<div style="font:9px Arial;width:100%;text-align:center;color:#586572">Katalin Tamási · Sample size calculation tutorial · <span class="pageNumber"></span> / <span class="totalPages"></span></div>'});
    for (const folder of ['module','docs/book','_site/book','output/pdf']) fs.writeFileSync(`${folder}/Sample_size_open_module.pdf`, complete);
    console.log('Exported complete tutorial PDF from chapter downloads');
  }
  await browser.close();
})().catch(async error=>{ console.error(error); if(browser) await browser.close(); process.exit(1); });

const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
let browser;
(async()=>{
 browser=await chromium.launch({headless:true,channel:'msedge'});
 const page=await browser.newPage({viewport:{width:1400,height:1000}}), errors=[];
 page.on('pageerror',e=>errors.push(e.message));
 await page.goto(base+'/book/clinical-question.html');
 assert((await page.locator('h2').first().innerText()).includes('chronic-pain'));
 assert(await page.evaluate(()=>document.querySelector('#misconception-pilot-effect').compareDocumentPosition(document.getElementById('tab:pain-planning-values')) & Node.DOCUMENT_POSITION_PRECEDING));
 assert(await page.locator('table').first().isVisible());
 for(const pre of await page.locator('details.r-code-output pre').all()) assert.equal(await pre.isVisible(),false);
 const tableRef=page.locator('a[data-reference-preview][href*="tab:pain-planning-values"]').first();
 await tableRef.hover(); await page.locator('#reference-preview:not([hidden]) table').waitFor();
 assert((await page.locator('#reference-preview').innerText()).includes('40 percentage points'));
 await tableRef.press('Escape');assert.equal(await page.locator('#reference-preview').isVisible(),false);
 await page.locator('.page-inner h1').click();await tableRef.focus();await page.locator('#reference-preview:not([hidden]) table').waitFor();
 await tableRef.press('Escape');
 await page.goto(base+'/book/simulation.html');
 const cross=page.locator('a[data-reference-preview][href*="fig:power-curves"]').first();
 await cross.hover();await page.locator('#reference-preview:not([hidden]) img').waitFor();
 assert(await page.locator('#reference-preview img').evaluate(img=>img.complete&&img.naturalWidth>0));
 await page.screenshot({path:'build/browser-checks/reference-preview.png'});
 await page.setViewportSize({width:390,height:844});
 await cross.locator('xpath=following-sibling::button[1]').click();
 assert(await page.locator('#reference-preview').evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth;}));
 await page.goto(base+'/book/feasibility.html#dataset-reuse');
 assert((await page.locator('#dataset-reuse').innerText()).includes('different question'));
 const manifest=await (await page.request.get(base+'/book/chapter-downloads.json')).json();assert.equal(manifest.length,13);
 for(const chapter of manifest){
  await page.goto(base+'/book/'+chapter.slug+'.html');
  assert.equal(await page.locator('.chapter-downloads a').count(),2);
  for(const ext of ['html','pdf']){const r=await page.request.get(base+'/book/downloads/'+chapter.slug+'.'+ext);assert(r.ok());assert((await r.body()).length>1000);}
 }
 await page.goto(base+'/book/downloads/calculations.html');
 assert(await page.locator('svg').count()>0);
 assert.equal(await page.locator('details.r-code-output pre').first().isVisible(),false);
 assert(await page.locator('table').first().isVisible());
 assert.deepEqual(errors,[]);
 console.log('READER TOOLS CHECK PASSED: case-first order, delayed misconception, raw output folded, visible summaries, hover/focus/cross-chapter/touch previews, reuse example, 13 HTML/PDF downloads, self-contained mathematical figures.');
 await browser.close();
})().catch(async e=>{console.error(e);if(browser)await browser.close();process.exit(1);});

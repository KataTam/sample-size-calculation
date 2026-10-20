const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
 const page=await browser.newPage({viewport:{width:1400,height:1000}});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto(base+'/book/clinical-question.html');
 const citation=page.locator('a[data-citation-label*="Cook"]').first();
 assert.match(await citation.innerText(),/^\d+$/);
 await citation.hover();assert.match(await page.locator('#citation-tooltip').innerText(),/Cook et al., 2018/);
 fs.mkdirSync('build/browser-checks',{recursive:true});
 await page.screenshot({path:'build/browser-checks/numbered-citation.png'});
 await page.keyboard.press('Escape');assert(await page.locator('#citation-tooltip').isHidden());
 await citation.focus();assert(await page.locator('#citation-tooltip').isVisible());
 const number=await citation.innerText(),ref=(await citation.getAttribute('href')).split('#')[1];
 await page.goto(base+'/book/references.html');
 assert.equal((await page.locator('#'+ref+' .reference-number').innerText()),'['+number+']');
 assert.match(await page.locator('.citation:not(.citation-numbered)').allTextContents().then(x=>x.join(' ')),/Kirkwood/);
 assert.match(await page.locator('#ref-richardson1995').innerText(),/1995.*well-built clinical question/s);
 await page.goto(base+'/book/power.html');
 assert.equal(await page.locator('details.advanced-explanation[open]').count(),0);
 assert(await page.locator('.chapter-recap').isVisible());
 await page.locator('#activity-menu-button').click();
 assert(await page.locator('#activity-menu').isVisible());
 assert((await page.locator('#activity-menu a[href*="alpha_beta"]').count())>0);
 assert((await page.locator('#activity-menu h3').first().innerText()).includes('Power'));
 await page.keyboard.press('Escape');assert(await page.locator('#activity-menu').isHidden());
 await page.goto(base+'/book/power.html#eq:mcse');
 assert(await page.locator('[id="eq:mcse"]').isVisible());
 for(const chapter of ['clinical-question','power','calculations','curves','simulation','feasibility','exercises','study-designs']) {
  await page.goto(base+'/book/'+chapter+'.html');
  assert.equal(await page.locator('.chapter-recap').count(),1,chapter);
  assert(await page.locator('.chapter-recap').isVisible(),chapter);
 }
 for(const chapter of ['glossary','common-mistakes']) {
  await page.goto(base+'/book/'+chapter+'.html');
  assert.equal(await page.locator('.page-inner .chapter-recap, .page-inner .learning-goals').count(),0,chapter);
 }
 await page.goto(base+'/book/glossary.html');
 assert.equal(await page.locator('.section.level1').count(),1);
 assert(await page.locator('.section.level1 > h1').isVisible());
 await page.goto(base+'/book/Sample_size_open_module.html');
 assert((await page.locator('a[data-citation-label]').count())>20);
 assert.equal(await page.locator('details.advanced-explanation[open]').count(),0);
 assert.deepEqual(errors,[]);
 console.log('Week 2 checks passed: hybrid citations, reference mapping, keyboard popups, activity menu, advanced disclosures, chapter recaps, and complete HTML.');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

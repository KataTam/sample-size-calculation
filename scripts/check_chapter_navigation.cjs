const {chromium}=require('playwright');
const assert=require('node:assert/strict');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
 const page=await browser.newPage({viewport:{width:1200,height:900}});
 const cases={
  'index':['clinical-question'], 'clinical-question':['power'], 'power':['calculations'],
  'calculations':['curves','feasibility'], 'curves':['simulation','feasibility'],
  'simulation':['feasibility'], 'feasibility':['exercises'], 'exercises':['study-designs','glossary'],
  'study-designs':['glossary'], 'glossary':['common-mistakes'], 'common-mistakes':['appendix'],
  'appendix':['references'], 'references':['index']
 };
 for(const [chapter,expected] of Object.entries(cases)){
  await page.goto(`http://127.0.0.1:8769/book/${chapter}.html`);
  if(['glossary','common-mistakes'].includes(chapter)){
   assert.equal(await page.locator('.page-inner .learning-goals, .page-inner .chapter-recap').count(),0);
  }
  const nav=page.locator('.chapter-end-nav');assert.equal(await nav.count(),1);
  assert.equal(await nav.locator('ul,ol,li').count(),0);
  assert(await nav.isVisible());
  assert(await nav.evaluate(n=>{const recap=document.querySelector('.chapter-recap');const closing=recap||[...document.querySelectorAll('.page-inner .section.level2')].at(-1);return Boolean(n.compareDocumentPosition(closing)&Node.DOCUMENT_POSITION_FOLLOWING);}));
  assert.equal(await nav.evaluate(n=>getComputedStyle(n).display),'grid');
  assert.deepEqual(await nav.locator('a').evaluateAll(a=>a.map(x=>x.getAttribute('href'))),expected.map(x=>x+'.html'));
  assert(await nav.locator('a').evaluateAll(a=>a.every(x=>x.target!=='_blank')));
 }
 await page.setViewportSize({width:390,height:844});
 await page.goto('http://127.0.0.1:8769/book/calculations.html');
 assert((await page.locator('.chapter-end-nav').innerText()).includes('Read power curves'));
 assert((await page.locator('.chapter-end-nav').innerText()).includes('Recruitment, estimation and feasibility'));
 await page.locator('.chapter-end-nav').scrollIntoViewIfNeeded();
 await page.locator('.chapter-end-nav').screenshot({path:'build/browser-checks/chapter-navigation-mobile.png'});
 await page.locator('.chapter-end-nav a').nth(1).click();
 await page.waitForURL('**/feasibility.html');
 assert.equal(new URL(page.url()).hash,'');
 console.log('All 13 reading panels verified: consistent styling, no bullets, placement before closing content, destinations, core shortcuts and mobile navigation.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

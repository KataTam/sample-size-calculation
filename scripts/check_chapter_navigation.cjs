const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const base=process.argv[2] || 'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
 const page=await browser.newPage({viewport:{width:1200,height:900}});
 const order=['index','clinical-question','power','calculations','feasibility','curves','simulation','study-designs','appendix','exercises','glossary','common-mistakes','references'];
 const cases=Object.fromEntries(order.map((chapter,i)=>[chapter,[order[i-1],order[i+1]].filter(Boolean)]));
 for(const [chapter,expected] of Object.entries(cases)){
  await page.goto(`${base}/book/${chapter}.html`);
  if(['glossary','common-mistakes'].includes(chapter)){
   assert.equal(await page.locator('.page-inner .learning-goals, .page-inner .chapter-recap').count(),0);
  }
  const nav=page.locator('.chapter-end-nav');assert.equal(await nav.count(),1);
  assert.equal(await nav.locator('ul,ol,li').count(),0);
  assert(await nav.isVisible());
  assert(await nav.evaluate(n=>n.parentElement.matches('section.normal') && n.nextElementSibling===null));
  assert.equal(await nav.evaluate(n=>getComputedStyle(n).display),'flex');
  assert.deepEqual(await nav.locator('a').evaluateAll(a=>a.map(x=>x.getAttribute('href'))),expected.map(x=>x+'.html'));
  assert(await nav.locator('a').evaluateAll(a=>a.every(x=>x.target!=='_blank' && x.getAttribute('aria-label') && !x.title)));
 }
 await page.setViewportSize({width:390,height:844});
 await page.goto(`${base}/book/calculations.html`);
 assert.equal((await page.locator('.chapter-end-nav').innerText()).replace(/\s/g,''),'<>');
 await page.locator('.chapter-end-nav').scrollIntoViewIfNeeded();
 await page.locator('.chapter-end-nav').screenshot({path:'build/browser-checks/chapter-navigation-mobile.png'});
 await page.locator('.chapter-arrow-next').click();
 await page.waitForURL('**/feasibility.html');
 assert.equal(new URL(page.url()).hash,'');
 console.log('All 13 chapter arrow controls verified: destinations, accessible labels, placement and mobile navigation.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

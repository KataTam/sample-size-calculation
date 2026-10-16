const {chromium}=require('playwright');const assert=require('node:assert/strict');const fs=require('node:fs');
(async()=>{const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});try{
const page=await browser.newPage({viewport:{width:1400,height:1000}});const errors=[];page.on('pageerror',e=>errors.push(e.message));
await page.goto('http://127.0.0.1:8769/study/?activity=design_questionnaire');
const f=page.frameLocator('#app-frame');await f.locator('#aim').waitFor();
async function fill(values){for(const [id,value] of Object.entries(values))await f.locator('#'+id).selectOption(value);}
await fill({aim:'treatment',data:'new',structure:'independent',outcome:'binary',allocation:'individual',comparison:'parallel',claim:'superiority'});
await f.getByRole('button',{name:'Show design suggestions'}).click();assert.match(await f.locator('#suggested-design').innerText(),/parallel-group/);
assert.equal(await f.locator('#result a[href="../two_proportions/"]').count(),1);
assert.equal(await f.locator('#crossover').isVisible(),false);
await f.locator('#comparison').selectOption('crossover');assert.equal(await f.locator('#suggested-design').count(),0);
await f.locator('#crossover').selectOption('no');await f.getByRole('button',{name:'Show design suggestions'}).click();assert.match(await f.locator('#suggested-design').innerText(),/parallel-group/);
await fill({aim:'association',data:'existing',sampling:'casecontrol'});await f.getByRole('button',{name:'Show design suggestions'}).click();assert.equal(await f.locator('#suggested-design').innerText(),'Case-control study');assert.equal(await f.locator('#result a[href="../two_proportions/"]').count(),0);
assert.equal(await f.locator('#comparison').isVisible(),false);
fs.mkdirSync('build/browser-checks',{recursive:true});await page.screenshot({path:'build/browser-checks/design-questionnaire.png',fullPage:true});
await page.locator('#reset').click();await page.waitForFunction(()=>document.getElementById('app-frame').contentDocument.getElementById('aim').value==='');assert.equal(await f.locator('#aim').inputValue(),'');assert.equal(await f.locator('#suggested-design').count(),0);
await page.goto('http://127.0.0.1:8769/design_questionnaire/');await page.setViewportSize({width:390,height:844});
await page.locator('#aim').selectOption('prevalence');await page.locator('#data').selectOption('new');await page.locator('#structure').selectOption('independent');await page.locator('#outcome').selectOption('binary');await page.getByRole('button',{name:'Show design suggestions'}).click();
assert.match(await page.locator('#suggested-design').innerText(),/prevalence/);assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
await page.locator('#result-panel').screenshot({path:'build/browser-checks/design-questionnaire-mobile.png'});
await page.goto('http://127.0.0.1:8769/book/study-designs.html');assert(await page.locator('#design-questionnaire a[href*="activity=design_questionnaire"]').count());
await page.locator('#activity-menu-button').click();assert(await page.locator('#activity-menu a[href*="activity=design_questionnaire"]').count());
assert.deepEqual(errors,[]);console.log('Questionnaire browser checks passed: conditional fields, stale suggestions, case routing, calculator eligibility, shell reset, mobile layout and Chapter 8/menu links.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exit(1)});

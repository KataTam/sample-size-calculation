const {chromium}=require('playwright');const assert=require('node:assert/strict');const fs=require('node:fs');
(async()=>{const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});try{
const page=await browser.newPage({viewport:{width:1400,height:1000}});const errors=[];page.on('pageerror',e=>errors.push(e.message));
await page.goto('http://127.0.0.1:8769/study/?activity=design_questionnaire');
const f=page.frameLocator('#activity-design_questionnaire iframe');await f.locator('#aim').waitFor();
async function fill(values){for(const [id,value] of Object.entries(values))await f.locator('#'+id).selectOption(value);}
async function showSuggestions(){
 assert(await f.locator('#design-form').evaluate(form=>form.checkValidity()),'All active questionnaire fields are complete');
 const button=f.getByRole('button',{name:'Show design suggestions'});
 await button.scrollIntoViewIfNeeded();
 // Conditional fields change the embedded height after a 100 ms debounce.
 // Wait for that resize before dispatching a pointer click into the frame.
 await page.waitForFunction(()=>{
  const frame=document.querySelector('#activity-design_questionnaire iframe');
  const button=frame?.contentDocument?.querySelector('button[type="submit"]');
  if(!button)return false;
  const frameBox=frame.getBoundingClientRect(),buttonBox=button.getBoundingClientRect();
  const position=[frameBox.y,frameBox.height,buttonBox.x,buttonBox.y,buttonBox.width,buttonBox.height].join(',');
  if(window.designButtonPosition?.position!==position){window.designButtonPosition={position,since:performance.now()};return false;}
  return performance.now()-window.designButtonPosition.since>250;
 },null,{polling:50});
 await button.click();
 await f.locator('#suggested-design').waitFor();
}
await fill({aim:'treatment',data:'new',structure:'independent',outcome:'binary',allocation:'individual',comparison:'parallel',claim:'superiority'});
await showSuggestions();assert.match(await f.locator('#suggested-design').innerText(),/parallel-group/);
assert.equal(await f.locator('#result a[href="../two_proportions/"]').count(),1);
assert.equal(await f.locator('#crossover').isVisible(),false);
await f.locator('#comparison').selectOption('crossover');assert.equal(await f.locator('#suggested-design').count(),0);
await f.locator('#crossover').selectOption('no');await showSuggestions();assert.match(await f.locator('#suggested-design').innerText(),/parallel-group/);
await fill({aim:'association',data:'existing',sampling:'casecontrol'});await showSuggestions();assert.equal(await f.locator('#suggested-design').innerText(),'Case-control study');assert.equal(await f.locator('#result a[href="../two_proportions/"]').count(),0);
assert.equal(await f.locator('#comparison').isVisible(),false);
fs.mkdirSync('build/browser-checks',{recursive:true});await page.screenshot({path:'build/browser-checks/design-questionnaire.png',fullPage:true});
await f.locator('#start-again').click();assert.equal(await f.locator('#aim').inputValue(),'');assert.equal(await f.locator('#suggested-design').count(),0);
await page.goto('http://127.0.0.1:8769/design_questionnaire/');await page.setViewportSize({width:390,height:844});
await page.locator('#aim').selectOption('prevalence');await page.locator('#data').selectOption('new');await page.locator('#structure').selectOption('independent');await page.locator('#outcome').selectOption('binary');await page.getByRole('button',{name:'Show design suggestions'}).click();
assert.match(await page.locator('#suggested-design').innerText(),/prevalence/);assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
await page.locator('#result-panel').screenshot({path:'build/browser-checks/design-questionnaire-mobile.png'});
await page.goto('http://127.0.0.1:8769/book/study-designs.html');assert(await page.locator('#design-questionnaire a[href*="activity=design_questionnaire"]').count());
await page.locator('#activity-menu-button').click();assert(await page.locator('#activity-menu a[href*="#activity-design_questionnaire"]').count());
assert.deepEqual(errors,[]);console.log('Questionnaire browser checks passed: conditional fields, stale suggestions, case routing, calculator eligibility, inline reset, mobile layout and Chapter 8/menu links.');
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exit(1)});

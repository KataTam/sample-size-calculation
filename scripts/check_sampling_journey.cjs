const {chromium}=require('playwright');
const assert=require('node:assert/strict');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
 const page=await browser.newPage({viewport:{width:1500,height:1100},reducedMotion:'reduce'});
 await page.goto('http://127.0.0.1:8769/study/?activity=pain_one_many');
 let f;
 for(let i=0;i<150;i++){
  f=page.frames().find(x=>x.url().includes('__shinylive'));
  for(const frame of page.frames()) if(await frame.locator('#run_journey').count()) f=frame;
  if(f && await f.locator('#run_journey').count()) break;
  await page.waitForTimeout(1000);
 }
 assert(f,'App frame loaded');
 await f.waitForFunction(()=>document.querySelector('#fixed_n').value==='20');
 await f.waitForFunction(()=>document.querySelector('#combined-many-studies'));
 assert.equal(await f.locator('#combined-many-studies #run_many').count(),1);
 assert(!await f.locator('a[data-value="Many studies"]').isVisible());
 await f.locator('#run_one').click();
 await f.waitForFunction(()=>document.querySelector('#sampling-journey svg'));
 assert(await f.locator('#journey-motion').isChecked());
 await f.locator('#journey-pause').click();
 const text=await f.locator('#sampling-journey').innerText();
 assert(text.includes('trial 1 of 1'));
 assert(text.includes('20 patients per group'));
 assert(!await f.locator('#journey-status').innerText().then(t=>t.includes('seed')));
 assert(text.includes('2. Estimated difference in this trial'));
 assert(text.includes('3. The same estimate joins'));
 assert(await f.evaluate(()=>document.querySelector('#journey-credit').compareDocumentPosition(document.querySelector('#combined-many-studies')) & Node.DOCUMENT_POSITION_PRECEDING));
 const sample=await f.evaluate(()=>{
  const t=[...document.querySelectorAll('#sampling-journey text')].map(x=>x.textContent);
  return {counts:t.filter(x=>/^(Standard|Novel):/.test(x)),diff:t.find(x=>x.startsWith('= ')),table:document.querySelector('#one_result').textContent};
 });
 const counts=sample.counts.map(s=>Number(s.match(/: (\d+)\//)[1]));
 assert(sample.diff.includes(String((counts[1]-counts[0])*5)+' percentage points'));
 console.log('Actual patient counts and estimated difference agree:',JSON.stringify(sample));
 await f.locator('#run_journey').click();
 await f.waitForFunction(()=>document.querySelector('#sampling-journey').textContent.includes('trial 1 of 20'));
 await f.locator('#journey-motion').uncheck();
 await page.waitForTimeout(1200);
 await f.locator('#journey-pause').click();
 const before=await f.locator('#sampling-journey').innerHTML();
 await page.waitForTimeout(700);
 assert.equal(await f.locator('#sampling-journey').innerHTML(),before);
 await f.locator('#journey-replay').click();
 await f.waitForFunction(()=>document.querySelector('#sampling-journey').textContent.includes('trial 2 of 20'));
 await f.locator('#journey-pause').click();
 await f.locator('#sampling-journey').screenshot({path:'build/browser-checks/sampling-journey.png'});
 await f.locator('#run_many').click();
 await f.waitForFunction(()=>document.querySelector('#many_summary').textContent.includes('significant'));
 await f.locator('#fixed_n').fill('50');await f.locator('#fixed_n').press('Tab');
 await f.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('Inputs changed'));
 await page.locator('#reset').click();
 await f.waitForFunction(()=>!document.querySelector('#sampling-journey svg'));
 await page.locator('select').filter({has:page.locator('option[value="pain_curves"]')}).selectOption('pain_curves');
 await f.waitForFunction(()=>!document.querySelector('#combined-many-studies'));
 assert(await f.locator('a[data-value="Many studies"]').isVisible());
 console.log('Animation tests passed: actual counts, reduced motion, pause, replay, repeated trials, stale assumptions and reset.');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

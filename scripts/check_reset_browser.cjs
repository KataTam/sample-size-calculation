// End-to-end checks against the exported WebR apps and their split-screen shell.
const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
async function appFrame(page, selector) {
 const end=Date.now()+150000;
 while(Date.now()<end) {
  for(const frame of page.frames()) {
   try { if(await frame.locator(selector).count()) return frame; } catch(_){}
  }
  await new Promise(r=>setTimeout(r,1000));
 }
 throw Error('App did not load: '+selector);
}
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
 const page=await browser.newPage({viewport:{width:1600,height:1000}});
 await page.goto(base+'/study/?activity=pain_one_many');
 const f=await appFrame(page,'#fixed_n');
 await f.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
 await f.waitForFunction(()=>document.querySelector('#fixed_n').value==='20');
 console.log('Reasoning lab loaded; checking changed inputs and saved output.');
 await f.locator('#fixed_n').fill('37');await f.locator('#fixed_n').press('Tab');
 await f.locator('#run_one').click();
 await f.waitForFunction(()=>document.querySelector('#one_status').textContent.includes('n = 37'));
 await page.locator('#reset').click();
 await f.waitForFunction(()=>document.querySelector('#fixed_n').value==='20' && document.querySelector('#one_result').textContent.trim()==='');
 await f.locator('#fixed_n').fill('42');await f.locator('#fixed_n').press('Tab');
 await page.locator('#reset').click();
 await f.waitForFunction(()=>document.querySelector('#fixed_n').value==='20');
 await page.locator('#activity-select').count().then(async n=>{
   // The shell selector ID is discovered from its existing options.
   const selector=page.locator('select').filter({has:page.locator('option[value="alpha_beta"]')});
   await selector.selectOption('alpha_beta');
 });
 const sampling=await appFrame(page,'#mu0');
 await sampling.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
 await sampling.locator('#mu0').fill('130');await sampling.locator('#mu0').press('Tab');
 await page.locator('#reset').click();
 await sampling.waitForFunction(()=>document.querySelector('#mu0').value==='120');
 console.log('Sampling app reset passed.');
 const selector=page.locator('select').filter({has:page.locator('option[value="assumptions_report"]')});
 await selector.selectOption('assumptions_report');
 const report=await appFrame(page,'#question');
 await report.locator('#question').fill('Temporary reset check');
 await page.locator('#reset').click();
 await report.waitForFunction(()=>document.querySelector('#question').value==='');
 assert.equal(await report.locator('#question').inputValue(),'');
 console.log('Browser reset checks passed for repeated lab resets, saved simulation output, sampling app, report, and switching activities.');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

// Actual browser checks for the lab's one-population estimation mode.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
  fs.mkdirSync('build/planning-routes',{recursive:true});
  const page=await browser.newPage({viewport:{width:1300,height:1100}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(base+'/power_explorer/?activity=mean_precision');
  let frame;
  for(let i=0;i<180;i++){
   for(const candidate of page.frames())if(await candidate.locator('#precision-run_one').count())frame=candidate;
   if(frame)break;await page.waitForTimeout(1000);
  }
  assert(frame,'Reasoning app loaded');
  await frame.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1 && Shiny.shinyapp.$inputValues.goal==='precision' && document.documentElement.classList.contains('single-population-mode'));
  await frame.locator('#precision-result').filter({hasText:'analyzable participants in total'}).waitFor();
  assert.equal(await frame.locator('#plan_delta').isVisible(),false);
  assert.equal(await frame.locator('#plan_p0-number').isVisible(),false);
  assert(!/per group|difference|power/i.test(await frame.locator('#precision-result').innerText()));
  await frame.locator('#precision-view a[data-value="Simulations"]').click();
  await frame.locator('#precision-run_one').click();
  await frame.locator('#precision-simulation_summary').filter({hasText:'One study: estimated mean'}).waitFor();
  await frame.locator('#precision-run_many').click();
  await frame.locator('#precision-simulation_summary').filter({hasText:'1000 simulated studies'}).waitFor();
  await frame.locator('#precision-intervals img').waitFor();
  await frame.locator('#precision-view a[data-value="Report"]').click();
  await frame.locator('#precision-report').filter({hasText:'1000 simulated studies'}).waitFor();
  assert(!/per group|Type I|target power|reflection/i.test(await frame.locator('#precision-report').innerText()));
  for(const format of ['pdf','docx']){
   const download=page.waitForEvent('download',{timeout:90000});
   await frame.locator(`[data-report-format="${format}"]:visible`).click();
   assert((await download).suggestedFilename().endsWith('.'+format));
  }
  await frame.evaluate(()=>jQuery('#precision-outcome')[0].selectize.setValue('proportions'));
  await frame.locator('#precision-report').filter({hasText:'One population percentage'}).waitFor();
  assert(!/1000 simulated studies/.test(await frame.locator('#precision-report').innerText()));
  await frame.locator('#precision-view a[data-value="Overview"]').click();
  await frame.waitForFunction(()=>document.querySelector('#precision-result .app-value')?.textContent==='78' && !document.documentElement.classList.contains('shiny-busy'));
  await frame.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(el=>el.checkVisibility()));
  await page.screenshot({path:'build/planning-routes/estimation.png'});
  assert.deepEqual(errors,[]);
  console.log('One-population estimation: total counts, mean/percentage controls, simulations, current report and PDF/Word passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

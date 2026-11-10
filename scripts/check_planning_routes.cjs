// Comparison and estimation activities expose their own criteria and results.
const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
  fs.mkdirSync('build/planning-routes',{recursive:true});
  const page=await browser.newPage({viewport:{width:1400,height:1000}});
  await page.goto(base+'/power_explorer/?activity=pain_one_many');
  let frame;
  for(let i=0;i<180;i++){
   for(const candidate of page.frames()) if(await candidate.locator('#run_one').count()) frame=candidate;
   if(frame) break;
   await page.waitForTimeout(1000);
  }
  assert(frame,'Reasoning app loaded');
  await frame.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
  await frame.waitForFunction(()=>Shiny.shinyapp.$inputValues.outcome==='proportions');
  await frame.locator('#run_one').click();
  await frame.locator('#one_interpretation').filter({hasText:'Estimated difference'}).waitFor();
  assert.equal(await frame.locator('#one_plot').isVisible(),false);
  assert(!/confidence interval/i.test(await frame.locator('#one_interpretation').innerText()));
  await page.screenshot({path:'build/planning-routes/core.png'});
  await frame.evaluate(()=>Shiny.setInputValue('activity_choice','mean_precision',{priority:'event'}));
  await frame.waitForFunction(()=>Shiny.shinyapp.$inputValues.goal==='precision');
  await frame.locator('#overview_metrics').filter({hasText:'interval width'}).waitFor();
  assert(!/power/i.test(await frame.locator('#overview_metrics').innerText()));
  await frame.locator('#lab-settings').evaluate(e=>e.open=true);
  await frame.locator('#plan_delta-question').filter({hasText:'used in simulation'}).waitFor();
  assert.equal(await frame.locator('#expected_m-question').isVisible(),false);
  await frame.locator('#confidence').waitFor({state:'attached'});
  assert(await frame.locator('label[for="confidence"]').isVisible());
  assert.equal(await frame.locator('label[for="target_power"]').isVisible(),false);
  assert.equal(await frame.locator('label[for="alpha"]').isVisible(),false);
  assert.equal(await frame.locator('a[data-value="Compare assumptions"]').isVisible(),false);
  await frame.locator('a[data-value="One study"]').click();
  await frame.locator('#run_one').click();
  await frame.locator('#one_status').filter({hasText:'Results match current inputs'}).waitFor();
  await frame.locator('#one_interpretation').filter({hasText:'confidence interval'}).waitFor();
  assert(!/percentage points/.test(await frame.locator('#one_interpretation').innerText()));
  assert(await frame.locator('#one_plot').isVisible());
  assert(!/p value|reject/i.test(await frame.locator('#one_interpretation').innerText()));
  await page.screenshot({path:'build/planning-routes/estimation.png'});
  console.log('Planning routes passed: core testing, estimation controls, intervals and goal-specific summaries.');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

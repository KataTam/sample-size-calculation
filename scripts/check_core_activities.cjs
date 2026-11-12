/* Core workload, relocated practice and shared report state across both views. */
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const menu=JSON.parse(fs.readFileSync('module/activity-contents.json','utf8'));
 const core=menu.filter(x=>x.route==='Core');
 assert.equal(core.length,3);assert.equal(core.flatMap(ch=>ch.activities).length,4);
 assert.equal(core.find(ch=>ch.chapter==='calculations').activities.length,2);
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const context=await browser.newContext({viewport:{width:1360,height:1000}}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(base+'/book/calculations.html#calculate-sample-size');
  const choice=page.locator('#calculate-sample-size');
  assert.equal(await choice.locator('[data-inline-start][href*="activity=probiotics_calculation"]').count(),1);
  assert.equal(await choice.locator('[data-inline-dedicated][href*="activity=probiotics_calculation"]').count(),1);
  assert.equal(await choice.locator('a[href*="activity=rehabilitation_calculation"]').count(),0);
  assert.equal(await page.locator('#rehabilitation > summary').innerText(),'Additional practice: rehabilitation');
  assert.equal(await page.locator('#rehabilitation').getAttribute('open'),null);
  assert.equal(await page.locator('#rehabilitation a[href*="activity=rehabilitation_calculation"]').count(),1);
  assert.equal(await page.locator('h2').filter({hasText:'Activity: Calculate a sample size'}).count(),0);
  const normalFigure=page.locator('[id="fig:normal-multiplier"]').locator('..');
  assert.equal(await normalFigure.locator('img').count(),1);
  assert.match(await page.locator('#two-means').innerText(),/calculation gives 60 patients per group/);
  const zLink=page.locator('a[data-glossary-term="z-value"]').first();
  await zLink.hover();
  await page.locator('#glossary-tooltip').waitFor({state:'visible'});
  assert.match(await page.locator('#glossary-tooltip').innerText(),/standard normal/);
  assert.equal(await page.locator('#discharge-error-activity').count(),0);
  await page.goto(base+'/book/reporting.html#check-reporting');
  assert.equal(await page.locator('.chapter-quiz').count(),0);
  assert.equal(await page.locator('#report-error-activity .spot-choice[data-error=true]').count(),4);
  for(const [old,target] of [['calculations.html#discharge','exercises.html#discharge'],['feasibility.html#recruitment-error-activity','simulation.html#recruitment-error-activity'],['feasibility.html#treatment-switching','simulation.html#treatment-switching']]){
   await page.goto(base+'/book/'+old);await page.waitForURL('**/book/'+target);await page.waitForLoadState('domcontentloaded');
   assert.equal(await page.locator('[id="'+target.split('#')[1]+'"]').count(),1);
  }
  await page.goto(base+'/assumptions_report/');
  const openGroups=()=>page.locator('.plan-section').evaluateAll(nodes=>nodes.forEach(n=>n.open=true));
  await openGroups();
  assert.equal(await page.locator('textarea:visible').count(),12);
  assert.match(await page.locator('#progress').innerText(),/0 of 12/);
  const coreFields=await page.locator('textarea:visible').evaluateAll(nodes=>nodes.map(n=>n.name));
  for(const name of coreFields)await page.locator('#'+name).fill('My '+name+' answer');
  assert.match(await page.locator('#progress').innerText(),/All 12 prompts answered/);
  assert.equal(await page.locator('#evidence_review').inputValue(),'');
  await page.locator('#advanced-plan > summary').click();
  await page.locator('#evidence_review').waitFor({state:'visible'});
  await page.locator('#evidence_review').fill('Evidence note to preserve across views');
  await page.locator('#advanced-plan > summary').click();
  await page.locator('#evidence_review').waitFor({state:'hidden'});
  assert.equal(await page.locator('#evidence_review').inputValue(),'Evidence note to preserve across views');
  assert.match(await page.locator('#progress').innerText(),/All 12 prompts answered/);
  assert.match(await page.locator('#supporting-study-plan').innerText(),/Evidence note to preserve/);
  await page.reload();
  await page.locator('#resume-plan-button').click();await openGroups();
  assert.match(await page.locator('#progress').innerText(),/All 12 prompts answered/);
  for(const name of coreFields)assert.equal(await page.locator('#'+name).inputValue(),'My '+name+' answer');
  // An advanced link must preserve a saved plan even before the resume prompt is accepted.
  await page.goto(base+'/assumptions_report/?level=advanced&stage=calculation');
  await page.waitForFunction(()=>document.querySelector('[name=plan_level]').value==='advanced');
  assert.equal(await page.locator('#question').inputValue(),'My question answer');
  assert.equal(await page.locator('#evidence_review').inputValue(),'Evidence note to preserve across views');
  assert.equal(await page.locator('#resume-plan').isVisible(),false);
  await page.goto(base+'/quiz/?chapter=reporting');await page.waitForURL('**/book/reporting.html#check-reporting');await page.waitForLoadState('domcontentloaded');
  fs.mkdirSync('build/core-route',{recursive:true});await page.screenshot({path:'build/core-route/report-review.png',fullPage:true});
  assert.deepEqual(errors,[]);
  console.log('Four core activities, calculation choice, four-error check, relocated links, optional practice and shared report-state preservation passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});

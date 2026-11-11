const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const launch=()=>chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 let browser=await launch();
 try{
  let context=await browser.newContext({viewport:{width:1450,height:1000}}),page=await context.newPage();
  async function freshBrowser(){const storageState=await context.storageState();await browser.close();browser=await launch();context=await browser.newContext({viewport:{width:1450,height:1000},storageState});page=await context.newPage();}
  async function app(url,field){await page.goto(base+url);for(let i=0;i<150;i++){for(const f of page.frames())if(await f.locator('#'+field).count()){await f.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);return f;}await page.waitForTimeout(1000);}throw Error('App failed to load '+url);}
  for(const [slug,field] of [['two_proportions','pi1'],['two_means','delta'],['power_explorer','fixed_n'],['dropout_adjustment','n'],['prevalence_precision','anticipated_p'],['sampling_distributions','alpha']]){
   if(process.argv.includes('--layout'))break;
   const f=await app('/'+slug+'/'+(slug==='power_explorer'?'?activity=pain_one_many':''),field);
   if(slug==='power_explorer')await f.waitForFunction(()=>document.querySelector('#fixed_n').value==='20'&&document.querySelector('#combined-many-studies')&&!document.documentElement.classList.contains('shiny-busy'));
   await f.getByRole('tab',{name:'Report',exact:true}).click();
   await f.locator('.plan-transfer-button').waitFor({timeout:60000});
   const record=JSON.parse(await f.locator('.plan-transfer-data').textContent());
   assert(record.lines.length>1);assert(record.lines.some(x=>x.includes('source version:')));assert(record.facts);
   if(slug==='two_proportions')assert.equal(record.facts.analyzable,56);
   if(slug==='two_means')assert.equal(record.facts.analyzable,59);
   const [report]=await Promise.all([context.waitForEvent('page'),f.locator('.plan-transfer-button').click()]);
   await report.waitForLoadState();await report.locator('#accept-transfer').waitFor();
   if(await report.locator('#resume-plan').isVisible())await report.locator('#resume-plan-button').click();
   if(slug==='two_proportions'){
    await report.locator('#plan-title').fill('My continuing trial');
    await report.locator('#plan-section-0').evaluate(el=>el.open=true);
    await report.locator('#question').fill('A question written by the student');
   }else assert.equal(await report.locator('#question').inputValue(),'A question written by the student');
   await report.locator('#accept-transfer').click();
   assert.match(await report.locator('#report').innerText(),new RegExp(record.title.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')));
   await report.close();console.log(slug+': actual current result transfers with software record; student writing preserved');
   await freshBrowser();
  }
  const f=await app('/study/?activity=probiotics_calculation','pi1');
  await f.waitForFunction(()=>Math.abs(Shiny.shinyapp.$inputValues.pi1-.9)<1e-8&&Math.abs(Shiny.shinyapp.$inputValues.pi2-.8)<1e-8);
  assert.equal(await page.locator('#activity optgroup[label="Core calculation: choose one"]').count(),1);
  assert.equal(await f.evaluate(()=>Shiny.shinyapp.$inputValues.dropout),0,'Core calculation precedes the loss adjustment');
  await page.setViewportSize({width:1200,height:950});
  await f.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(e=>e.checkVisibility()));
  const heights=[];for(let i=0;i<20;i++){heights.push(await f.evaluate(()=>document.documentElement.scrollHeight));await page.waitForTimeout(250);if(heights.length>=8&&new Set(heights.slice(-8)).size===1)break;}
  assert.equal(new Set(heights.slice(-8)).size,1,'Split activity layout settles without repeated resizing: '+heights.join(', '));
  fs.mkdirSync('build/week4-qa',{recursive:true});await page.screenshot({path:'build/week4-qa/probiotics-split.png'});
  const recruit=await app('/study/?activity=recruitment','n');assert.equal(await page.locator('#app-panel-title').innerText(),'Adjust recruitment');
  assert.equal(await recruit.locator('#recruitment-advanced').evaluate(el=>el.open),false);
  await page.locator('#activity').selectOption('recruitment_advanced');
  await recruit.waitForFunction(()=>document.getElementById('recruitment-advanced').open);
  if(!await recruit.locator('#different_losses').isVisible())await recruit.locator('.app-settings > summary').click();
  await recruit.locator('#different_losses').check();
  await page.locator('#activity').selectOption('recruitment');
  await recruit.waitForFunction(()=>document.getElementById('different_losses').checked&&document.getElementById('recruitment-advanced').open);
  await recruit.locator('#different_losses').uncheck();
  if(!await recruit.locator('#n').isVisible())await recruit.locator('.app-settings > summary').click();
  await recruit.locator('#n').fill('56');await recruit.locator('#n').press('Tab');
  await page.waitForTimeout(400);await page.reload();
  let restored;for(let i=0;i<120&&!restored;i++){for(const frame of page.frames())if(await frame.locator('.app-resume').count())restored=frame;if(!restored)await page.waitForTimeout(500);}
  await restored.locator('.app-resume > summary').click();await restored.getByRole('button',{name:'Restore previous inputs'}).click();
  await restored.waitForFunction(()=>document.getElementById('n').value==='56');
  console.log('Core presets, recruitment split screen, stable layout and restored inputs passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

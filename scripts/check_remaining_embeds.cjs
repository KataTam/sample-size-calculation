// Real WebR sessions: compact controls, reactive text, figures and preserved work.
const {chromium}=require('playwright'), assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
const routes=[
 ['calculations','rehabilitation_calculation','two_means','#delta','2','#interpretation','#allocation_plot',/target difference of 2 units/],
 ['calculations','recruitment','dropout_adjustment','#dropout-number','10','#recruitment_interpretation','#dropout_plot',/63 per group \(126 in total\)/],
 ['estimation-planning','prevalence','prevalence_precision','#anticipated_p-number','30','#precision_text','#sample_plot',/323 completed assessments/],
 ['estimation-planning','pilot_feasibility','prevalence_precision','#fixed_n','100','#precision_text','#sample_plot',/With 100 participants/],
 ['estimation-planning','mean_precision','power_explorer','#precision-sd','6','#precision-interpretation','#precision-curve',/SD of 6 units/],
 ['curves','pain_curves','power_explorer','#fixed_n','60','#overview_text','#planning_plot',/With 60 analyzable participants per group/],
 ['curves','alpha_beta','sampling_distributions','#n-number','100','#explanation','#distributions',/With 100 observations/],
 ['simulation','pain_simulation','power_explorer','#fixed_n','80','#many_status','#distribution',/n = 80 analyzable per group/],
 ['study-designs','recruitment_advanced','dropout_adjustment','#dropout-number','20','#recruitment_interpretation','#dropout_plot',/70 per group \(140 in total\)/]
].filter(r=>!process.argv[3]||process.argv[3].split(',').includes(r[1]));
(async()=>{const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
try{fs.mkdirSync('build/remaining-embeds',{recursive:true});
for(const [chapter,id,engine,input,value,result,figure,expected] of routes){
 console.log('Checking '+id);
 const context=await browser.newContext({viewport:{width:1360,height:1000}}),page=await context.newPage();
 page.setDefaultTimeout(90000);const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto(`${base}/book/${chapter}.html`);
 const card=page.locator(`[data-activity="${id}"]`);
 await card.evaluate(el=>{for(let p=el.parentElement;p;p=p.parentElement)if(p.tagName==='DETAILS')p.open=true;});
 assert.equal(await page.locator('.inline-activity iframe').count(),0);
 await card.locator('[data-inline-start]').click();
 let app;for(let i=0;i<180&&!app;i++){
  for(const f of page.frames())if(await f.locator(input.replace('-number','')).count())app=f;
  if(!app)await page.waitForTimeout(1000);
 }
 assert(app,'App loaded: '+id);
 await app.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1 && document.documentElement.classList.contains('tutorial-embedded'));
 // The case arrives after the initial Shiny connection. Await its values
 // before editing, so a startup update cannot overwrite the test input.
 if(id==='rehabilitation_calculation')await app.waitForFunction(()=>document.querySelector('#delta').value==='3' && /target difference of 3 units/.test(document.querySelector('#interpretation').textContent));
 if(['prevalence_precision','sampling_distributions'].includes(engine))await app.waitForFunction(()=>/Loaded shared case:/.test(document.querySelector('#bridge_status')?.textContent||''));
 if(id==='pilot_feasibility')await app.waitForFunction(()=>document.querySelector('#fixed_n').value==='40');
 if(id==='mean_precision')await app.waitForFunction(()=>document.documentElement.classList.contains('single-population-mode'));
 if(id==='pain_curves'){
  await app.waitForFunction(()=>document.querySelector('#fixed_n').value==='100');
  await app.locator('a[data-value="Compare assumptions"]').click();
  await app.waitForFunction(()=>/100 analyzable/.test(document.querySelector('#comparison_text').textContent));
  const comparison=await app.locator('#comparison_table').innerText();
  for(const value of ['59.2%','82.8%','99.2%','217','124','56'])assert(comparison.includes(value),value);
  await app.locator('a[data-value="Explore assumptions"]').click();
 }
 if(id==='pain_simulation'){
  await app.waitForFunction(()=>document.querySelector('#activity_choice').value==='pain_simulation' && Shiny.shinyapp.$inputValues.goal==='fixed');
  await app.waitForFunction(()=>document.querySelector('#fixed_n').value==='100');
  await app.locator('a[data-value="Many studies"]').click();
 }
 await app.waitForFunction(()=>!document.documentElement.classList.contains('shiny-busy'));
 if(id==='alpha_beta'){
  assert.equal(await app.locator('#alpha-number').inputValue(),'5','Moved alpha control retains percentage units');
  await app.locator('#alpha-number').fill('2.5');await app.locator('#alpha-number').press('Enter');
  await app.waitForFunction(()=>/Type I error probability 2.5%/.test(document.querySelector('#operating_summary')?.textContent||document.body.textContent));
 }
 if(id==='recruitment_advanced'){
  await app.waitForFunction(()=>Shiny.shinyapp.$inputValues.activity_request?.activity==='recruitment_advanced' && document.querySelector('#recruitment-advanced').open);
  await app.waitForFunction(()=>{const img=document.querySelector('#dropout_plot img');return img?.complete&&img.naturalWidth>0&&!document.documentElement.classList.contains('shiny-busy');});
  await app.locator('#different_losses').scrollIntoViewIfNeeded();
  // The first plot and expanded controls resize the outer iframe. Its movement
  // is outside the checkbox's own frame, so wait for that layout to settle too.
  await page.waitForFunction(activity=>{
   const frame=document.querySelector(`[data-activity="${activity}"] iframe`),r=frame.getBoundingClientRect();
   const value=[r.x,r.y,r.width,r.height].map(v=>Math.round(v)).join(',');
   const old=window.recruitmentFrameStable;
   if(!old||old.value!==value){window.recruitmentFrameStable={value,since:performance.now()};return false;}
   return performance.now()-old.since>=500;
  },id);
  await app.locator('#different_losses').check();
 }
 await app.locator(input).fill(value);await app.locator(input).press(input.endsWith('-number')?'Enter':'Tab');
 if(id==='pain_simulation'){
  await app.waitForFunction(()=>Object.entries(Shiny.shinyapp.$inputValues).some(([key,value])=>key.split(':')[0]==='fixed_n' && Number(value)===80));
  await page.waitForTimeout(500);
  await app.locator('#run_many').click();
 }
 await app.waitForFunction(([selector,pattern])=>new RegExp(pattern).test(document.querySelector(selector)?.textContent||''),[result,expected.source]).catch(async error=>{
  console.error(await app.evaluate(selector=>({text:document.querySelector(selector)?.textContent,n:document.querySelector('#fixed_n')?.value,activity:document.querySelector('#activity_choice')?.value,errors:[...document.querySelectorAll('.shiny-output-error')].map(e=>e.textContent)}),result));throw error;
 });
 await app.locator(figure+' img').waitFor();
 await app.waitForFunction(selector=>{const i=document.querySelector(selector+' img');return i?.complete&&i.naturalWidth>0;},figure);
 const control=await app.locator(input).boundingBox(),plot=await app.locator(figure).boundingBox();
 assert(control.y+control.height<plot.y,'Controls appear above the figure: '+id);
 assert.equal(await app.locator('.shiny-output-error:not(.shiny-output-error-validation)').count(),0);
 const before=await app.locator(result).textContent();
 await card.locator('[aria-label="Close app window"]').click();await card.locator('[data-inline-start]').click();
 assert.equal(await app.locator(input).inputValue(),value,'Closing preserves the selected value');
 assert.equal(await app.locator(result).textContent(),before,'Closing preserves results');
 await page.waitForTimeout(600);
 const dedicated=card.locator('[data-inline-dedicated]');
 assert.equal(await dedicated.getAttribute('href'),`${base}/${engine}/?activity=${id}`);
 assert.equal(await dedicated.getAttribute('target'),'_blank');
 assert(await dedicated.evaluate(el=>el.getBoundingClientRect().top>=el.closest('.inline-activity').querySelector('iframe').getBoundingClientRect().bottom));
 await page.setViewportSize({width:1360,height:1700});
 await card.evaluate(el=>el.scrollIntoView({block:'start'}));await page.waitForTimeout(600);
 await page.screenshot({path:`build/remaining-embeds/${id}-desktop.png`});
 await page.setViewportSize({width:390,height:844});await page.waitForTimeout(800);
 await page.locator('.book').evaluate(el=>el.classList.remove('with-summary'));
 await card.evaluate(el=>el.scrollIntoView({block:'start'}));await page.waitForTimeout(600);
 assert(await app.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'No horizontal scrolling in '+id);
 assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
 assert((await card.locator('iframe').boundingBox()).width>=300,'Readable mobile frame width');
 await page.screenshot({path:`build/remaining-embeds/${id}-mobile.png`});
 assert.deepEqual(errors,[]);assert.equal(context.pages().length,1);
 console.log(id+': controls, updated result, figure, preserved inputs, dedicated link and mobile passed.');
 await context.close();
}
}finally{await browser.close();}})().catch(e=>{console.error(e);process.exit(1)});

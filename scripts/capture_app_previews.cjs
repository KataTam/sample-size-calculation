/* Actual app screenshots for the tutorial's clickable previews.
 * Run against a built local site after changing an app's visible interface.
 * Screenshots show the named activity; no student entries are prefilled.
 */
const {chromium}=require('playwright');
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
const ids=(process.argv[3]||'pain_one_many,probiotics_calculation,rehabilitation_calculation,recruitment,assumptions_report,mean_precision,prevalence,pilot_feasibility,pain_curves,alpha_beta,pain_simulation,recruitment_advanced,design_questionnaire').split(',');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
  const context=await browser.newContext({viewport:{width:1120,height:760},deviceScaleFactor:1});
  const cases=await (await context.request.get(base+'/teaching-cases.json')).json();
  fs.mkdirSync('figures/app-previews',{recursive:true});
  for(const id of ids){
   console.log('Loading preview for '+id);
   const record=Array.isArray(cases)?cases.find(c=>c.id===id):cases[id]; assert(record,id);
   const page=await context.newPage();page.setDefaultTimeout(120000);
   let clip;
   if(!['assumptions_report','design_questionnaire'].includes(record.app))await page.setViewportSize({width:1120,height:id==='mean_precision'?1500:1200});
   const embedded=!['assumptions_report','design_questionnaire'].includes(record.app);
   await page.goto(`${base}/${record.app}/?activity=${id}${embedded?'&embedded=1':''}`,{waitUntil:'domcontentloaded'});
   if(!['assumptions_report','design_questionnaire'].includes(record.app)){
    let app;
    for(let i=0;i<180&&!app;i++){
     for(const frame of page.frames())if(await frame.evaluate(()=>Boolean(window.Shiny?.shinyapp?.$socket?.readyState===1)).catch(()=>false))app=frame;
     if(!app)await page.waitForTimeout(1000);
    }
    assert(app,id+' Shiny session ready');
    // Case initialization follows the activity query parameter through the app bridge.
    if(id==='rehabilitation_calculation')await app.waitForFunction(()=>document.querySelector('#delta').value==='3');
    if(['prevalence_precision','sampling_distributions'].includes(record.app))await app.waitForFunction(()=>/Loaded shared case:/.test(document.querySelector('#bridge_status')?.textContent||''));
    if(['pain_one_many','pain_curves','pain_simulation'].includes(id))await app.waitForFunction(n=>document.querySelector('#fixed_n').value===String(n),record.inputs.fixed_n);
    await app.waitForFunction(()=>!document.querySelector('.shiny-busy'));
    if(id==='pain_one_many') {
     await app.locator('#run_one').click();
     await app.locator('#sampling-journey svg').waitFor({state:'visible'});
    }else if(id==='pain_simulation') {
     await app.locator('#run_many').click();
    }else if(id==='mean_precision'){
     await app.waitForFunction(()=>Shiny.shinyapp.$inputValues.goal==='precision' && document.documentElement.classList.contains('single-population-mode'));
     await app.locator('#precision-view a[data-value="Overview"]').click();
     await app.locator('#precision-result').filter({hasText:'analyzable participants in total'}).waitFor();
    }else if(!['pain_simulation','alpha_beta'].includes(id)){
     const overview=app.getByRole('tab',{name:'Overview',exact:true});
     if(await overview.count())await overview.click();
    }
    await app.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(el=>el.checkVisibility()));
    const errors=await app.locator('.shiny-output-error:not(.shiny-output-error-validation)').allTextContents();
    assert.deepEqual(errors,[],id+' rendered without an app error');
    await app.waitForFunction(()=>[...document.querySelectorAll('.shiny-plot-output img')].filter(i=>i.checkVisibility()).every(i=>i.complete&&i.naturalWidth>0));
    const sidebar=await app.locator(id==='mean_precision'?'.single-population-inputs':'.well').first().boundingBox();
    if(sidebar){
     const endSelector={two_means:'#interpretation',two_proportions:'#interpretation',prevalence_precision:'#precision_text',
      dropout_adjustment:'#recruitment_interpretation',sampling_distributions:'#explanation'}[record.app] ||
      (id==='mean_precision'?'#precision-interpretation':id==='pain_curves'?'#overview_text':id==='pain_simulation'?'#many_text':'#journey-reading');
     const bottom=await app.evaluate(selector=>Math.max(...[...document.querySelectorAll('.shiny-plot-output,'+selector+',#sampling-journey')]
      .filter(el=>el.checkVisibility()).map(el=>el.getBoundingClientRect().bottom+scrollY+60)),endSelector);
     clip={x:0,y:Math.floor(sidebar.y),width:1120,height:Math.ceil(Math.max(700,bottom-sidebar.y))};
     await page.setViewportSize({width:1120,height:Math.ceil(clip.y+clip.height+30)});
     await page.waitForTimeout(400);
    }
   } else {
    await page.locator('main').waitFor();
   }
   await page.evaluate(()=>document.fonts.ready);
   const file=`figures/app-previews/${id}.png`;
   await page.screenshot({path:file,...(clip?{clip}:{})});
   // Keep a running preview server in sync without another complete rebuild.
   const served=path.join('_site',file);fs.mkdirSync(path.dirname(served),{recursive:true});fs.copyFileSync(file,served);
   console.log('Captured '+id+' from '+record.app);await page.close();
  }
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

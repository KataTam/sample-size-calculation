// Exercise real exported R apps, including iframe resizing and saved sessions.
const {chromium}=require('playwright'), assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 fs.mkdirSync('build/inline-apps',{recursive:true});
 try {
  for(const [chapter,id,engine,selector] of [
   ['calculations','probiotics_calculation','two_proportions','#pi1'],
   ['clinical-question','pain_one_many','power_explorer','#fixed_n']].filter(row=>!process.argv[3] || row[1]===process.argv[3])) {
   const context=await browser.newContext({viewport:{width:1360,height:1100}}),page=await context.newPage(),errors=[];
   console.log(`Starting ${id}`);
   page.on('pageerror',e=>errors.push(e.message));
   const failed=[];page.on('requestfailed',r=>failed.push({url:r.url(),error:r.failure()?.errorText}));
   await page.goto(`${base}/book/${chapter}.html`);
   const card=page.locator(`[data-activity="${id}"]`), iframe=card.locator('iframe');
   assert.equal(await iframe.count(),0,'No R session before the reader starts the app');
   await card.locator('[data-inline-start]').click();
   assert.match(page.url(),new RegExp(`/book/${chapter}.html`));
   let app;
   for(let i=0;i<180;i++){
    for(const candidate of page.frames()) if(await candidate.locator(selector).count())app=candidate;
    if(app)break;await page.waitForTimeout(1000);
   }
   if(!app)console.log(JSON.stringify({frames:page.frames().map(f=>f.url()),failed,errors}));
   assert(app,`${engine} loaded`);
   console.log(`${id}: R app loaded`);
   await app.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
   await app.evaluate(()=>window.inlineSessionSentinel='same session');
   const settle=async()=>{await page.waitForTimeout(500);await app.waitForFunction(()=>!document.documentElement.classList.contains('shiny-busy'));await page.waitForTimeout(350);};
   const dimensions=async()=>{
    await settle();
    const size=await app.evaluate(()=>({content:document.querySelector('body > .container-fluid').getBoundingClientRect().bottom+scrollY,
     height:innerHeight,width:innerWidth,scroll:document.documentElement.scrollWidth}));
    assert(size.height>=size.content-2,JSON.stringify(size));
    assert(size.height<=size.content+25,JSON.stringify(size));
    assert(size.scroll<=size.width+1,'No horizontal scrolling: '+JSON.stringify(size));
   };
   if(engine==='two_proportions'){
    await app.waitForFunction(()=>jQuery('#pi1').data('ionRangeSlider')?.result.from===.9 && document.querySelector('#result').textContent.includes('266'));
    await app.locator('#pi1-number').fill('95');await app.locator('#pi1-number').press('Enter');
    await app.waitForFunction(()=>document.querySelector('#interpretation').textContent.includes('95%'));
    assert(parseFloat(await app.locator('#result .app-value').innerText())<266);
    assert.match(await app.locator('#result .app-value').innerText(),/per group/);
    assert.match(await app.locator('#result').innerText(),/standard.*novel.*in total/s);
    await dimensions();
    const before=await iframe.evaluate(el=>el.offsetHeight);
    await app.locator('details.app-input-group').filter({has:app.locator('#alpha')}).locator('summary').click();
    await dimensions();assert(await iframe.evaluate(el=>el.offsetHeight)>before+70);
    await app.locator('details.app-input-group').filter({has:app.locator('#alpha')}).locator('summary').click();
    await app.locator('a[data-value="Report"]').click();
    await app.locator('#report_preview').filter({hasText:'95%'}).waitFor();
   } else {
     await app.waitForFunction(()=>Number(document.querySelector('#fixed_n').value)===20 && document.documentElement.classList.contains('pain-focus'));
    await app.locator('#inline-study-explanation > summary').click();
    assert((await app.locator('#inline-study-explanation').innerText()).length>150);
    await dimensions();
    await app.locator('#inline-study-explanation > summary').click();
    await app.locator('#one-study-records > summary').click();
    assert.match(await app.locator('#one-study-records').innerText(),/after a single-study simulation/);
    await dimensions();
    await app.locator('#one-study-records > summary').click();
    await app.locator('#fixed_n').fill('40');await app.locator('#fixed_n').press('Tab');
    await app.locator('#run_one').click();
    await app.locator('#sampling-journey svg').waitFor();
    await app.locator('#one_status').filter({hasText:'40 patients per group'}).waitFor();
    await app.locator('#run_journey').click();
    await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('of 20'));
    await app.locator('#journey-pause').click();
    assert.match(await app.locator('#journey-status').innerText(),/Paused/);
    await app.locator('#combined-many-studies > summary').click();
    await app.locator('#run_many').click();
    await app.locator('#distribution img').waitFor({timeout:90000});
    await dimensions();
    await app.locator('#combined-many-studies > summary').click();
    await settle();
    await app.locator('a[data-value="Justify and communicate"]').click();
    try {await app.locator('#report_preview').filter({hasText:'40 patients per group'}).waitFor();}
    catch(error){console.log(await app.evaluate(()=>({n:Shiny.shinyapp.$inputValues.fixed_n,stage:Shiny.shinyapp.$inputValues.stage,report:document.querySelector('#report_preview').outerHTML})));throw error;}
    assert.equal(await app.locator('#justification').isVisible(),false);
    assert.equal(await app.locator('.plan-transfer').count(),0);
    assert.equal(await app.locator('a[data-value="Methods"]').count(),0);
    assert(!/Your reflection/.test(await app.locator('#report_preview').innerText()));
   }
   // Both readable formats work from the nested inline frame.
   for(const format of ['pdf','docx']) {
    const button=app.locator(`[data-report-format="${format}"]`).first();
    const downloadPromise=page.waitForEvent('download',{timeout:90000});await button.click();
    const download=await downloadPromise;
    assert.match(download.suggestedFilename(),new RegExp(`\\.${format}$`));
    const path=await download.path(),bytes=fs.readFileSync(path);
    assert(bytes.length>1000);assert.equal(bytes.subarray(0,format==='pdf'?4:2).toString(),format==='pdf'?'%PDF':'PK');
   }
   await dimensions();
   const expand=card.locator('[aria-label="Expand app"]');await expand.click();
   assert(await card.locator('[role="dialog"]').isVisible());
   await dimensions();
   assert.equal(await app.evaluate(()=>window.inlineSessionSentinel),'same session');
   await app.locator('body').press('Escape');
   await card.locator('[aria-label="Expand app"]').waitFor();
   assert.equal(await page.locator('[inert]').count(),0);
   await card.locator('[aria-label="Close app window"]').click();
   await card.locator('[data-inline-start]').click();
   assert.equal(await app.evaluate(()=>window.inlineSessionSentinel),'same session');
   if(engine==='two_proportions'){
    assert.equal(await app.locator('#pi1-number').inputValue(),'95');
    await app.locator('a[data-value="Overview"]').click();
   }else{
    assert.equal(await app.locator('#fixed_n').inputValue(),'40');
    await app.locator('a[data-value="One study"]').click();
    await app.locator('#lab-settings > summary').click();
    await app.locator('#show_advanced').check();
    await app.locator('#reality-selectized').waitFor({state:'visible'});
    await app.locator('a[data-value="Compare assumptions"]').waitFor({state:'visible'});
    await app.evaluate(()=>jQuery('#reality')[0].selectize.setValue('null'));
    await app.locator('#show_advanced').uncheck();
    await app.waitForFunction(()=>Shiny.shinyapp.$inputValues.reality==='same');
    assert.equal(await app.locator('#reality-selectized').isVisible(),false);
    await app.locator('a[data-value="Compare assumptions"]').waitFor({state:'hidden'});
    await app.locator('#lab-settings > summary').click();
   }
   await dimensions();
   const dedicated=card.locator('[data-inline-dedicated]');
   assert.equal(await dedicated.getAttribute('href'),`${base}/${engine}/?activity=${id}`);
   assert.equal(await dedicated.getAttribute('target'),'_blank');
   assert(await dedicated.evaluate(el=>el.getBoundingClientRect().top>=el.closest('.inline-activity').querySelector('iframe').getBoundingClientRect().bottom));
   await page.setViewportSize({width:1360,height:1700});await dimensions();
   await card.evaluate(el=>el.scrollIntoView({block:'start'}));await page.waitForTimeout(500);
   await page.screenshot({path:`build/inline-apps/${id}-desktop.png`});
   await page.setViewportSize({width:390,height:844});
   await page.locator('.book').evaluate(el=>el.classList.remove('with-summary'));await dimensions();
   await card.evaluate(el=>el.scrollIntoView({block:'start'}));await page.waitForTimeout(500);
   await page.screenshot({path:`build/inline-apps/${id}-mobile.png`});
   // Edge may show its browser-owned download hub while saving a report.
   assert.equal(context.pages().filter(p=>/^https?:/.test(p.url())).length,1);
   assert.deepEqual(errors,[]);
   console.log(`${id}: current results, PDF/Word reports, responsive height, expand/close preservation and dedicated link passed.`);
   await context.close();
  }
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

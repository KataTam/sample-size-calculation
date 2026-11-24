// Legacy links and activity menus reach inline apps without a split view.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const context=await browser.newContext({viewport:{width:1360,height:1000}}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  // Routing does not require downloading and starting each R runtime.
  for(const engine of ['power_explorer','two_means','two_proportions','prevalence_precision','sampling_distributions','dropout_adjustment']){
   await context.route(`**/${engine}/**`,r=>r.fulfill({contentType:'text/html',body:'<!doctype html><title>App routing fixture</title>'}));
  }
  const routes=await (await page.request.get(base+'/activity-routes.json')).json();
  assert.equal(Object.values(routes).filter(path=>path.includes('#activity-')).length,14);
  for(const [id,path] of Object.entries(routes)){
   await page.goto(base+'/study/?activity='+id);
   await page.waitForURL(base+'/'+path);
   assert.equal(await page.locator('#lesson-frame,#app-frame,#panel-separator').count(),0);
   if(path.includes('#activity-')){
    const card=page.locator('#activity-'+id);
    await card.locator('iframe').waitFor();
    assert(await card.locator('iframe').isVisible(),id+' opens inside any collapsed section');
    assert.equal(await card.locator('iframe').count(),1);
   }
  }
  await page.goto(base+'/study/');await page.waitForURL(base+'/book/');
  await page.goto(base+'/study/?activity=unknown');await page.waitForURL(base+'/book/');
  await page.goto(base+'/study/?activity=assumptions_report&stage=calculation');
  await page.waitForURL(base+'/assumptions_report/?activity=assumptions_report&stage=calculation');
  await page.goto(base+'/book/curves.html');
  const link=page.locator('section.normal p a[href$="#activity-pain_curves"]').first();
  await link.click();await page.locator('#activity-pain_curves iframe').waitFor();
  assert.equal(context.pages().length,1,'A prose link uses the current lesson');
  assert.equal(await page.locator('#activity-menu-button').count(),0);
  assert.equal(await page.locator('#report-link').innerText(),'Report');
  const popupPromise=context.waitForEvent('page');await page.locator('#report-link').click();
  const reportPage=await popupPromise;await reportPage.waitForLoadState('domcontentloaded');
  assert.match(reportPage.url(),/assumptions_report\//);await reportPage.close();
  fs.mkdirSync('build/inline-routing',{recursive:true});
  for(const id of ['assumptions_report','design_questionnaire']){
   await page.goto(base+'/'+routes[id]);
   const card=page.locator('#activity-'+id),app=card.frameLocator('iframe');
   const field=id==='assumptions_report'?'#plan-title':'#aim';
   await app.locator(field).waitFor();
   if(id==='assumptions_report')await app.locator(field).fill('Preserved inline plan');
   else await app.locator(field).selectOption('prevalence');
   const value=await app.locator(field).inputValue();
   await card.locator('[aria-label="Expand app"]').click();
   assert.equal(await card.locator('[role="dialog"]').getAttribute('aria-modal'),'true');
   await page.keyboard.press('Escape');
   await card.locator('[aria-label="Close app window"]').click();
   await card.locator('[data-inline-start]').waitFor({state:'visible'});
   // A delayed page-load notification must not reopen a deliberately closed app.
   await page.evaluate(()=>window.dispatchEvent(new Event('load')));
   assert(await card.locator('[data-inline-start]').isVisible());
   await card.locator('[data-inline-start]').click();
   assert.equal(await app.locator(field).inputValue(),value);
   for(const width of [1360,390]){
    await page.setViewportSize({width,height:1000});
    await page.locator('.book').evaluate(el=>el.classList.remove('with-summary'));
    await card.scrollIntoViewIfNeeded();
    await page.waitForTimeout(400);
    assert(await app.locator('html').evaluate(el=>el.scrollWidth<=innerWidth+1));
    assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
    await page.screenshot({path:`build/inline-routing/${id}-${width}.png`});
   }
  }
  assert.deepEqual(errors,[]);
  console.log('Activity routes passed: all legacy cases, prose/menu links, collapsed sections, inline forms, preserved entries, expansion and mobile layout.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

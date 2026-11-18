// Activity previews open in the lesson and preserve their current session.
const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const context=await browser.newContext({viewport:{width:1360,height:1000}}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  // Routing/preview checks do not need to start a WebR session.
  await context.route('**/power_explorer/**',route=>route.fulfill({contentType:'text/html',body:'<!doctype html><title>App routing fixture</title>'}));
  await page.goto(base+'/book/clinical-question.html');
  assert.match(await page.locator('.page-inner').innerText(),/Neravixa/);
  assert.match(await page.locator('#tab\\:pain-pico').evaluate(el=>el.closest('table').innerText),/diabetes mellitus/);
  assert.equal(await page.locator('.app-preview iframe').count(),0);
  assert.equal(await page.locator('.app-preview pre').count(),0,'Preview markup renders as content');
  const preview=page.locator('.app-preview').first();
  await preview.scrollIntoViewIfNeeded();
  await preview.locator('img').evaluate(img=>img.decode());
  assert(await preview.locator('img').evaluate(img=>img.complete&&img.naturalWidth>0));
  fs.mkdirSync('build/app-previews',{recursive:true});
  for(const theme of [0,1,2]){
   await page.locator('.book').evaluate((el,t)=>{el.classList.remove('color-theme-0','color-theme-1','color-theme-2');el.classList.add('color-theme-'+t)},theme);
   assert.equal(await preview.locator('[data-inline-start] img').count(),1);
   assert.equal(await preview.locator('button,.app-preview-action').count(),0,'The screenshot itself opens the app');
   assert(await preview.locator('img').evaluate(img=>img.naturalWidth>=1000));
   await preview.screenshot({path:'build/app-previews/theme-'+theme+'.png'});
  }
  await page.setViewportSize({width:390,height:844});
  await preview.scrollIntoViewIfNeeded();
  assert(await preview.evaluate(el=>{const r=el.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth}));
  await preview.screenshot({path:'build/app-previews/mobile.png'});
  await page.setViewportSize({width:1360,height:1000});
  await preview.locator('[data-inline-start]').click();
  assert.match(page.url(),/book\/clinical-question\.html/);
  assert.equal(context.pages().length,1);
  await preview.locator('iframe[src*="power_explorer"]').waitFor();
  assert.equal(await preview.locator('[aria-label="Expand app"]').innerText(),'\u26f6');
  assert.equal(await preview.locator('[aria-label="Close app window"]').innerText(),'\u00d7');
  assert.match(await preview.locator('[data-inline-dedicated]').getAttribute('href'),/power_explorer\/\?activity=pain_one_many$/);
  await preview.locator('button[aria-label="Close app window"]').click();
  assert(await preview.locator('[data-inline-start]').isVisible());
  assert.equal(await preview.locator('iframe').count(),1,'Closing preserves the existing app frame');
  await page.goto(base+'/book/reporting.html');
  const reportCard=page.locator('#activity-assumptions_report');
  await reportCard.locator('[data-inline-start]').click();
  const report=reportCard.frameLocator('iframe');
  await report.locator('#plan-title').fill('My preserved study title');
  const appFrame=page.frames().find(f=>f.url().includes('/assumptions_report/'));
  await appFrame.evaluate(()=>window.previewSentinel='same app instance');
  await reportCard.locator('[aria-label="Close app window"]').click();
  await reportCard.locator('[data-inline-start]').click();
  assert.equal(await report.locator('#plan-title').inputValue(),'My preserved study title');
  assert.equal(await appFrame.evaluate(()=>window.previewSentinel),'same app instance');
  assert.equal(context.pages().length,1);
  assert.match(page.url(),/book\/reporting\.html/);
  assert.equal(await page.locator('#lesson-frame,#app-frame').count(),0);
  // The complete HTML is assembled from chapter DOMs. Copied initialization
  // flags must not suppress the event bindings on this new document.
  await page.goto(base+'/book/Sample_size_open_module.html');
  assert.equal(await page.locator('.inline-activity').count(),14);
  for(const card of await page.locator('.inline-activity').all()){
    assert.equal(await card.locator('[data-inline-dedicated]').count(),1);
    assert.equal(await card.locator('iframe').count(),0,'Apps start on demand');
  }
  const complete=page.locator('[data-activity="pain_one_many"]');
  await complete.locator('[data-inline-start]').click();
  await complete.locator('iframe[src*="power_explorer"]').waitFor();
  assert.match(page.url(),/book\/Sample_size_open_module\.html$/);
  assert.equal(await complete.locator('[aria-label="Close app window"]').innerText(),'\u00d7');
  assert.deepEqual(errors,[]);
  console.log('App previews passed: responsive themes, inline startup, dedicated links, inline report and preserved answers.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

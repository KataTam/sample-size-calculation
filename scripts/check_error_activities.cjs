// The same review content must work with pointer, keyboard, print and no script.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
const cases={discharge:'exercises',recruitment:'simulation',report:'reporting',software:'appendix'};
const bank=JSON.parse(fs.readFileSync('data/error-activities.json','utf8'));
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  fs.mkdirSync('build/error-reviews',{recursive:true});
  const page=await browser.newPage({viewport:{width:1350,height:1000}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  const axe=process.env.AXE_PATH||require.resolve('axe-core/axe.min.js');
  for(const [name,chapter] of Object.entries(cases)){
   const item=bank[name],parts=item.segments.filter(x=>typeof x.error==='boolean'),count=parts.filter(x=>x.error).length;
   assert(count>0&&count<parts.length,'Include appropriate passages as well as errors');
   await page.goto(`${base}/book/${chapter}.html#${item.id}`,{waitUntil:'networkidle'});
   const root=page.locator('#'+item.id),popup=root.locator('.spot-popover');
   await root.locator('.spot-reset').click();
   assert.equal(await root.locator('.spot-choice[role="button"]').count(),parts.length);
   assert.equal(await root.locator('.spot-found').count(),0);
   const correct=root.locator('.spot-choice[data-error="false"]').first();
   await correct.click();await popup.waitFor({state:'visible'});
   assert.match(await popup.innerText(),/This part is appropriate/);
   assert.equal(await root.locator('.spot-status').innerText(),`0 of ${count} problem areas found.`);
   await page.keyboard.press('Escape');
   await popup.waitFor({state:'hidden'});assert(await correct.evaluate(el=>el===document.activeElement));
   const wrong=root.locator('.spot-choice[data-error="true"]').first();
   await wrong.focus();await page.keyboard.press('Enter');
   await popup.waitFor({state:'visible'});assert.match(await popup.innerText(),/needs correction/);
   assert.equal(await root.locator('.spot-status').innerText(),`1 of ${count} problem areas found.`);
   assert(await popup.locator('a').getAttribute('href'));
   await popup.locator('.spot-close').click();
   await wrong.hover();await popup.waitFor({state:'visible'});
   await popup.hover();assert(await popup.isVisible(),'Revealed explanation remains hoverable');
   await page.keyboard.press('Escape');await popup.waitFor({state:'hidden'});
   await wrong.click();assert.equal(await root.locator('.spot-status').innerText(),`1 of ${count} problem areas found.`);
   await page.keyboard.press('Escape');
   await page.reload({waitUntil:'networkidle'});assert.equal(await root.locator('.spot-found').count(),1);
   await root.locator('.spot-reset').click();assert.equal(await root.locator('.spot-found').count(),0);
   await page.addScriptTag({path:axe});
   const violations=await page.evaluate(async id=>(await axe.run('#'+id)).violations,item.id);
   assert.deepEqual(violations,[],`${name}: accessibility`);
  }
  await page.goto(`${base}/book/reporting.html#report-error-activity`,{waitUntil:'networkidle'});
  const report=page.locator('#report-error-activity');
  for(const theme of [0,1,2]){
   await page.locator('.book').evaluate((el,n)=>{el.classList.remove('color-theme-1','color-theme-2');if(n)el.classList.add('color-theme-'+n);},theme);
   const wrong=report.locator('.spot-choice[data-error="true"]').first();
   await wrong.click();
   await page.addScriptTag({path:axe});
   assert.deepEqual(await page.evaluate(async()=>(await axe.run('#report-error-activity')).violations),[],`theme ${theme}`);
   await page.screenshot({path:`build/error-reviews/report-theme-${theme}.png`});
   await page.keyboard.press('Escape');
  }
  await page.goto(base+'/book/Sample_size_open_module.html',{waitUntil:'networkidle'});
  assert.equal(await page.locator('.spot-activity[data-spot-ready]').count(),4,'Complete HTML rebinds all reviews');
  await page.locator('#report-error-activity .spot-choice[data-error="true"]').first().click();
  assert(await page.locator('#report-error-activity .spot-popover').isVisible());
  await page.evaluate(()=>window.dispatchEvent(new Event('beforeprint')));
  await page.emulateMedia({media:'print'});
  assert.equal(await page.locator('.spot-popover:visible').count(),0);
  assert.equal(await page.locator('.spot-print-marker:visible').count(),Object.values(bank).reduce((n,x)=>n+x.segments.filter(s=>typeof s.error==='boolean').length,0));
  for(const details of await page.locator('.spot-answer-key').all())assert(await details.evaluate(el=>el.open));
  const mobile=await browser.newPage({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  await mobile.goto(base+'/book/reporting.html#report-error-activity',{waitUntil:'networkidle'});
  await mobile.locator('#report-error-activity .spot-choice[data-error="true"]').first().tap();
  const bounds=await mobile.locator('#report-error-activity .spot-popover').boundingBox();
  assert(bounds.x>=0&&bounds.x+bounds.width<=391&&bounds.y>=0&&bounds.y+bounds.height<=845);
  await mobile.screenshot({path:'build/error-reviews/report-mobile.png'});
  await mobile.locator('#report-error-activity .spot-close').tap();
  const offline=await browser.newPage({javaScriptEnabled:false});
  await offline.goto(base+'/book/reporting.html#report-error-activity');
  await offline.locator('#report-error-activity .spot-answer-key > summary').click();
  assert(await offline.locator('#report-error-activity .spot-answer-key li').first().isVisible());
  assert.equal(await offline.locator('#report-error-activity .spot-tools').isVisible(),false);
  assert.deepEqual(errors,[]);
  console.log('Error reviews passed: four banks, appropriate/error choices, progress, persistence/reset, keyboard, hover, touch, themes, links, standalone HTML, print and no-script answers.');
 }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exit(1)});

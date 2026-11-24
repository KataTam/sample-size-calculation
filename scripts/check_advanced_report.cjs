/* Advanced prompts must follow selections and survive report export/restoration. */
const assert=require('node:assert/strict'), fs=require('node:fs'), path=require('node:path'), http=require('node:http');
const {chromium}=require('playwright');
const {saveReportPair}=require('./report_test_helpers.cjs');
(async()=>{
 const root=path.resolve(process.argv.includes('--source')?'site':'_site');
 const server=http.createServer((req,res)=>{
  const url=new URL(req.url,'http://local'),file=path.resolve(root,'.'+decodeURIComponent(url.pathname),url.pathname.endsWith('/')?'index.html':'');
  if(!file.startsWith(root+path.sep)){res.writeHead(403).end();return;}
  try{res.setHeader('Content-Type',({'.html':'text/html','.js':'text/javascript','.json':'application/json','.css':'text/css'})[path.extname(file)]||'application/octet-stream');res.end(fs.readFileSync(file));}catch(_){res.writeHead(404).end();}
 });
 await new Promise(r=>server.listen(0,'127.0.0.1',r));
 let browser;
 try{
  browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
  const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));page.on('dialog',d=>d.accept());
  await page.goto(`http://127.0.0.1:${server.address().port}/assumptions_report/`);
  assert.equal(await page.locator('#advanced-features').isVisible(),false);
  assert.equal(await page.locator('#field-cluster_details').isVisible(),false);
  const initialUrl=page.url();
  await page.locator('#advanced-plan > summary').click();
  assert.equal(context.pages().length,1,'Additional prompts stay in this page');
  assert.equal(page.url(),initialUrl,'Additional prompts do not navigate away');
  await page.locator('#study-settings > summary').click();
  await page.locator('#study_type').selectOption('other');
  await page.locator('[data-plan-feature=clustered]').check();
  await page.locator('[data-plan-feature=multiple]').check();
  while(await page.locator('.plan-section:not([open]) > summary').count())await page.locator('.plan-section:not([open]) > summary').first().click();
  await page.locator('#question').fill('Compare clinic-level strategies.');
  await page.locator('#cluster_details').fill('24 clinics with 30 patients each; ICC 0.02.');
  await page.locator('#testing_details').fill('Both co-primary outcomes must meet the prespecified rule.');
  await page.locator('#software').fill('External procedure v2; inputs and code archived.');
  for(const part of ['#calculation-summary']){
   assert.match(await page.locator(part).innerText(),/24 clinics/);
   assert.match(await page.locator(part).innerText(),/Both co-primary outcomes/);
  }
  assert.doesNotMatch(await page.locator('#planning').getAttribute('data-example-answer'),/30 percentage points|neravixa/);
  await page.locator('[data-plan-feature=clustered]').uncheck();
  assert.equal(await page.locator('#field-cluster_details').isVisible(),false);
  assert.doesNotMatch(await page.locator('#calculation-summary').innerText(),/24 clinics/);
  assert.equal(await page.locator('#cluster_details').inputValue(),'24 clinics with 30 patients each; ICC 0.02.');
  await page.locator('[data-plan-feature=clustered]').check();
  await page.locator('#advanced-plan > summary').click();
  await page.waitForFunction(()=>document.querySelector('[name=plan_level]').value==='core');
  assert.equal(await page.locator('#advanced-features').isVisible(),false);
  await page.locator('#advanced-plan > summary').click();
  await page.waitForFunction(()=>document.querySelector('[name=plan_level]').value==='advanced');
  assert.match(await page.locator('#calculation-summary').innerText(),/24 clinics/);
  await page.locator('#outcome').selectOption('survival');
  assert.equal(await page.locator('[data-plan-feature=survival]').isChecked(),true);
  await page.locator('#survival_details').fill('120 events after 18 months of recruitment and 12 months minimum follow-up.');
  assert.match(await page.locator('#variation-question').innerText(),/distribution or event assumptions/);
  assert.match(await page.locator('#report').innerText(),/time-to-event outcome/);
  assert.equal(await page.locator('#example-calculation').isVisible(),false);
  fs.mkdirSync('build/advanced-planning-qa',{recursive:true});
  await page.locator('#advanced-features').scrollIntoViewIfNeeded();
  await page.screenshot({path:'build/advanced-planning-qa/conditional-prompts-desktop.png'});
  await page.setViewportSize({width:400,height:900});
  await page.locator('#advanced-features').scrollIntoViewIfNeeded();
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),'Advanced options fit a narrow screen');
  await page.screenshot({path:'build/advanced-planning-qa/conditional-prompts-mobile.png'});
  await page.setViewportSize({width:1440,height:1000});
  await page.locator('#file-actions > summary').click();
  const exported=await saveReportPair(page,page,'#save','#save-word','advanced-study-plan');
  assert.match(exported.html,/120 events/);assert.match(exported.html,/24 clinics/);
  await page.locator('#saved-work > summary').click();
  const pending=page.waitForEvent('download');await page.locator('#save-work').click();
  const file=await pending, saved=JSON.parse(fs.readFileSync(await file.path(),'utf8'));
  assert.equal(saved.entries.survival_details,await page.locator('#survival_details').inputValue());
  await page.locator('#clear').click();
  assert.equal(await page.locator('#outcome').inputValue(),'binary');
  await page.locator('#restore').setInputFiles({name:'advanced.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(saved))});
  await page.waitForFunction(()=>document.querySelector('#status').textContent==='Saved entries restored.');
  assert.equal(await page.locator('[data-plan-feature=clustered]').isChecked(),true);
  assert.match(await page.locator('#calculation-summary').innerText(),/120 events/);
  const invalid={...saved,entries:{...saved.entries,advanced_features:'unknown'}};
  await page.locator('#restore').setInputFiles({name:'invalid.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(invalid))});
  await page.waitForFunction(()=>document.querySelector('#status').textContent.startsWith('Entries were not changed.'));
  assert.equal(await page.locator('#outcome').inputValue(),'survival');
  const legacy={schema:saved.schema,version:1,entries:{question:'Earlier plan'}};
  await page.locator('#restore').setInputFiles({name:'legacy.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(legacy))});
  await page.waitForFunction(()=>document.querySelector('#question').value==='Earlier plan');
  assert.equal(await page.locator('[name=advanced_features]').inputValue(),'');
  assert.equal(await page.locator('#outcome').inputValue(),'binary');
  assert.deepEqual(errors,[]);
  console.log('Advanced selections, conditional prompts, current PDF/Word exports, saved work, legacy imports and invalid-file protection passed.');
 }finally{if(browser)await browser.close();await new Promise(r=>server.close(r));}
})().catch(e=>{console.error(e);process.exit(1)});

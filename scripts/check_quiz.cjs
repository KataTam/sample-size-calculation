const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const base=process.argv[2] || 'http://127.0.0.1:8769';
const bank=JSON.parse(fs.readFileSync('site/quiz/questions.json','utf8'));
(async()=>{
 assert.equal(new Set(bank.questions.map(q=>q.id)).size,bank.questions.length);
 for(const q of bank.questions){
  assert.equal(q.options.length,4);
  assert.equal(new Set(q.options).size,4);
  assert(q.answer>=0 && q.answer<4);
  const [file,anchor]=q.link.split('#');
  assert(fs.readFileSync('_site/book/'+file,'utf8').includes(`id="${anchor}"`),'Missing feedback target '+q.link);
 }
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const page=await browser.newPage({viewport:{width:1200,height:950}});
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  for(const ch of Object.keys(bank.chapters)){
   await page.goto(base+'/quiz/?chapter='+ch);
   await page.waitForFunction(()=>!document.getElementById('start').disabled);
   assert.equal(await page.locator('#chapter').inputValue(),ch);
   await page.locator('#route').selectOption('all');
   await page.locator('#start').click();
   assert.equal(await page.locator('fieldset').count(),bank.questions.filter(q=>q.chapter===ch).length);
   assert.equal(await page.locator('#results').isVisible(),false);
  }
  await page.goto(base+'/quiz/');
  await page.waitForFunction(()=>!document.getElementById('start').disabled);
  await page.locator('#start').click();
  const core=bank.questions.filter(q=>q.level==='core');
  assert.equal(await page.locator('fieldset').count(),core.length);
  await page.locator('button[type=submit]').click();
  assert.equal(await page.locator('#results').isVisible(),false,'All questions require an answer');
  for(const [i,q] of core.entries())await page.locator(`input[name="${q.id}"][value="${i<2?(q.answer+1)%4:q.answer}"]`).check();
  await page.locator('button[type=submit]').click();
  assert((await page.locator('#score').innerText()).startsWith(`${core.length-2} of ${core.length} correct`));
  assert.equal(await page.locator('#review a').count(),core.length);
  await page.locator('#retry').click();
  assert.equal(await page.locator('fieldset').count(),2);
  for(const q of core.slice(0,2))await page.locator(`input[name="${q.id}"][value="${q.answer}"]`).check();
  await page.locator('button[type=submit]').click();
  assert((await page.locator('#score').innerText()).includes('2 of 2 correct'));
  assert.equal(await page.locator('#retry').isVisible(),false);
  await page.locator('#again').click();
  await page.locator('#route').selectOption('all');
  await page.locator('#start').click();
  assert.equal(await page.locator('fieldset').count(),bank.questions.length);
  for(const q of bank.questions)await page.locator(`input[name="${q.id}"][value="${q.answer}"]`).check();
  await page.locator('button[type=submit]').click();
  assert((await page.locator('#score').innerText()).includes('100%'));
  fs.mkdirSync('build/browser-checks',{recursive:true});
  await page.screenshot({path:'build/browser-checks/quiz-results.png'});
  await page.setViewportSize({width:390,height:844});
  await page.goto(base+'/quiz/?chapter=power');
  await page.waitForFunction(()=>!document.getElementById('start').disabled);
  await page.locator('#start').click();
  await page.screenshot({path:'build/browser-checks/quiz-mobile.png'});
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
  await page.goto(base+'/assumptions_report/');
  await page.locator('#software').fill('Pooled score test; R 4.5.1; recorded source commit and saved input file');
  assert((await page.locator('#report').innerText()).includes('R 4.5.1'));
  const saved=page.waitForEvent('download');
  await page.locator('#download').click();
  const download=await saved;
  assert(fs.readFileSync(await download.path(),'utf8').includes('recorded source commit'));
  assert.deepEqual(errors,[]);
  console.log('Quiz: all chapter filters, core/advanced coverage, required answers, scores, feedback anchors, retry and mobile layout passed.');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});

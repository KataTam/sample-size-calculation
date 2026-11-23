// Check the single display against actual batch results, including saved assumptions.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true});
 try{
  const page=await browser.newPage({viewport:{width:1360,height:1100}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(base+'/book/clinical-question.html');
  assert.equal(await page.locator('.sidebar-level').count(),0);
  const chapter=await page.locator('.page-inner').innerText();
  assert(chapter.indexOf('Scenario 1:')<chapter.indexOf('These scenarios give'));
  assert(chapter.includes('True positive (power)'));
  const card=page.locator('[data-activity="pain_one_many"]');
  await card.locator('[data-inline-start]').click();
  let app;
  for(let i=0;i<150&&!app;i++){
   for(const frame of page.frames())if(await frame.locator('#fixed_n').count())app=frame;
   if(!app)await page.waitForTimeout(1000);
  }
  assert(app,'Inline app loaded');
  await app.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1&&document.querySelector('#fixed_n').value==='20');
  assert.equal(await app.locator('#simulation_target').isVisible(),false);
  assert(await app.locator('#run_many').isVisible());
  await app.locator('#run_journey').click();
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('of 20'));
  await app.locator('#journey-finish').click();
  assert.match(await app.locator('#journey-status').innerText(),/Trial 20 of 20/);
  assert.equal(await app.locator('[data-trial-estimate]').count(),19);
  assert(await app.locator('#journey-finish').isDisabled());
  await app.locator('#journey-motion').check();
  const began=Date.now();await app.locator('#journey-replay').click();
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('Trial 20 of 20')&&document.querySelector('#journey-pause').disabled,null,{timeout:8000});
  assert(Date.now()-began<8000,'Reduced motion completes promptly');
  await app.locator('#run_many').click();
  await app.waitForFunction(()=>document.querySelectorAll('[data-batch-bin]').length===40,null,{timeout:90000});
  assert.equal(await app.locator('#distribution').isVisible(),false);
  assert.match(await app.locator('#sampling-journey').innerText(),/5000 trials, each with 20/);
  await app.locator('#many_text').filter({hasText:'batch of estimates'}).waitFor();
  await app.getByText('P values in the latest batch',{exact:true}).click();
  await app.locator('#p_value_interpretation').filter({hasText:'5000 trials'}).waitFor();
  assert.match(await app.locator('#p_value_interpretation').innerText(),/p = 0.05/);
  assert.match(await app.locator('#p_value_interpretation').innerText(),/rejected the null/);
  await app.locator('#fixed_n').fill('50');await app.locator('#fixed_n').press('Tab');
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('Inputs changed'));
  assert.match(await app.locator('#p_value_interpretation').innerText(),/20 participants per group/);
  await app.locator('#run_many').click();
  await app.locator('[data-reference-batch="20"]').waitFor();
  await app.locator('#p_value_interpretation').filter({hasText:'50 participants per group'}).waitFor();
  fs.mkdirSync('build/chapter-one-review',{recursive:true});
  await app.locator('#sampling-journey').screenshot({path:'build/chapter-one-review/shared-display.png'});
  await page.setViewportSize({width:390,height:844});
  await page.locator('.book').evaluate(el=>el.classList.remove('with-summary'));
  await page.waitForTimeout(700);
  assert(await app.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await app.locator('#sampling-journey').screenshot({path:'build/chapter-one-review/shared-display-mobile.png'});
  await app.locator('#run_one').click();
  await app.waitForFunction(()=>document.querySelector('[data-moving-estimate]')&&!document.querySelector('[data-batch-bin]'));
  assert.deepEqual(errors,[]);
  console.log('Chapter 1: clinical scenarios, unlabelled contents, instant finish, reduced motion, shared batch display, saved p-value interpretation and mobile width passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

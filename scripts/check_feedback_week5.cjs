// Check changes that affect navigation and the identity of shuffled quiz answers.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
const bank=JSON.parse(fs.readFileSync('site/quiz/questions.json','utf8'));
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const page=await browser.newPage({viewport:{width:1360,height:1000}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  // A deterministic shuffle prevents a chance unchanged order making this check flaky.
  await page.addInitScript(()=>{Math.random=()=>0;});
  await page.goto(base+'/book/estimation-planning.html',{waitUntil:'networkidle'});
  assert.equal(await page.locator('.sidebar-core').count(),0);
  assert.equal(await page.locator('.sidebar-extension').count(),0);
  const local=await page.locator('.page-inner a[href]').evaluateAll(xs=>xs.filter(a=>{const u=new URL(a.href);return u.pathname===location.pathname&&u.hash.startsWith('#fig:')}).map(a=>({href:a.getAttribute('href'),target:a.target,label:a.getAttribute('aria-label')})));
  assert(local.length>0,'Chapter has figure references');
  assert(local.every(a=>!a.target&&!/opens in a new tab/.test(a.label||'')));
  const pagesBefore=page.context().pages().length;
  await page.locator(`.page-inner a[href="${local[0].href}"]`).first().click();
  await page.waitForFunction(hash=>location.hash===hash,new URL(local[0].href,page.url()).hash);
  assert.equal(page.context().pages().length,pagesBefore,'Figure navigation keeps the current tab');
  await page.waitForFunction(()=>document.querySelector('.page-inner a[href="https://www.bmj.com/content/355/bmj.i5239"]')?.target==='_blank');
  await page.goto(base+'/book/appendix.html#simulation-reproducibility');
  await page.waitForURL('**/simulation.html#simulation-reproducibility');
  assert.equal(await page.locator('#simulation-reproducibility').count(),1,'Old implementation links resolve to Chapter 6');

  for(const chapter of bank.chapter_checks){
   await page.goto(`${base}/book/${chapter}.html`);
   const root=page.locator('.chapter-quiz');
   await root.evaluate(q=>q.closest('details').open=true);
   const state=()=>root.locator('fieldset:not([hidden])').evaluateAll(qs=>qs.map(q=>({id:q.dataset.question,options:[...q.querySelectorAll('input')].map(i=>i.value)})));
   const initial=await state();
   assert.deepEqual(await root.locator('.quiz-answer').evaluateAll(xs=>xs.map(x=>x.dataset.question)),await root.locator('fieldset').evaluateAll(xs=>xs.map(x=>x.dataset.question)),'Exportable answer key follows question order');
   const original=bank.questions.filter(q=>q.chapter===chapter&&q.chapter_check!==false).map(q=>q.id);
   if(original.length>1)assert.notDeepEqual(initial.map(x=>x.id),original,'Fresh chapter questions shuffle');
   for(const q of await root.locator('fieldset:not([hidden])').all()){
    const id=await q.getAttribute('data-question'),answer=await q.getAttribute('data-answer');
    const displayed=await q.locator(`input[value="${answer}"] + span`).innerText();
    const detail=root.locator(`.quiz-answer[data-question="${id}"]`);
    assert.equal(await detail.locator('.quiz-correct-option').innerText(),displayed,'Correct letter follows displayed choice');
    assert.equal(await detail.locator('.quiz-number').textContent(),await q.locator('.quiz-number').textContent(),'Answer numbering follows shuffled questions');
    for(const row of await detail.locator('.quiz-option-feedback [data-option]').all()){
     const value=await row.getAttribute('data-option');
     assert.equal(await row.locator('.quiz-option-text').innerText(),await q.locator(`input[value="${value}"] + span`).innerText());
    }
    await q.locator(`input[value="${(Number(answer)+1)%4}"]`).check();
   }
   await page.reload();
   await root.evaluate(q=>q.closest('details').open=true);
   assert.deepEqual(await state(),initial,'Reload preserves question and option order');
   assert.equal(await root.locator('input:checked').count(),initial.length);
   await root.locator('button[type=submit]').click();
   assert.match(await root.locator('.quiz-score').innerText(),/^0 of /);
   await root.locator('.quiz-retry').click();
   if(initial.length>1)assert.notDeepEqual((await state()).map(x=>x.id),initial.map(x=>x.id),'Retry shuffles missed questions');
  }
  await page.goto(base+'/quiz/?chapter=estimation-planning');
  await page.locator('#start:not([disabled])').click();
  const choices={};
  for(const q of await page.locator('fieldset').all()){
   const id=await q.getAttribute('data-question'),record=bank.questions.find(q=>q.id===id);
   choices[id]=await q.locator(`input[value="${record.answer}"] + span`).innerText();
   await q.locator(`input[value="${record.answer}"]`).check();
  }
  await page.locator('button[type=submit]').click();
  assert.match(await page.locator('#score').innerText(),/100%/);
  await page.locator('#review details').evaluateAll(xs=>xs.forEach(x=>x.open=true));
  const review=await page.locator('#review').innerText();
  for(const label of Object.values(choices))assert(review.includes('Correct answer: '+label));
  const noScript=await browser.newPage({javaScriptEnabled:false});
  await noScript.goto(base+'/book/estimation-planning.html');
  for(const q of await noScript.locator('.chapter-quiz fieldset').all()){
   const id=await q.getAttribute('data-question'),answer=await q.getAttribute('data-answer');
   assert.equal((await noScript.locator(`.quiz-answer[data-question="${id}"] .quiz-correct-option`).textContent()).trim(),(await q.locator(`input[value="${answer}"] + span`).textContent()).trim(),'Static answer key remains aligned');
  }
  assert.deepEqual(errors,[]);
  console.log('Week 5: local references, sidebar routes, relocated section, chapter shuffle/resume/retry and displayed/static answer letters passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

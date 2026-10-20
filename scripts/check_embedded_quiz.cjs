const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const page=await browser.newPage({viewport:{width:1200,height:950}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  const chapters=['clinical-question','power','calculations','curves','simulation','feasibility','exercises','study-designs','appendix'];
  for(const chapter of chapters){
   await page.goto(`${base}/book/${chapter}.html`);
   const quiz=page.locator('.chapter-quiz');
   assert.equal(await quiz.count(),1,chapter);
   assert.equal(await page.locator('.chapter-check').count(),0);
   assert.equal(await page.locator('.chapter-recap details.model-answer').count(),0);
   assert.equal(await quiz.locator('.quiz-answer-key').isVisible(),false);
   assert(await quiz.evaluate(q=>Boolean(q.compareDocumentPosition(document.querySelector('.chapter-end-nav'))&Node.DOCUMENT_POSITION_FOLLOWING)));
   assert.equal(await quiz.evaluate(q=>q.closest('details').open),false);
   await quiz.evaluate(q=>q.closest('details').open=true);
   assert((await quiz.locator('fieldset:visible').count())>0);
  }
  await page.goto(`${base}/book/clinical-question.html`);
  const quiz=page.locator('.chapter-quiz');
  await quiz.evaluate(q=>q.closest('details').open=true);
  assert.equal(await quiz.locator('fieldset:visible').count(),5);
  await quiz.locator('button[type=submit]').click();
  assert.equal(await quiz.locator('.quiz-results').isVisible(),false);
  for(const [i,q] of (await quiz.locator('fieldset:visible').all()).entries()){
   const right=Number(await q.getAttribute('data-answer'));
   await q.locator(`input[value="${i===0?(right+1)%4:right}"]`).check();
  }
  await quiz.locator('button[type=submit]').click();
  assert.match(await quiz.locator('.quiz-score').innerText(),/^4 of 5 correct/);
  assert.equal(await quiz.locator('.quiz-answer:visible').count(),5);
  await quiz.locator('.quiz-retry').click();
  assert.equal(await quiz.locator('fieldset:visible').count(),1);
  const q=quiz.locator('fieldset:visible');
  await q.locator(`input[value="${await q.getAttribute('data-answer')}"]`).check();
  await quiz.locator('button[type=submit]').click();
  assert.match(await quiz.locator('.quiz-score').innerText(),/^1 of 1 correct/);
  await page.goto(`${base}/book/exercises.html`);
  await quiz.evaluate(q=>q.closest('details').open=true);
  assert.equal(await quiz.locator('fieldset:visible').count(),20);
  await quiz.locator('select').selectOption('all');
  assert.equal(await quiz.locator('fieldset:visible').count(),40);
  await page.goto(`${base}/book/Sample_size_open_module.html`);
  assert.equal(await page.locator('.chapter-quiz').count(),9);
  const offline=page.locator('#quiz-clinical-question');
  await offline.evaluate(q=>q.closest('details').open=true);
  for(const q of await offline.locator('fieldset:visible').all())await q.locator(`input[value="${await q.getAttribute('data-answer')}"]`).check();
  await offline.locator('button[type=submit]').click();
  assert.match(await offline.locator('.quiz-score').innerText(),/^5 of 5 correct/);
  await page.setViewportSize({width:390,height:844});
  await page.goto(`${base}/book/clinical-question.html#check-clinical-question`);
  await quiz.evaluate(q=>q.closest('details').open=true);
  await quiz.scrollIntoViewIfNeeded();
  fs.mkdirSync('build/browser-checks',{recursive:true});
  await page.screenshot({path:'build/browser-checks/embedded-quiz-mobile.png'});
  assert.deepEqual(errors,[]);
  console.log('Embedded quizzes passed: one per teaching chapter, no duplicate recap questions, delayed feedback, scores, retries, routes, standalone HTML and mobile.');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});

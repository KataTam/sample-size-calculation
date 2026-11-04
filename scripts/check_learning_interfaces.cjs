const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
const axePath=process.env.AXE_PATH||require.resolve('axe-core/axe.min.js');
const cards=JSON.parse(fs.readFileSync('data/flashcards.json','utf8')).cards;
(async()=>{const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});try{
 fs.mkdirSync('build/learning-layout',{recursive:true});
 const page=await browser.newPage({viewport:{width:1400,height:1000}});const errors=[];page.on('pageerror',e=>errors.push(e.message));
 async function help(id){await page.locator('#'+id+'-question').focus();const popup=page.locator('.input-guidance-popover:not([hidden])');await popup.waitFor();assert((await popup.innerText()).length>30);await page.keyboard.press('Escape');assert.equal(await popup.count(),0)}
 async function audit(label){await page.addScriptTag({path:axePath});const r=await page.evaluate(()=>axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa']}}));assert.deepEqual(r.violations.map(v=>({id:v.id,nodes:v.nodes.map(n=>n.target)})),[],label);assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1),label+' fits');await page.screenshot({path:'build/learning-layout/'+label+'.png',fullPage:false})}
 await page.goto(base+'/design_questionnaire/');await page.waitForFunction(()=>[...document.querySelectorAll('.input-guidance-source')].every(el=>el.dataset.attached==='true'));await help('aim');assert.equal(await page.locator('#question-progress').innerText(),'0 of 4 questions answered');
 for(const [id,value] of Object.entries({aim:'treatment',data:'new',structure:'independent',outcome:'binary',allocation:'individual',comparison:'parallel',claim:'superiority'}))await page.locator('#'+id).selectOption(value);
 assert.equal(await page.locator('#question-progress').innerText(),'7 of 7 questions answered');await page.getByRole('button',{name:'Show design suggestions'}).click();
 assert.match(await page.locator('#suggested-design').innerText(),/parallel-group/);await audit('questionnaire-desktop');
 await page.setViewportSize({width:390,height:844});await page.locator('#aim-selection').waitFor();assert.match(await page.locator('#aim-selection').innerText(),/Compare the effects/);await help('structure');await audit('questionnaire-mobile');
 await page.getByRole('button',{name:'Start again'}).click();assert.equal(await page.locator('#result-panel').isVisible(),false);assert.equal(await page.locator('#question-progress-bar').getAttribute('value'),'0');
 await page.setViewportSize({width:1400,height:1000});await page.goto(base+'/quiz/?chapter=clinical-question');await page.locator('#start:enabled').waitFor();await help('route');await audit('quiz-setup');await page.locator('#start').click();
 const questions=JSON.parse(fs.readFileSync('site/quiz/questions.json','utf8')).questions.filter(q=>q.chapter==='clinical-question'&&q.level==='core');
 for(const [i,q] of questions.entries())await page.locator(`input[name="${q.id}"][value="${i? q.answer:(q.answer+1)%4}"]`).check();
 assert.equal(Number(await page.locator('#quiz-progress-bar').getAttribute('value')),questions.length);await page.locator('button[type=submit]').click();
 assert.equal(await page.locator('#review details[open]').count(),1);assert.equal(await page.locator('#review details').count(),questions.length);await audit('quiz-results');
 await page.setViewportSize({width:320,height:850});await audit('quiz-mobile');await page.locator('#review details:not([open]) summary').first().click();assert.equal(await page.locator('#review details[open]').count(),2);
 await page.goto(base+'/student-materials/flashcards/cards.html');await page.locator('#flashcard-controls:visible').waitFor();assert.equal(await page.locator('tbody tr:visible').count(),cards.length);await help('flashcard-search');
 await page.locator('#flashcard-route').selectOption('core');assert.equal(await page.locator('tbody tr:visible').count(),cards.filter(c=>c.level==='core').length);await page.locator('#flashcard-search').fill('sample size');
 const expected=cards.filter(c=>c.level==='core'&&['sample','size'].every(t=>(c.front+' '+c.back).toLowerCase().includes(t))).length;assert.equal(await page.locator('tbody tr:visible').count(),expected);await audit('flashcards-mobile');
 await page.locator('#flashcard-search').fill('zzzz-no-card');assert.equal(await page.locator('tbody tr:visible').count(),0);assert(await page.locator('#flashcard-empty').isVisible());await page.locator('#clear-search').click();assert.equal(await page.locator('#flashcard-route').inputValue(),'core');
 await page.locator('#flashcard-route').selectOption('advanced');assert.equal(await page.locator('tbody tr:visible').count(),cards.filter(c=>c.level==='advanced').length);
 const row=page.locator('tbody tr:visible').first(),id=await row.getAttribute('data-card'),card=cards.find(c=>c.id===id);const actual=new URL(await row.locator('a').getAttribute('href'),page.url()),expectedLink=new URL(card.source);assert(actual.pathname.endsWith('/book/'+expectedLink.pathname.split('/book/')[1]));assert.equal(actual.hash,expectedLink.hash);assert.equal(await row.locator('td').nth(1).innerText(),card.back);
 await page.setViewportSize({width:1400,height:1000});await audit('flashcards-desktop');
 const fallback=await browser.newContext({javaScriptEnabled:false});const staticPage=await fallback.newPage();await staticPage.goto(base+'/student-materials/flashcards/cards.html');assert.equal(await staticPage.locator('tbody tr:visible').count(),cards.length);await fallback.close();
 await page.goto(base+'/book/clinical-question.html');const quiz=page.locator('.chapter-quiz');await quiz.evaluate(el=>el.closest('details').open=true);
 for(const [i,q] of (await quiz.locator('fieldset:visible').all()).entries()){const answer=Number(await q.getAttribute('data-answer'));await q.locator(`input[value="${i?answer:(answer+1)%4}"]`).check()}
 await quiz.locator('button[type=submit]').click();assert.equal(await quiz.locator('.quiz-answer[open]').count(),1);
 for(const theme of [0,1,2]){await page.evaluate(t=>{const b=document.querySelector('.book');b.classList.remove('color-theme-1','color-theme-2');if(t)b.classList.add('color-theme-'+t)},theme);await page.addScriptTag({path:axePath});const r=await quiz.evaluate(el=>axe.run(el,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa']}}));assert.deepEqual(r.violations.map(v=>({id:v.id,nodes:v.nodes.map(n=>n.target)})),[],'Embedded quiz theme '+theme)}
 await page.screenshot({path:'build/learning-layout/embedded-night.png',fullPage:false});assert.deepEqual(errors,[]);
 console.log('Shared learning interfaces passed: questionnaire help/progress/reset, quiz feedback and required answers, flashcard filters/search/source links/no-JS fallback, mobile reflow and WCAG automated checks including quiz reader themes.');
}finally{await browser.close()}})().catch(e=>{console.error(e);process.exit(1)});

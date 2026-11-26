// Reading checks: immediate explanations, safe arithmetic, keyboard use and export.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
const bank=JSON.parse(fs.readFileSync('data/consider-checks.json','utf8')).checks;
const quiz=JSON.parse(fs.readFileSync('site/quiz/questions.json','utf8')).questions;
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const page=await browser.newPage({viewport:{width:1200,height:950}}),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  assert.equal(bank.length,27); assert.equal(new Set(bank.map(x=>x.id)).size,27);
  assert.equal(bank.filter(x=>x.calculator).length,7);
  for(const chapter of [...new Set(bank.map(x=>x.chapter))]){
   await page.goto(base+'/book/'+chapter+'.html');
   const expected=bank.filter(x=>x.chapter===chapter);
   assert.equal(await page.locator('.consider-check').count(),expected.length,chapter);
   for(const q of expected){
    const root=page.locator('#'+q.id);
    await root.evaluate(el=>{for(let p=el.parentElement;p;p=p.parentElement)if(p.tagName==='DETAILS')p.open=true;});
    assert.equal(await root.locator('.consider-question').innerText(),q.question);
    assert.equal(await root.locator('.consider-answer').isVisible(),false);
    assert.equal(await root.locator('details').count(),0);
    for(const value of [!q.answer,q.answer]){
     await root.locator(`input[type=radio][value=${value?'yes':'no'}]`).check();
     assert.equal(await root.locator('.consider-answer').isVisible(),true);
     assert.equal(await root.locator('.consider-result').innerText(),value===q.answer?'Correct.':'Incorrect.');
     assert((await root.locator('.consider-explanation').innerText()).includes(q.feedback));
    }
    for(const source of q.adapted_from) assert.equal(await page.locator(`.chapter-quiz [data-question="${source}"]`).count(),0);
   }
   const selected=quiz.filter(q=>q.chapter===chapter&&q.chapter_check!==false&&!q.inline_check);
   if(chapter!=='reporting') assert.equal(await page.locator('.chapter-quiz fieldset').count(),selected.length);
  }
  await page.goto(base+'/book/calculations.html');
  const root=page.locator('#consider-recruitment'),calculator=root.locator('.consider-calculator');
  const input=calculator.locator('input'),output=calculator.locator('output');
  assert.equal(await calculator.locator('.consider-calculator-help').innerText(),'5% = 0.05. Use ^ for powers.');
  assert.equal(await output.innerText(),'');
  assert.equal(await calculator.getByRole('button',{name:'Round up',exact:true}).isDisabled(),true);
  await input.focus(); await input.press('Enter');
  assert.match(await output.innerText(),/58\.947368/);
  await calculator.getByRole('button',{name:'Round up',exact:true}).click();
  assert.equal(await input.inputValue(),'59');
  await input.fill('59 * 2'); assert.equal(await output.innerText(),'');
  await input.press('Enter'); assert.match(await output.innerText(),/= 118$/);
  for(const [expression,result] of [['56 / (1 - 5%)',58.94736842],['(3 / 1.5)^2',4],['118 / (30 * 50%)',7.866666667],['90% * 90% * 100',81],['−2^2',-4],['2^3^2',512],['2 × (3 + 1) ÷ 4',2]]){
   await input.fill(expression); await input.press('Enter');
   assert(Math.abs(Number((await output.innerText()).split(' = ').pop())-result)<1e-7,expression);
  }
  for(const expression of ['1 / 0','(2 + 3','window.__considerInjected=1','1;alert(1)','']){
   await input.fill(expression); await input.press('Enter');
   assert.equal(await input.getAttribute('aria-invalid'),'true');
   assert.equal(await calculator.getByRole('button',{name:'Round up',exact:true}).isDisabled(),true);
  }
  for(const [expression,expected] of [['0.07 * 100','7'],['59.00000001','60']]){
   await input.fill(expression);await input.press('Enter');
   await calculator.getByRole('button',{name:'Round up',exact:true}).click();
   assert.equal(await input.inputValue(),expected,'Upward rounding respects numerical precision');
  }
  assert.equal(await page.evaluate(()=>window.__considerInjected),undefined);
  await calculator.getByRole('button',{name:'Clear',exact:true}).click();
  assert.equal(await input.inputValue(),''); assert.equal(await output.innerText(),'');
  await root.locator('input[value=yes]').focus(); await page.keyboard.press('Space');
  assert.equal(await root.locator('.consider-result').innerText(),'Correct.');
  const axePath=process.env.AXE_PATH||require.resolve('axe-core/axe.min.js');
  await page.addScriptTag({path:axePath});
  for(const theme of ['color-theme-0','color-theme-1','color-theme-2']){
   await page.locator('.book').evaluate((el,theme)=>{el.classList.remove('color-theme-0','color-theme-1','color-theme-2');el.classList.add(theme)},theme);
   const audit=await page.evaluate(()=>axe.run({include:[['.consider-check']]},{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa']}}));
   assert.deepEqual(audit.violations.map(v=>({id:v.id,nodes:v.nodes.map(n=>n.target)})),[],theme);
  }
  await page.locator('.book').evaluate(el=>el.classList.remove('color-theme-2'));
  await page.setViewportSize({width:390,height:844});
  await root.scrollIntoViewIfNeeded();
  assert(await root.evaluate(el=>el.scrollWidth<=el.clientWidth+2),'Reading check fits a narrow screen');
  fs.mkdirSync('build/browser-checks',{recursive:true});
  await root.screenshot({path:'build/browser-checks/consider-calculator-mobile.png'});
  await page.goto(base+'/book/Sample_size_open_module.html');
  assert.equal(await page.locator('.consider-check').count(),27);
  assert.equal(await page.locator('.consider-answer:visible').count(),0);
  const standalone=page.locator('#consider-recruitment');
  await standalone.locator('input[value=no]').check();
  assert.equal(await standalone.locator('.consider-result').innerText(),'Incorrect.');
  await page.emulateMedia({media:'print'});
  await page.evaluate(()=>document.querySelectorAll('details').forEach(el=>el.open=true));
  assert.equal(await page.locator('.consider-answer:visible').count(),27);
  assert.equal(await page.locator('.consider-calculator:visible').count(),0);
  assert.equal(await page.locator('.consider-choices:visible').count(),0);
  await page.emulateMedia({media:'screen'});
  await page.goto(base+'/student-materials/study-design-guide.html');
  assert.equal(await page.locator('.consider-check[data-consider-ready]').count(),3);
  await page.goto(base+'/book/clinical-question.html#model-answer-target-choice');
  await page.waitForURL('**/calculations.html#model-answer-target-choice');
  assert.equal(await page.locator('#model-answer-target-choice').count(),1);
  assert.deepEqual(errors,[]);
  console.log('27 inline checks, 7 calculators, immediate feedback, quiz separation, arithmetic safety, keyboard, three themes, mobile, standalone HTML and print answers passed.');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});

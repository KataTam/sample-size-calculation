const {chromium}=require('playwright'),assert=require('node:assert/strict');
const base=process.argv[2]||'http://127.0.0.1:8770';
(async()=>{const b=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});try{
 const p=await b.newPage();
 for(const chapter of ['power','calculations','feasibility','exercises','appendix']) {
  await p.goto(base+'/book/'+chapter+'.html');
  assert.equal(await p.locator('details.section-disclosure').count(),{power:3,calculations:1,feasibility:3,exercises:1,appendix:1}[chapter]);
  for(const d of await p.locator('details.section-disclosure').all()) {
   assert.equal(await d.locator(':scope > summary > :is(h2,h3)').count(),1);
   assert.equal(await d.evaluate(x=>x.open),false);
   assert(!/Advanced explanation and exploration/.test(await d.innerText()));
   await d.locator(':scope > summary').focus();await p.keyboard.press('Enter');
   assert.equal(await d.evaluate(x=>x.open),true);
  }
 }
 await p.goto(base+'/book/calculations.html#plan-for-precision');
 assert(await p.locator('#plan-for-precision details').first().evaluate(d=>d.open));
 for(const [anchor,chapter] of [['plan-for-precision','calculations'],['prevalence','study-designs'],['interpret-a-confidence-interval-clinically','power']]) {
  await p.goto(base+'/book/feasibility.html#'+anchor);
  await p.waitForURL('**/'+chapter+'.html#'+anchor);
  assert(await p.locator('[id="'+anchor+'"]').isVisible());
 }
 await p.goto(base+'/book/feasibility.html');
 assert.match(await p.locator('#stress-test-the-study-plan h2').first().innerText(),/Sensitivity to planning assumptions/);
 const term=p.locator('[data-glossary-term="sensitivity-analysis"]').first();await term.focus();
 assert.match(await p.locator('#glossary-tooltip').innerText(),/missing outcomes/);
 assert.equal(await p.locator('#plan-for-precision, #prevalence, #interpret-a-confidence-interval-clinically').count(),0);
 const chapterSections=await p.locator('.page-inner .section.level2 > h2, .page-inner .section.level2 > details > summary > h2').allTextContents();
 assert.deepEqual(chapterSections.filter(t=>/^6\./.test(t.trim())).map(t=>t.trim().replace(/^6\.\d+\s*/,'')),[
  'Account for expected losses','Sensitivity to planning assumptions','What can the available sample establish?',
  'Options when the study provides insufficient information','Planning a pilot or feasibility study']);
 const bank=require('../site/quiz/questions.json');
 for(const [id,chapter] of [['q22','power'],['q23','calculations'],['q44','study-designs']])
  assert.equal(bank.questions.find(q=>q.id===id).chapter,chapter);
 const menu=require('../module/activity-contents.json');
 for(const [activity,chapter] of [['mean_precision','calculations'],['prevalence','study-designs']]) {
  const entries=menu.flatMap(c=>c.activities.filter(a=>a.path==='study/?activity='+activity).map(a=>({...a,chapter:c.chapter})));
  assert.equal(entries.length,1);assert.equal(entries[0].chapter,chapter);
  await p.goto(base+'/book/'+chapter+'.html#'+entries[0].section);
  assert(await p.locator('[id="'+entries[0].section+'"]').isVisible());
 }
 await p.goto(base+'/student-materials/study-design-guide.html');
 assert(!/\(#(?:eq|tab):/.test(await p.locator('body').textContent()),'Standalone guide must not display Bookdown labels');
 assert.match(await p.locator('#prevalence').evaluate(h=>h.parentElement.textContent),/246/);
 assert.equal(await p.locator('details.r-code-output').count(),1);
 assert.equal(await p.locator('details.r-code-output').evaluate(d=>d.open),false);
 console.log('Chapter structure and advanced headings: relocated explanations, quiz and activity routes, guide calculation, keyboard, saved links and sensitivity popup passed.');
}finally{await b.close();}})().catch(e=>{console.error(e);process.exit(1)});

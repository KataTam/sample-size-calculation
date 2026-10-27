const {chromium}=require('playwright'),assert=require('node:assert/strict');
const base=process.argv[2]||'http://127.0.0.1:8770';
(async()=>{const b=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});try{
 const p=await b.newPage();
 for(const chapter of ['power','feasibility','exercises','appendix']) {
  await p.goto(base+'/book/'+chapter+'.html');
  assert.equal(await p.locator('details.section-disclosure').count(),{power:3,feasibility:5,exercises:1,appendix:1}[chapter]);
  for(const d of await p.locator('details.section-disclosure').all()) {
   assert.equal(await d.locator(':scope > summary > :is(h2,h3)').count(),1);
   assert.equal(await d.evaluate(x=>x.open),false);
   assert(!/Advanced explanation and exploration/.test(await d.innerText()));
   await d.locator(':scope > summary').focus();await p.keyboard.press('Enter');
   assert.equal(await d.evaluate(x=>x.open),true);
  }
 }
 await p.goto(base+'/book/feasibility.html#plan-for-precision');
 assert(await p.locator('#plan-for-precision details').first().evaluate(d=>d.open));
 assert.match(await p.locator('#stress-test-the-study-plan h2').first().innerText(),/Sensitivity analysis and feasibility/);
 const term=p.locator('[data-glossary-term="sensitivity-analysis"]').first();await term.focus();
 assert.match(await p.locator('#glossary-tooltip').innerText(),/missing outcomes/);
 console.log('Advanced headings: single expandable labels, keyboard, deep links and sensitivity popup passed.');
}finally{await b.close();}})().catch(e=>{console.error(e);process.exit(1)});

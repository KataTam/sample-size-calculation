const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{const b=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});try{
 const p=await b.newPage({viewport:{width:1400,height:1000}});
 const order=JSON.parse(fs.readFileSync('module/chapter-order.json','utf8')).map(x=>x.id);
 const expected={power:[],calculations:[],feasibility:[],curves:['critical-observed-difference','alpha-beta','available-sample','a-fixed-total-of-70-patients'],simulation:['precision-of-a-simulation','discharge-simulation'], 'estimation-planning':['plan-for-precision','dataset-reuse','pilot-feasibility'], 'study-designs':['rare-diseases'],appendix:['own-study','software-support','gpower-assumptions']};
 for(const [i,chapter] of order.entries()){
  await p.goto(base+'/book/'+chapter+'.html',{waitUntil:'networkidle'});
  const heading=p.locator('.page-inner .section.level1 > h1');
  assert.equal(await heading.count(),1,chapter);
  assert.match(await heading.innerText(),new RegExp('Chapter '+(i+1)+'\\b'));
  assert(await heading.evaluate((h,core)=>h.parentElement.classList.contains(core?'core-heading':'advanced-heading'),i<3));
  for(const id of expected[chapter]||[])assert.equal(await p.locator('[id="'+id+'"]').count(),1,id);
  if(i<3) {
    const disclosures=p.locator('.page-inner details.advanced-explanation');
    const optional=undefined;
    assert.equal(await disclosures.count(),chapter==='calculations'?2:0,'Optional advanced explanations stay beside their related core calculation');
    for(const disclosure of await disclosures.all())assert.equal(await disclosure.getAttribute('open'),null,'Advanced explanation starts collapsed');
    if(chapter==='calculations')assert.deepEqual(await disclosures.evaluateAll(nodes=>nodes.map(n=>n.closest('.optional-practice, .section').id)),['adherence','rehabilitation']);
    if(optional) {
      assert.equal(await disclosures.getAttribute('id'),optional);
      assert.equal(await disclosures.getAttribute('open'),null,'Advanced explanation starts collapsed');
    }
  }
 }
 for(const chapter of ['exercises','glossary','common-mistakes']){
  await p.goto(base+'/book/'+chapter+'.html');
  assert.equal(await p.locator('.page-inner h1 .header-section-number').count(),0);
  assert.equal(await p.locator('.page-inner .learning-goals, .page-inner .chapter-recap').count(),0);
 }
 for(const [old,anchor,chapter] of [['power','alpha-beta','curves'],['power','eq:mcse','simulation'],['calculations','plan-for-precision','estimation-planning'],['feasibility','dataset-reuse','estimation-planning'],['calculations','discharge','exercises'],['exercises','own-study','appendix'],['calculations','gpower-assumptions','appendix'],['calculations','tab:gpower-effect-sizes','appendix']]){
  await p.goto(base+'/book/'+old+'.html#'+anchor);
  await p.waitForURL('**/'+chapter+'.html#'+anchor);
  assert(await p.locator('[id="'+anchor+'"]').isVisible());
 }
 const menu=require('../module/activity-contents.json');
 for(const [activity,chapter] of [['mean_precision','estimation-planning'],['pilot_feasibility','estimation-planning'],['alpha_beta','curves'],['own_study','appendix']]){
  const entries=menu.flatMap(c=>c.activities.filter(a=>a.path==='study/?activity='+activity).map(a=>({...a,chapter:c.chapter})));
  assert.equal(entries.length,1);assert.equal(entries[0].chapter,chapter);
 }
 await p.goto(base+'/book/calculations.html',{waitUntil:'networkidle'});
 assert(await p.locator('.summary a[href="calculations.html#two-proportions"]').isVisible());
 assert(!(await p.locator('.summary a[href="calculations.html#adherence"]').isVisible()));
 assert.equal(await p.locator('.summary .activity-toc:visible').count(),0);
 await p.locator('.summary a[href="calculations.html#two-proportions"]').click();
 assert.equal(await p.locator('.summary a[href="calculations.html#adherence"]').count(),0,'Optional transfer practice stays outside the chapter contents');
 assert.equal(await p.locator('#adherence').getAttribute('open'),null);
 assert.equal(await p.locator('#adherence [data-activity="probiotics_calculation"]').count(),1);
 assert.equal(await p.locator('.summary a[href="calculations.html#rehabilitation"]').count(),0);
 fs.mkdirSync('build/browser-checks',{recursive:true});
 await p.screenshot({path:'build/browser-checks/streamlined-contents.png'});
 await p.goto(base+'/book/Sample_size_open_module.html');
 assert.deepEqual(await p.locator('.print-chapter').evaluateAll(n=>n.map(x=>x.id)),['index',...order,'exercises','glossary','common-mistakes','references'].map(x=>'tutorial-'+x));
 console.log('Streamlined routes passed: consecutive core chapters, advanced destinations, reference pages, saved links, activities, selective contents and complete download order.');
}finally{await b.close();}})().catch(e=>{console.error(e);process.exit(1)});

// One answer set, one report, and the two starting points remain distinct.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const {saveReportPair}=require('./report_test_helpers.cjs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const context=await browser.newContext({viewport:{width:1440,height:1000},acceptDownloads:true}),page=await context.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(base+'/assumptions_report/');
  assert.equal(await page.locator('#plan-basis').inputValue(),'own');
  for(const input of await page.locator('textarea').all())assert.equal(await input.inputValue(),'');
  const form=await page.locator('.form-pane').boundingBox(),report=await page.locator('#report-pane').boundingBox();
  assert(report.x>=form.x+form.width,'Report is on the right');
  assert.equal(await page.locator('#progress,.section-progress,.section-review,#supporting-study-plan').count(),0);
  await page.locator('#question').fill('Does the intervention improve recovery in adults?');
  await page.locator('#plan-section-2').evaluate(el=>el.open=true);
  await page.locator('#references').fill('Example Author. (2026). A study-specific evidence source.');
  const own=await saveReportPair(page,page,'#save','#save-word','unified-own-report');
  assert.match(own.html,/study-specific evidence source/);
  assert.doesNotMatch(own.html,/neravixa|duloxetine|56 analyzable/);
  assert.equal(own.model.title,'Sample size calculation report');
  await page.locator('#plan-basis').selectOption('pain');
  await page.waitForFunction(()=>/R \d+\.\d+\.\d+/.test(document.getElementById('software').value));
  assert.equal(await page.locator('#references').inputValue(),'');
  const teaching=await saveReportPair(page,page,'#save','#save-word','unified-teaching-report');
  for(const field of ['question','clinical','planning','variation','power','counts','software','recruitment']){
   const answer=await page.locator('#'+field).inputValue();
   const count=teaching.model.blocks.filter(b=>b.runs?.map(r=>r.text).join('').includes(answer)).length;
   assert.equal(count,1,field+' appears once');
  }
  const text=teaching.model.blocks.map(b=>b.runs?.map(r=>r.text).join('')).join('\n');
  assert.match(text,/55\.68382.*56.*112/);
  assert.match(text,/59 per group \(118 total\)/);
  assert.match(text,/Prepared using.*Tamasi \(2026\)/);
  assert.doesNotMatch(text,/\b(you|your|we|our|I would)\b|Section review|source version|marked ready|Supporting study plan|Guidance behind|Teaching materials:/i);
  assert.equal(teaching.model.blocks.filter(b=>b.type==='heading'&&b.runs[0]?.text==='References').length,1);
  const chapter=await context.newPage();
  await chapter.goto(base+'/book/reporting.html');
  const exampleFields=await chapter.locator('.annotated-report [data-report-field]').evaluateAll(nodes=>nodes.map(p=>[p.dataset.reportField,p.textContent.trim()]));
  const appFields=await page.locator('#report [data-report-field]').evaluateAll(nodes=>nodes.map(p=>[p.dataset.reportField,p.textContent.trim()]));
  assert.deepEqual(exampleFields,appFields,'Example 3.1 matches the selected teaching report, including its software record');
  assert(await chapter.locator('.annotated-report [data-report-field] + [data-report-field]').evaluateAll(nodes=>
    nodes.length>0 && nodes.every(el=>el.previousSibling.nodeType===Node.TEXT_NODE && /^\s+$/.test(el.previousSibling.textContent))),
    'Combined report entries retain a space between sentences');
  assert.equal(await chapter.locator('.page-inner table').count(),1,'The reporting checklists are consolidated');
  assert.equal(await chapter.locator('[id="tab:report-annotations"]').count(),1,'The old table link remains available');
  assert.equal(await chapter.locator('#report-error-activity .spot-part').count(),4,'The review follows the same four report sections');
  await chapter.close();
  fs.mkdirSync('build/unified-report',{recursive:true});
  await page.locator('main').scrollIntoViewIfNeeded();
  await page.screenshot({path:'build/unified-report/teaching-desktop.png'});
  await page.locator('#plan-basis').selectOption('own');
  for(const input of await page.locator('textarea').all())assert.equal(await input.inputValue(),'');
  assert.doesNotMatch(await page.locator('#report').innerText(),/neravixa|duloxetine/);
  await page.setViewportSize({width:800,height:900});
  await page.evaluate(()=>{document.body.classList.add('tutorial-embedded');document.body.dataset.inlineEngine='assumptions_report';});
  const inlineForm=await page.locator('.form-pane').boundingBox(),inlineReport=await page.locator('#report-pane').boundingBox();
  assert(inlineReport.x>=inlineForm.x+inlineForm.width,'Embedded report is also on the right');
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await page.setViewportSize({width:400,height:850});
  await page.locator('#preview').click();
  assert(await page.locator('#report-pane').isVisible());
  assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await page.locator('#preview').click();
  assert(await page.locator('#question').isVisible());
  assert.deepEqual(errors,[]);
  console.log('Unified report: both starting points, single answers, right-hand preview, neutral exports, references and mobile navigation passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});

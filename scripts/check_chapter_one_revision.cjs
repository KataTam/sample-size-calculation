// Check the single display against actual batch results, including saved assumptions.
const {chromium}=require('playwright'),assert=require('node:assert/strict'),fs=require('node:fs');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try{
  const page=await browser.newPage({viewport:{width:1360,height:1100}}),errors=[];
  page.setDefaultTimeout(90000);
  page.on('pageerror',e=>errors.push(e.message));
  await page.goto(base+'/book/clinical-question.html');
  assert.equal(await page.locator('.sidebar-level').count(),0);
  const chapter=await page.locator('.page-inner').innerText();
  assert(chapter.indexOf('Scenario 1:')<chapter.indexOf('These scenarios give'));
  assert(chapter.includes('True positive (power)'));
  assert.equal(await page.locator('#fig\\:error-scenario-null, #fig\\:error-scenario-effect').count(),2);
  const card=page.locator('[data-activity="pain_one_many"]');
  await card.locator('[data-inline-start]').click();
  let app;
  for(let i=0;i<150&&!app;i++){
   for(const frame of page.frames())if(await frame.locator('#fixed_n').count())app=frame;
   if(!app)await page.waitForTimeout(1000);
  }
  assert(app,'Inline app loaded');
  const capture=async(name)=>{
    const snapshot=await browser.newPage({viewport:{width:1100,height:900}});
    const markup=await app.evaluate(()=>document.querySelector('#sampling-journey').outerHTML+document.querySelector('#journey-reading').outerHTML);
    const css=fs.readFileSync('apps/power_explorer/www/sampling-journey.css','utf8');
    await snapshot.setContent('<style>'+css+'body{padding:12px;font:14px system-ui}#journey-reading{margin-top:16px}</style>'+markup);
    await snapshot.screenshot({path:'build/chapter-one-review/'+name+'.png',fullPage:true});
    await snapshot.close();await page.bringToFront();
  };
  await app.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1&&document.querySelector('#fixed_n').value==='20');
  assert.equal(await app.locator('#simulation_target').isVisible(),false);
  assert(await app.locator('#run_many').isVisible());
  assert.equal(await app.locator('#run_many').innerText(),'Simulate 5000 trials');
  await app.locator('#run_journey').click();
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('of 20'));
  await app.locator('.journey-playback > summary').click();
  await app.locator('#journey-finish').click();
  assert.match(await app.locator('#journey-status').innerText(),/Trial 20 of 20/);
  assert.equal(await app.locator('[data-trial-estimate]').count(),38);
  assert.equal(await app.locator('[data-pvalue-trial]').count(),40);
  assert.equal(await app.locator('[data-patient]').count(),80);
  assert.deepEqual(await app.locator('#sampling-journey svg').evaluateAll(xs=>xs.map(x=>Number(x.dataset.population))),[.3,.6]);
  assert.equal(await app.locator('[data-population-bar]').count(),0);
  assert(await app.locator('[data-population-patient]').count()>20);
  assert.equal(await app.locator('[data-moving-decision]').count(),2);
  assert.equal(await app.locator('[data-mean-estimate]').count(),2);
  assert.equal(await app.locator('#journey-reading > section').count(),2);
  assert.match(await app.locator('#journey-reading').textContent(),/mean estimated difference/);
  for(const svg of await app.locator('#sampling-journey svg').all()){
    const correct=await svg.locator('[data-decision-trial]').evaluateAll(xs=>xs.map(x=>x.dataset.correct==='true'));
    assert.deepEqual(correct,[...correct].sort((a,b)=>Number(b)-Number(a)),'Correct decisions precede errors');
  }
  const decisions=await app.locator('#sampling-journey svg').evaluateAll(xs=>xs.map(svg=>({
    rejects:Array.from(svg.querySelectorAll('[data-pvalue-trial]')).filter(p=>Number(p.dataset.pvalue)<.05).length,
    correct:svg.querySelectorAll('[data-decision-trial][data-correct="true"]').length,
    total:svg.querySelectorAll('[data-decision-trial]').length
  })));
  assert.equal(decisions[0].correct,20-decisions[0].rejects);
  assert.equal(decisions[1].correct,decisions[1].rejects);
  assert(decisions.every(x=>x.total===20));
  fs.mkdirSync('build/chapter-one-review',{recursive:true});
  await capture('stick-figures-twenty');
  console.log('Completed 20-trial decisions, means and outcome ordering checked.');
  assert(await app.locator('#journey-finish').isDisabled());
  await app.locator('#journey-speed').selectOption('fast');
  assert(await app.locator('[data-moving-estimate]').evaluateAll(xs=>xs.every(dot=>Number(dot.getAttribute('cy'))===Number(dot.dataset.motionEnd))),'Changing speed preserves completed trials');
  await app.locator('#journey-speed').selectOption('normal');
  await app.locator('#journey-motion').check();
  const began=Date.now();await app.locator('#journey-replay').click();
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('Trial 20 of 20')&&document.querySelector('#journey-pause').disabled,null,{timeout:8000});
  assert(Date.now()-began<8000,'Reduced motion completes promptly');
  await app.locator('#run_many').click();
  await app.waitForFunction(()=>document.querySelectorAll('[data-batch-bin]').length===80,null,{timeout:90000});
  assert.equal(await app.locator('#distribution').isVisible(),false);
  assert.match(await app.locator('#sampling-journey').innerText(),/5000 trials, each with 20/);
  await app.locator('#many_text').filter({hasText:'batch of estimates'}).waitFor();
  assert.equal(await app.locator('[data-pvalue-bin]').count(),80);
  assert.equal(await app.locator('[data-pvalue-bin]').evaluateAll(bins=>bins.reduce((n,b)=>n+Number(b.dataset.count),0)),10000);
  assert.match(await app.locator('#sampling-journey').innerText(),/Values\s+below\s+it\s+reject\s+the\s+null/);
  await app.locator('#fixed_n').fill('50');await app.locator('#fixed_n').press('Tab');
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('Inputs changed'));
  assert.match(await app.locator('#sampling-journey').innerText(),/20 patients per group/);
  await app.locator('#run_many').click();
  await app.locator('[data-reference-batch="20"]').waitFor();
  assert.match(await app.locator('#sampling-journey').innerText(),/50 patients per group/);
  fs.mkdirSync('build/chapter-one-review',{recursive:true});
  await capture('shared-display');
  await app.locator('#journey-motion').focus();await app.locator('#journey-motion').press('Space');
  assert.equal(await app.locator('#journey-motion').isChecked(),false);
  await app.locator('#journey_repetitions').fill('12');await app.locator('#journey_repetitions').press('Tab');
  await app.waitForFunction(()=>Object.entries(Shiny.shinyapp.$inputValues).some(([k,v])=>k.split(':')[0]==='journey_repetitions'&&v===12));
  await app.locator('#run_journey').focus();await app.locator('#run_journey').press('Enter');
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.includes('of 12')).catch(async e=>{
    console.log(await app.evaluate(()=>({inputs:Shiny.shinyapp.$inputValues,status:document.querySelector('#journey-status').textContent,errors:Array.from(document.querySelectorAll('.shiny-output-error')).map(x=>x.textContent)})));
    throw e;
  });
  await app.locator('#journey-pause').click();
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.startsWith('Paused.'));
  const paused=await app.locator('#sampling-journey').innerHTML();
  await page.waitForTimeout(700);
  assert.equal(await app.locator('#sampling-journey').innerHTML(),paused,'Pause freezes both charts');
  await app.locator('#journey-pause').click();
  await app.waitForFunction(()=>!document.querySelector('#journey-status').textContent.startsWith('Paused.'));
  await app.locator('#journey-finish').click();
  assert.equal(await app.locator('[data-pvalue-trial]').count(),24);
  assert.equal(await app.locator('[data-patient]').count(),0);
  assert.equal(await app.locator('[data-outcome-bar]').count(),4);
  assert(await app.locator('[data-outcome-bar]').evaluateAll(xs=>xs.every(x=>Number(x.dataset.total)===50 && Number(x.dataset.reliefCount)<=50)));
  await app.locator('#journey_repetitions').fill('21');await app.locator('#journey_repetitions').press('Tab');
  await app.waitForFunction(()=>Object.entries(Shiny.shinyapp.$inputValues).some(([k,v])=>k.split(':')[0]==='journey_repetitions'&&v===21));
  await app.locator('#run_journey').click();
  await app.waitForFunction(()=>document.querySelector('#journey-status').textContent.startsWith('21 trials;'));
  assert(await app.locator('#journey-pause').isDisabled(),'More than 20 trials render without animation');
  assert.equal(await app.locator('[data-pvalue-bin]').evaluateAll(xs=>xs.reduce((sum,x)=>sum+Number(x.dataset.count),0)),42);
  console.log('Pause/resume, larger-group bars and immediate 21-trial results checked.');
  await app.locator('#pain_population input[value="equal"]').focus();await app.locator('#pain_population input[value="equal"]').press('Space');
  await app.locator('#compare_populations').check();
  await app.waitForFunction(()=>Shiny.shinyapp.$inputValues.pain_population==='equal'&&Shiny.shinyapp.$inputValues.compare_populations);
  await app.locator('#run_many').focus();await app.locator('#run_many').press('Enter');
  await app.waitForFunction(()=>document.querySelectorAll('#sampling-journey svg').length===2&&document.querySelectorAll('[data-batch-bin]').length===80&&document.querySelector('#journey-status').textContent.startsWith('5000 trials;'));
  assert.deepEqual(await app.locator('#sampling-journey svg').evaluateAll(xs=>xs.map(x=>Number(x.dataset.population))),[.3,.6]);
  assert.match(await app.locator('#sampling-journey').innerText(),/False positives/);
  await app.locator('#inline-study-explanation > summary').click();
  assert.match(await app.locator('#journey-reading').textContent(),/planned Type I error probability is 5%/);
  assert.deepEqual(await app.locator('#sampling-journey svg').evaluateAll(xs=>xs.map(x=>Array.from(x.querySelectorAll('[data-pvalue-bin]')).reduce((n,b)=>n+Number(b.dataset.count),0))),[5000,5000]);
  await app.locator('#sampling-journey').screenshot({path:'build/chapter-one-review/population-comparison.png'});
  await page.setViewportSize({width:390,height:844});
  await page.locator('.book').evaluate(el=>el.classList.remove('with-summary'));
  await page.waitForTimeout(700);
  assert(await app.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1));
  await app.locator('#sampling-journey').screenshot({path:'build/chapter-one-review/shared-display-mobile.png'});
  await app.locator('#reset_trials').click();
  await app.waitForFunction(()=>!document.querySelector('#sampling-journey svg'));
  assert.equal(await app.locator('#fixed_n').inputValue(),'50');
  assert(await app.locator('#pain_population input[value="equal"]').isChecked());
  await app.locator('#run_one').click();
  await app.waitForFunction(()=>document.querySelector('[data-moving-estimate]')&&!document.querySelector('[data-batch-bin]'));
  assert.deepEqual(errors,[]);
  console.log('Chapter 1: scenario figures, chosen repetition counts, pause/resume, finish/replay, linked p values, two population comparison, reset and mobile width passed.');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

const {chromium} = require('playwright');
const assert = require('node:assert/strict');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
(async () => {
  const browser = await chromium.launch({headless:true, ...(process.platform==='win32'?{channel:'msedge'}:{})});
  try {
    const page = await browser.newPage({viewport:{width:1400,height:1000}});
    async function app(name, field) {
      await page.goto(base+'/'+name+'/');
      for (let i=0;i<180;i++) {
        for (const f of page.frames()) if (await f.locator('#'+field).count()) {
          await f.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
          return f;
        }
        await page.waitForTimeout(1000);
      }
      throw Error(name+' did not load');
    }
    const answer = (f,id,text) => f.waitForFunction(({id,text})=>document.getElementById(id).dataset.exampleAnswer?.includes(text),{id,text});
    const set = (f, values) => f.evaluate(values=>{
      for(const [id,value] of Object.entries(values)) Shiny.setInputValue(id,value,{priority:'event'});
    },values);
    let f=await app('dropout_adjustment','reasoning');
    await answer(f,'reasoning','112 per group (224 total)');
    await set(f,{n:56,dropout:.20,different_losses:true,loss_standard:.10});
    await answer(f,'reasoning','70 per group (140 total)');
    await f.getByRole('tab',{name:'Report',exact:true}).click();
    await f.getByText('Activity: Treatment changes and missing outcomes',{exact:true}).click();
    await f.locator('#reasoning').fill('My written response remains here.');
    await set(f,{n:100});
    await answer(f,'reasoning','125 per group (250 total)');
    assert.equal(await f.locator('#reasoning').inputValue(),'My written response remains here.');
    await f.locator('#reasoning-question').focus();
    const help=f.locator('.input-guidance-popover:not([hidden])');
    await help.waitFor();
    assert.match(await help.innerText(),/starting and final counts/);
    assert.doesNotMatch(await help.innerText(),/Model answer:|125 per group/);
    await set(f,{n:0}); await answer(f,'reasoning','when the current calculation inputs are valid');
    console.log('Recruitment answers: current placeholders, concise help, invalid inputs and preserved writing passed.');

    f=await app('sampling_distributions','interpretation');
    await answer(f,'interpretation','50.87%');
    await set(f,{effect:-5}); await answer(f,'interpretation','reduces power');
    await set(f,{sidedness:'less',n:100}); await answer(f,'interpretation','increases power');
    await answer(f,'interpretation','100 observations');
    await set(f,{effect:0}); await answer(f,'interpretation','under the null');
    console.log('Sampling answers: test direction, sample size and null scenario passed.');

    f=await app('prevalence_precision','justification');
    await answer(f,'justification','246 participants');
    await set(f,{activity_request:{activity:'pilot_feasibility',nonce:Date.now()}});
    await answer(f,'justification','retention pilot'); await answer(f,'justification','fixed at 40');
    await set(f,{confidence:.90,unknown_p:true,dropout:.2});
    await answer(f,'justification','90% confidence'); await answer(f,'justification','planning uses 50%');
    await answer(f,'justification','recruitment target is 50');
    await f.getByRole('tab',{name:'Explore assumptions',exact:true}).click();
    await f.locator('#simulate').click(); await answer(f,'justification','saved sample has');
    await set(f,{fixed_n:60}); await answer(f,'justification','earlier inputs');
    console.log('Precision answers: pilot case, confidence, conservative planning, fixed sample and saved interval passed.');

    f=await app('power_explorer','justification');
    await answer(f,'justification','45 participants per group');
    await set(f,{activity_request:{activity:'adherence',nonce:Date.now()}});
    await answer(f,'study_question','probiotic'); await answer(f,'evidence_sources','10 percentage points');
    assert(!await f.locator('#study_question').getAttribute('data-example-answer').then(t=>t.includes('pain')));
    await set(f,{goal:'fixed',fixed_n:17,dropout:.2});
    await answer(f,'justification','17 participants per group (34 total)');
    await answer(f,'justification','22 recruits per group (44 total)');
    await f.getByRole('tab',{name:'Report',exact:true}).click();
    await f.locator('#justification').fill('My recommendation.');
    await set(f,{activity_request:{activity:'rehabilitation',nonce:Date.now()}});
    await answer(f,'study_question','six weeks'); await answer(f,'clinical_relevance','2 units');
    assert.equal(await f.locator('#justification').inputValue(),'My recommendation.');
    await set(f,{study_design:'paired'}); await answer(f,'justification','matching planning method');
    console.log('Reasoning lab answers: examples, parameters, design changes and preserved writing passed.');

    await page.goto(base+'/assumptions_report/');
    await page.locator('#study-settings > summary').click();
    await page.locator('#goal').selectOption('precision');
    assert(!await page.locator('#counts').getAttribute('data-example-answer').then(t=>t.includes('56')));
    await page.locator('#goal').selectOption('feasibility');
    assert(!await page.locator('#recruitment').getAttribute('data-example-answer').then(t=>t.includes('63')));
    await page.locator('#question').fill('My own trial question');
    await page.locator('#goal').selectOption('testing');
    assert(!await page.locator('#power').getAttribute('data-example-answer').then(t=>t.includes('90%')));
    assert.equal(await page.locator('#question').inputValue(),'My own trial question');
    for (const id of ['population','intervention','comparator','outcome_detail','design']) {
      const example=await page.locator('#'+id).getAttribute('data-example-answer');
      assert(!/chronic pain|novel pain|four weeks/i.test(example),id+' uses the custom study format');
      assert(example.includes('['),id+' marks unspecified details');
    }
    await page.locator('#goal').selectOption('feasibility');
    assert.match(await page.locator('#scale').getAttribute('data-example-answer'),/percentage with \[feasibility outcome\]/);
    assert.doesNotMatch(await page.locator('#scale').getAttribute('data-example-answer'),/percentage points/);
    assert.match(await page.locator('#recruitment').getAttribute('data-example-answer'),/unknown retention status/);
    console.log('Written report: selected goal and custom study guidance passed.');
  } finally {await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1});

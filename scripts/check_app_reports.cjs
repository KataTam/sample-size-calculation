const {chromium} = require('playwright');
const {saveReportPair} = require('./report_test_helpers.cjs');
const assert = require('node:assert/strict'), fs = require('node:fs');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
(async () => {
  const browser = await chromium.launch({headless:true, ...(process.platform === 'win32' ? {channel:'msedge'} : {})});
  try {
    const page = await browser.newPage({viewport:{width:1400,height:1000}, acceptDownloads:true});
    const offline = await browser.newPage();
    fs.mkdirSync('build/app-reports', {recursive:true});
    const normalize = text => text.replace(/\s+/g,' ').trim();
    const set = (f, values) => f.evaluate(values => {
      for (const [id,value] of Object.entries(values)) Shiny.setInputValue(id,value);
    }, values);
    const has = async (f, text) => {
      try { await f.waitForFunction(text => document.querySelector('#report_preview')?.textContent.includes(text), text); }
      catch(error) { console.error('Expected report fragment:', text, '\nActual report:', await f.locator('#report_preview').innerText()); throw error; }
    };
    async function save(f, id, app) {
      await f.waitForFunction(() => !document.querySelector('#report_preview.recalculating'));
      const {html} = await saveReportPair(page, f, '#'+id, '#'+id+'_word', app);
      await offline.setContent(html);
      const preview = await f.locator('#report_preview .app-report').innerText();
      const heading = await offline.locator('.app-report > h3').count() ? '' : await offline.locator('h1').innerText();
      assert.equal(normalize(heading+' '+await offline.locator('.app-report').innerText()), normalize(preview), app+' download matches preview');
      assert(!html.includes('Model answer:'), app+' excludes placeholder answers');
      assert.equal(await offline.locator('footer').count(), 1);
      assert.match(html, /https:\/\/creativecommons.org\/licenses\/by-sa\/4.0\//);
      assert.match(html, /https:\/\/opensource.org\/license\/mit/);
      return html;
    }
    for (const [app,field,download] of [['two_means','delta','download_report'], ['two_proportions','pi1','download_report'],
      ['dropout_adjustment','reasoning','report'], ['sampling_distributions','interpretation','download_assumptions'],
      ['prevalence_precision','justification','download_plan'], ['power_explorer','justification','download_plan']]) {
      if(process.argv[3] && !process.argv[3].split(',').includes(app)) continue;
      await page.goto(base+'/'+app+'/'); let f;
      for(let i=0; i<180 && !f; i++) {
        for(const frame of page.frames()) if(await frame.locator('#'+field).count()) f=frame;
        if(!f) await page.waitForTimeout(1000);
      }
      assert(f, app+' loaded');
      await f.waitForFunction(() => window.Shiny?.shinyapp?.$socket?.readyState === 1);
      await f.getByRole('tab',{name:'Report',exact:true}).click();
      await f.locator('#report_preview .app-report').waitFor();
      console.log(app+': checking changed inputs and report downloads');
      if(app==='two_means') {
        await set(f,{delta:2,sd:7,compare_delta:1,dropout:.2}); await has(f,'target difference 1 units');
        await has(f,'7² / 2²');
        await has(f,'With 20% expected dropout');
      } else if(app==='two_proportions') {
        await set(f,{pi1:.5,pi2:.2,compare_pi1:.4,dropout:.15}); await has(f,'novel-treatment event probability 40%');
        await has(f,'p1 = 0.5, p2 = 0.2');
        await has(f,'With 15% expected dropout');
      } else if(app==='dropout_adjustment') {
        await set(f,{n:56,dropout:.2,different_losses:true,loss_standard:.1,switching:false,reasoning:'My recruitment evidence.'});
        await has(f,'70 in each group, 140 in total'); await has(f,'My recruitment evidence.');
        assert(!await f.locator('#report_preview').innerText().then(t=>t.includes('switching approximation assumes')));
      } else if(app==='sampling_distributions') {
        await set(f,{mu0:120,effect:0,sigma:10,n:80,alpha:.01,sidedness:'two.sided',interpretation:'My interpretation.'});
        await has(f,'n = 80'); await has(f,'Non-rejection probability under the null'); await has(f,'My interpretation.');
      } else if(app==='prevalence_precision') {
        await set(f,{activity_request:{activity:'pilot_feasibility',nonce:Date.now()}}); await has(f,'Pilot: retention');
        await set(f,{goal:'fixed',fixed_n:40,confidence:.9,anticipated_p:.8,justification:'My retention decision.'}); await has(f,'current analyzable count is 40');
        await has(f,'Confidence: 90%');
        await f.getByRole('tab',{name:'Explore assumptions',exact:true}).click(); await f.locator('#simulate').click();
        await f.getByRole('tab',{name:'Report',exact:true}).click(); await has(f,'events among 40');
        await set(f,{fixed_n:60}); await has(f,'omitted');
        assert(!await f.locator('#report_preview').innerText().then(t=>t.includes('events among 40')));
        await has(f,'My retention decision.');
      } else {
        await set(f,{activity_request:{activity:'adherence',nonce:Date.now()}});
        await f.waitForFunction(()=>document.querySelector('#activity_context')?.textContent.includes('Probiotics:'));
        await f.getByRole('tab',{name:'Report',exact:true}).click();
        await has(f,'Probiotics:');
        await set(f,{goal:'fixed',fixed_n:20,B:100,dropout:.2,study_question:'My study question.',clinical_relevance:'My clinical rationale.',
          participant_burden:'My burden assessment.',evidence_sources:'My supporting evidence.',justification:'My recommendation.'});
        await has(f,'20 per group; 40 total'); await has(f,'My recommendation.');
        await f.getByRole('tab',{name:'One study',exact:true}).click(); await f.locator('#run_one').click();
        await f.getByRole('tab',{name:'Many studies',exact:true}).click(); await f.locator('#run_many').click();
        await f.getByRole('tab',{name:'Report',exact:true}).click(); await has(f,'100 simulated studies'); await has(f,'Estimated difference:');
        await save(f,download,app+'-simulation');
        await set(f,{fixed_n:17}); await has(f,'17 per group; 34 total'); await has(f,'uses earlier settings');
        assert(!await f.locator('#report_preview').innerText().then(t=>t.includes('100 simulated studies')));
        for(const text of ['My study question.','My clinical rationale.','My burden assessment.','My supporting evidence.','My recommendation.']) await has(f,text);
        await f.locator('details').filter({has:f.locator('#download_plan_json')}).locator('summary').click();
        const pending=page.waitForEvent('download'); await f.locator('#download_plan_json').click();
        const backup=await pending, json=fs.readFileSync(await backup.path(),'utf8'), data=JSON.parse(json);
        assert.equal(data.inputs.fixed_n,17); assert.equal(data.study.justification,'My recommendation.'); assert.equal(data.activity,'adherence');
        await set(f,{fixed_n:31,justification:'Changed answer.'}); await has(f,'31 per group; 62 total');
        await f.locator('#upload_plan').setInputFiles({name:'plan.json',mimeType:'application/json',buffer:Buffer.from(json)});
        await has(f,'17 per group; 34 total'); await has(f,'My recommendation.'); await has(f,'No single-study simulation');
        assert.equal(await f.locator('#justification').inputValue(),'My recommendation.');
      }
      await save(f,download,app);
      assert.deepEqual(await f.locator('.tab-pane.active .shiny-output-error:not(.shiny-output-error-validation)').allTextContents(),[]);
      console.log(app+': current report, PDF, editable Word and saved-work controls verified.');
    }
    await offline.screenshot({path:'build/app-reports/lab-report.png',fullPage:true});
  } finally { await browser.close(); }
})().catch(error=>{console.error(error);process.exit(1);});

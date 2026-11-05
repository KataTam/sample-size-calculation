const {chromium} = require('playwright');
const assert = require('node:assert/strict'), fs = require('node:fs');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
const selected = process.argv[3];
const specs = [
  ['two_proportions', 'pi1', '60', '50'], ['power_explorer', 'plan_p1', '60', '55'],
  ['two_means', 'power', '90', '80'], ['dropout_adjustment', 'dropout', '10', '20'],
  ['prevalence_precision', 'anticipated_p', '20', '30'], ['sampling_distributions', 'alpha', '5', '2.5']
];
(async () => {
  const browser = await chromium.launch({headless:true, ...(process.platform==='win32'?{channel:'msedge'}:{})});
  fs.mkdirSync('build/app-usability', {recursive:true});
  try {
    for (const [app,id,initial,revised] of specs) {
      if (selected && !(selected==='first-two' ? specs.slice(0,2).some(s=>s[0]===app) : selected===app)) continue;
      const page = await browser.newPage({viewport:{width:1440,height:1050}, reducedMotion:'reduce'});
      await page.goto(`${base}/${app}/${app==='power_explorer'?'?activity=pain_one_many':''}`);
      let f;
      for (let i=0;i<150&&!f;i++) {
        for (const candidate of page.frames()) if (await candidate.locator('#'+id).count()) f=candidate;
        if (!f) await page.waitForTimeout(1000);
      }
      assert(f, app+' loads');
      await f.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
      if (app==='power_explorer') {
        await f.evaluate(()=>Shiny.setInputValue('activity_request',{activity:'pain_one_many',nonce:Date.now()}));
        await f.waitForFunction(()=>document.querySelector('#fixed_n').value==='20' && document.querySelector('#outcome').value==='proportions');
        await f.getByRole('tab',{name:'One study and many studies',exact:true}).click();
        await f.locator('#run_one').click();
        await f.locator('#sampling-journey svg').waitFor({timeout:60000});
        assert.equal(await f.locator('.nav-tabs a:visible').count(),3,'Focused simulation has three primary views');
        assert(await f.locator('#journey-motion').isChecked(),'Respects reduced motion');
      }
      await f.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(e=>e.checkVisibility()));
      await page.screenshot({path:`build/app-usability/${app}-wide.png`});
      // Editable percentages use the visible 0–100 scale; R retains probabilities.
      await f.evaluate(id => {
        for(let el=document.getElementById(id);el;el=el.parentElement) if(el.tagName==='DETAILS')el.open=true;
      },id);
      await f.waitForFunction(({id,initial})=>document.getElementById(id+'-number')?.value===initial,{id,initial});
      const number=f.locator('#'+id+'-number');
      await number.fill(revised); await number.press('Tab');
      await f.waitForFunction(({id,revised})=>Math.abs(Shiny.shinyapp.$inputValues[id]-Number(revised)/100)<1e-8,{id,revised});
      await f.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(e=>e.checkVisibility()));
      if (app==='two_proportions') await f.waitForFunction(()=>document.querySelector('#result').textContent.includes('124'));
      if (app==='dropout_adjustment') await f.waitForFunction(()=>document.querySelector('#result').textContent.includes('125'));
      await number.fill(initial); await number.press('Tab');
      // Server-driven resets synchronize the editable display too.
      await f.evaluate(({id,initial})=>jQuery('#'+id).data('ionRangeSlider').update({from:Number(initial)/100}),{id,initial});
      await page.setViewportSize({width:720,height:1000});
      await page.waitForTimeout(700);
      assert(!await f.locator('.app-settings').evaluate(e=>e.open),'Settings collapse in a split view');
      await f.evaluate(()=>window.scrollTo(0,0));
      await page.screenshot({path:`build/app-usability/${app}-split.png`});
      const top=await f.evaluate(()=>document.querySelector('.tab-pane.active .app-primary-result,.tab-pane.active .app-metrics,.tab-pane.active .simulation-actions')?.getBoundingClientRect().top);
      assert(top>=0 && top<570,`${app}: main result/action reaches first screen (${top})`);
      await page.setViewportSize({width:390,height:844});
      await page.waitForTimeout(700);
      await f.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(e=>e.checkVisibility()));
      console.log(await f.evaluate(()=>({viewport:innerWidth,scroll:document.documentElement.scrollWidth,overflow:[...document.querySelectorAll('body *')].filter(e=>e.checkVisibility()&&e.getBoundingClientRect().right>innerWidth+2).slice(0,8).map(e=>[e.tagName,e.id,e.className,e.getBoundingClientRect().right])})));
      await page.screenshot({path:`build/app-usability/${app}-mobile.png`});
      assert(await f.evaluate(()=>document.documentElement.scrollWidth<=document.documentElement.clientWidth+2),app+' has no page overflow');
      console.log(app+': percentage editing, current results, compact settings and responsive layout passed');
      await page.close();
    }
  } finally { await browser.close(); }
})().catch(e=>{console.error(e);process.exit(1)});

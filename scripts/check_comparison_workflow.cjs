// Original and revised plans, graph selection, and retained simulation batches.
const {chromium} = require('playwright');
const assert = require('node:assert/strict'), fs = require('node:fs');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
(async () => {
  const browser = await chromium.launch({headless:true, ...(process.platform === 'win32' ? {channel:'msedge'} : {})});
  try {
    const page = await browser.newPage({viewport:{width:1120,height:1000}});
    page.setDefaultTimeout(90000);
    const open = async (url, field) => {
      await page.goto(base+url);
      for (let i=0;i<180;i++) {
        for (const frame of page.frames()) if (await frame.locator('#'+field).count()) {
          await frame.waitForFunction(() => window.Shiny?.shinyapp?.$socket?.readyState === 1);
          return frame;
        }
        await page.waitForTimeout(1000);
      }
      throw Error('App did not load: '+url);
    };
    const has = (f,id,text) => f.waitForFunction(({id,text}) => {
      const el=document.getElementById(id);
      return el && !el.classList.contains('recalculating') && el.textContent.includes(text);
    }, {id,text});
    const set = (f,values) => f.evaluate(values => {
      for (const [id,value] of Object.entries(values)) Shiny.setInputValue(id,value);
    },values);
    fs.mkdirSync('build/comparison-workflow',{recursive:true});
    let f = await open('/two_means/?activity=rehabilitation_calculation&embedded=1','compare_sd');
    await f.getByRole('tab',{name:'Explore assumptions',exact:true}).click();
    await f.locator('.app-comparison > summary').click();
    await has(f,'comparison_table','116');
    assert.match(await f.locator('#comparison_table').innerText(),/60/);
    await f.locator('#comparison_plot img').waitFor();
    await page.setViewportSize({width:1120,height:2100});
    await page.screenshot({path:'build/comparison-workflow/means.png',fullPage:true});
    await page.setViewportSize({width:1120,height:1000});
    await f.getByRole('tab',{name:'Report',exact:true}).click();
    await f.locator('#report_scenario').evaluate(el=>el.selectize.setValue('revised'));
    await f.locator('#decision').fill('Comparable follow-up measurements support SD 7.');
    await f.locator('#decision').press('Tab');
    await has(f,'report_preview','sd = 7');
    await has(f,'report_preview','Comparable follow-up measurements');
    const transfer = await f.locator('.plan-transfer-data').innerText();
    assert.equal(JSON.parse(transfer).facts.analyzable,116);
    assert.equal(JSON.parse(transfer).facts.sd,7);
    await f.locator('#report_scenario').evaluate(el=>el.selectize.setValue('original'));
    await has(f,'report_preview','sd = 5');
    assert.equal(await f.locator('#decision').inputValue(),'Comparable follow-up measurements support SD 7.');
    console.log('Two means: retained 60/116 comparison, selected report, transfer and preserved answer passed.');

    f = await open('/power_explorer/?activity=pain_curves&embedded=1','comparison_plot');
    await has(f,'comparison_table','217');
    // Shiny exposes the plot's data-to-pixel map for actual pointer interaction.
    const clickGraph = async (x,y) => {
      const position=await f.evaluate(({x,y})=>{
        const plot=Shiny.shinyapp.$values.comparison_plot;
        const panel=plot.coordmap.panels[0], img=document.querySelector('#comparison_plot img');
        const px=panel.range.left+(x-panel.domain.left)/(panel.domain.right-panel.domain.left)*(panel.range.right-panel.range.left);
        const py=panel.range.bottom+(y-panel.domain.bottom)/(panel.domain.top-panel.domain.bottom)*(panel.range.top-panel.range.bottom);
        return {x:px*img.clientWidth/plot.coordmap.dims.width,y:py*img.clientHeight/plot.coordmap.dims.height};
      },{x,y});
      await f.locator('#comparison_plot img').click({position,timeout:15000});
    };
    await clickGraph(140,.8);
    await has(f,'comparison_table','140 per group');
    await f.locator('input[name="graph_selection"][value="power"]').check();
    await clickGraph(140,.8);
    await has(f,'comparison_table','80% power');
    await f.locator('#fixed_n').fill('100'); await f.locator('#fixed_n').press('Tab');
    await has(f,'comparison_table','100 per group');
    await page.screenshot({path:'build/comparison-workflow/curves.png',fullPage:true});
    console.log('Power curves: pointer selection of sample size and power plus keyboard input passed.');

    f = await open('/power_explorer/?activity=pain_one_many&embedded=1','run_many');
    await set(f,{B:1000});
    await f.locator('#combined-many-studies > summary').click();
    await f.locator('#run_many').click();
    await has(f,'many_status','20 patients per group');
    await f.locator('#fixed_n').fill('56'); await f.locator('#fixed_n').press('Tab');
    await f.locator('#run_many').click();
    await has(f,'sample_comparison','first batch used 20');
    await has(f,'sample_comparison','current batch uses 56');
    await f.locator('#distribution img').waitFor();
    await page.setViewportSize({width:1120,height:2100});
    await page.screenshot({path:'build/comparison-workflow/simulation.png',fullPage:true});
    await page.setViewportSize({width:1120,height:1000});
    await set(f,{plan_p1:.7});
    await f.locator('#run_many').click();
    await f.waitForFunction(()=>!document.querySelector('#sample_comparison').textContent.trim());
    console.log('Simulation: original/current sample comparison and population-change reset passed.');
    assert.equal(await f.locator('.shiny-output-error:not(.shiny-output-error-validation)').count(),0);
  } finally { await browser.close(); }
})().catch(error=>{console.error(error);process.exit(1);});

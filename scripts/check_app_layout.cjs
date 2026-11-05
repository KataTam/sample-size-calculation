const {chromium}=require('playwright');
const {saveReportPair}=require('./report_test_helpers.cjs');
const assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
  fs.mkdirSync('build/app-layout',{recursive:true});
  const page=await browser.newPage({viewport:{width:1440,height:1000},acceptDownloads:true});
  const specs=[['two_means','delta','download_report'],['two_proportions','pi1','download_report'],['dropout_adjustment','reasoning','report'],['prevalence_precision','justification','download_plan'],['sampling_distributions','interpretation','download_assumptions'],['power_explorer','justification','download_plan']];
  for(const [app,field,save] of specs){
   if(process.argv[3]&&process.argv[3]!==app)continue;
   await page.setViewportSize({width:1440,height:1000});
   await page.goto(base+'/'+app+'/');let f;
   for(let i=0;i<180;i++){
    for(const frame of page.frames())if(await frame.locator('#'+field).count())f=frame;
    if(f)break;await page.waitForTimeout(1000);
   }
   assert(f,app+' loaded');
   await f.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1);
   await f.getByRole('tab',{name:'Overview',exact:true}).click();
   await f.locator(app==='dropout_adjustment'?'#recruitment_steps li':'.app-primary-result,.app-metric').first().waitFor();
   await f.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(el=>el.checkVisibility()));
   assert(await f.locator('h2').first().evaluate(el=>parseFloat(getComputedStyle(el).fontSize)>=24),'Legible heading');
   await page.screenshot({path:`build/app-layout/${app}-overview.png`,fullPage:true});
   for(const name of ['Explore assumptions','Methods and references','Report']){
    await f.getByRole('tab',{name,exact:true}).click();
    await f.waitForFunction(()=>![...document.querySelectorAll('.recalculating')].some(el=>el.checkVisibility()));
    const errors=await f.locator('.tab-pane.active .shiny-output-error:not(.shiny-output-error-validation)').allTextContents();
    assert.deepEqual(errors,[],app+' '+name+' has no rendering errors');
   }
   await f.locator('#report_preview .app-report').waitFor();
   const preview=await f.locator('#report_preview').innerText();
   assert(preview.length>150,app+' has substantive report');
   const {html}=await saveReportPair(page,f,'#'+save,'#'+save+'_word',app+'-layout');
   assert(!html.includes('Model answer:'),'Model examples stay out of reports');
   await page.screenshot({path:`build/app-layout/${app}-report.png`,fullPage:true});
   await f.getByRole('tab',{name:'Overview',exact:true}).click();
   await page.setViewportSize({width:390,height:844});
   await f.waitForFunction(()=>[...document.querySelectorAll('.tab-pane.active .shiny-plot-output img')].every(img=>img.clientWidth<=img.parentElement.clientWidth+2));
   const size=await f.evaluate(()=>({width:document.documentElement.clientWidth,scroll:document.documentElement.scrollWidth}));
   assert(size.scroll<=size.width+2,app+' no horizontal page overflow '+JSON.stringify(size));
   await page.screenshot({path:`build/app-layout/${app}-mobile.png`,fullPage:true});
   console.log(app+': tabs, legible headings, output rendering, PDF/Word reports and narrow layout passed');
  }
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});

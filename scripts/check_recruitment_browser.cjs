const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 try {
  const page=await browser.newPage({viewport:{width:1360,height:1000}});
  await page.goto(base+'/dropout_adjustment/');
  let frame;
  for(let i=0;i<150;i++){
   for(const f of page.frames())if(await f.locator('#starting_assumption').count())frame=f;
   if(frame)break;await page.waitForTimeout(1000);
  }
  assert(frame,'The exported recruitment app loads');
  const result=frame.locator('#result');
  await result.getByText('112 participants per group; 224 in total.',{exact:true}).waitFor();
  assert.equal(await frame.locator('.advanced-options').getAttribute('open'),null);
  await frame.locator('.advanced-options>summary').click();
  await frame.locator('#switching').check();
  await result.getByText('154 participants per group; 308 in total.',{exact:true}).waitFor();
  await frame.getByLabel('Expected switching is already included').check();
  await result.getByText('112 participants per group; 224 in total.',{exact:true}).waitFor();
  await frame.getByLabel('Full adherence to assigned treatment',{exact:true}).check();
  // Slider API changes the same values and events as keyboard interaction.
  await frame.evaluate(()=>{
   jQuery('#dropout').data('ionRangeSlider').update({from:.05});jQuery('#dropout').trigger('change');
  });
  await result.getByText('146 participants per group; 292 in total.',{exact:true}).waitFor();
  await frame.locator('#different_losses').check();
  await result.getByText('154 participants per group; 308 in total.',{exact:true}).waitFor();
  await frame.getByText('Activity: Treatment changes and missing outcomes',{exact:true}).click();
  await frame.locator('#reasoning').fill('Switching changes the comparison; missing assessments reduce available outcomes.');
  await frame.getByText('Model answer',{exact:true}).click();
  assert(await frame.getByText('The switching adjustment should be applied once.',{exact:false}).isVisible());
  await frame.getByText('Methods and report',{exact:true}).click();
  const downloadPromise=page.waitForEvent('download');await frame.locator('#report').click();
  const download=await downloadPromise;
  fs.mkdirSync('build/browser-checks',{recursive:true});
  await download.saveAs('build/browser-checks/recruitment-report.txt');
  const report=fs.readFileSync('build/browser-checks/recruitment-report.txt','utf8');
  assert.match(report,/Recruitment total: 308/);assert.match(report,/Switching changes the comparison/);
  assert.match(report,/Shiny/);assert.match(report,/1-a-b/);
  const binary=frame.getByRole('link',{name:'two-proportion app',exact:true});
  assert.equal(await binary.getAttribute('target'),'_blank');
  assert.match(await binary.getAttribute('href'),/\/two_proportions\/$/);
  assert.equal(await frame.locator('.shiny-output-error').count(),0);
  await page.screenshot({path:'build/browser-checks/recruitment-desktop.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});
  await frame.waitForFunction(()=>document.querySelector('#dropout_plot img')?.clientWidth <= document.querySelector('#dropout_plot').clientWidth+2);
  await frame.evaluate(()=>window.scrollTo(0,0));
  const size=await frame.evaluate(()=>({scroll:document.documentElement.scrollWidth,width:document.documentElement.clientWidth}));
  assert(size.scroll<=size.width+2,JSON.stringify(size));
  await page.screenshot({path:'build/browser-checks/recruitment-mobile.png',fullPage:true});
  console.log('Exported recruitment app: defaults, switching, double-count prevention, unequal losses, model answer, report, links and mobile layout passed.');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});

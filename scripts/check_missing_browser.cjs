const {chromium}=require('playwright');
const assert=require('node:assert/strict'),fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8770';
(async()=>{const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
try {
 const page=await browser.newPage({viewport:{width:1550,height:1050}});
 page.on('console',msg=>{if(msg.type()==='error')console.log('Browser:',msg.text().slice(0,300));});
 await page.goto(base+'/study/?activity=pain_simulation');
 let frame;
 for(let i=0;i<150;i++) { for(const f of page.frames()) if(await f.locator('#missing_mode').count()) frame=f;
   if(frame)break;await page.waitForTimeout(1000); }
 assert(frame,'Exported app loaded');
 await frame.waitForFunction(()=>window.Shiny?.shinyapp?.$socket?.readyState===1 && document.querySelector('#activity_choice').value==='pain_simulation' && document.querySelector('#B').value==='5000');
 await page.locator('#app-status').filter({hasText:'App loaded'}).waitFor();
 await frame.waitForFunction(()=>!document.documentElement.classList.contains('shiny-busy'));
 await page.waitForTimeout(1000);
 await frame.locator('#missing-controls summary').click();
 await frame.locator('#B').fill('1000');await frame.locator('#B').press('Tab');
 for(const mode of ['complete','equal','differential','selective']) {
   const label={complete:'Complete outcomes',equal:'10% expected loss in both groups',differential:'10% standard / 20% novel expected loss, unrelated',selective:'10% standard / 20% novel expected loss, related'}[mode];
   await frame.locator('#missing_mode + .selectize-control .selectize-input').click();
   await frame.locator('.selectize-dropdown .option[data-value="'+mode+'"]').click();
   await frame.waitForFunction(label=>document.querySelector('#missing_note').textContent.includes(label),label);
   await frame.locator('a[data-value="Many studies"]').click();
   await frame.locator('#run_many').click();
   await frame.waitForFunction(label=>document.querySelector('#many_status').textContent.includes(label) && document.querySelector('#many_status').textContent.includes('Results match current inputs.') && document.querySelector('#many_summary').textContent.includes('Estimated bias'),label).catch(async e=>{
    console.log(await frame.locator('#many_status, #many_summary, .shiny-output-error').allTextContents());
    fs.mkdirSync('build/browser-checks',{recursive:true});await page.screenshot({path:'build/browser-checks/missing-failure.png',fullPage:true});throw e;
   });
   console.log(mode,(await frame.locator('#many_summary').innerText()).replace(/\s+/g,' ').slice(-330));
 }
 await frame.locator('#download_many').scrollIntoViewIfNeeded();
 const [file]=await Promise.all([page.waitForEvent('download',{timeout:60000}),frame.locator('#download_many').click()]).catch(async e=>{console.log('Download status:',await frame.locator('#download-status').innerText());console.log(await frame.evaluate(()=>({errors:Shiny.shinyapp.$errors,download:Shiny.shinyapp.$values.download_many,hidden:Shiny.shinyapp.$inputValues['.clientdata_output_download_many_hidden']})));throw e;});
 const csv=fs.readFileSync(await file.path(),'utf8');
 assert(csv.includes('missing_failure_multiplier')&&csv.includes('retained_treatment'));
 await frame.locator('a[data-value="One study"]').click();await frame.locator('#run_one').click();
 await frame.waitForFunction(()=>document.querySelector('#one_status').textContent.includes('Results match current inputs.') && document.querySelector('#one_retention').textContent.includes('Retained'));
 assert((await frame.locator('#one_data').innerText()).includes('Missing'));
 assert(!(await frame.locator('#run_journey').isVisible()));
 fs.mkdirSync('build/browser-checks',{recursive:true});await page.screenshot({path:'build/browser-checks/missing-outcomes.png',fullPage:true});
 await page.locator('#reset').click();
 await frame.waitForFunction(()=>document.querySelector('#missing_mode').value==='off' && document.querySelector('#one_result').textContent.trim()==='');
 console.log('Exported missing-outcome app: four scenarios, results, download, missing records, animation isolation and reset passed.');
} finally {await browser.close();}})().catch(e=>{console.error(e);process.exit(1)});

const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const base=process.argv[2]||'http://127.0.0.1:8769';
(async()=>{
 const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
 const page=await browser.newPage({viewport:{width:1280,height:900}});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 for(const path of ['/book/feasibility.html','/book/Sample_size_open_module.html']) {
  console.log("Checking",path); await page.goto(base+path);
  const term=page.locator('a[data-glossary-term="precision"]').first();
  await term.hover();await page.locator('#glossary-tooltip:not([hidden])').waitFor();
  assert((await page.locator('#glossary-tooltip').innerText()).includes('not necessarily less bias'));
  await page.keyboard.press('Escape');assert(await page.locator('#glossary-tooltip').isHidden());
  await term.focus();assert(await page.locator('#glossary-tooltip').isVisible());
  const bounds=await page.locator('#glossary-tooltip').boundingBox();
  await page.mouse.move(bounds.x+10,bounds.y+10);await page.waitForTimeout(250);
  assert(await page.locator('#glossary-tooltip').isVisible());
  await page.keyboard.press('Escape');
  await term.evaluate(el=>el.blur());await page.setViewportSize({width:390,height:844});await term.focus();
  assert(await page.locator('#glossary-tooltip').evaluate(el=>{let r=el.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth}));
  assert((await term.getAttribute('href')).includes('#precision'));
  assert.equal(await page.locator('pre a[data-glossary-term]').count(),0);
  await page.setViewportSize({width:1280,height:900});
 }
 await page.goto(base+'/book/clinical-question.html');
 await page.locator('a[data-glossary-term="clinical-threshold"]:visible').first().hover();
 await page.screenshot({path:'build/browser-checks/glossary-tooltip.png'});
 const definitions=JSON.parse(fs.readFileSync('data/glossary-terms.json','utf8'));
 await page.goto(base+'/book/glossary.html');
 for(const entry of definitions) assert.equal(await page.locator('[id="'+entry.id+'"]').count(),1,entry.id);
 assert.deepEqual(errors,[]);
 await browser.close();console.log('Glossary checks passed: all term anchors, hover, focus, Escape, hoverable popup, narrow-screen bounds, standalone HTML and code exclusions.');
})().catch(e=>{console.error(e);process.exit(1)});

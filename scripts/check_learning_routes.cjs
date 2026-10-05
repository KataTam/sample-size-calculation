// Run against the private loopback preview after rebuilding the tutorial.
const {chromium}=require('playwright');
const assert=require('node:assert/strict');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
let browser;
(async()=>{
 browser=await chromium.launch({headless:true,channel:'msedge'});
 const page=await browser.newPage();
 await page.goto(base+'/book/');
 for(const route of ['core-route','advanced-route']) {
  const links=await page.locator('#'+route+' a[href]').evaluateAll(nodes=>nodes.map(a=>a.href));
  assert(links.length>=6,route+' must provide a complete route');
  for(const href of links) {
   const url=new URL(href); assert.equal(url.origin,new URL(base).origin);
   const response=await page.request.get(url.href); assert(response.ok(),href);
   if(url.hash) assert((await response.text()).includes('id="'+decodeURIComponent(url.hash.slice(1))+'"'),href+' has no target section');
  }
 }
 await page.goto(base+'/book/power.html');
 assert(await page.locator('#alpha-beta .route-label.advanced').isVisible());
 const continuation=await page.locator('.core-next a').getAttribute('href');
 assert(continuation.includes('calculations'), 'The core route should skip error-region and simulation extensions');
 await page.goto(base+'/');
 assert((await page.locator('.start-route').first().getAttribute('href')).includes('#core-route'));
 console.log('Learning routes passed: section targets, core continuation, advanced labels and student entry point.');
 await browser.close();
})().catch(async e=>{console.error(e);if(browser)await browser.close();process.exit(1);});

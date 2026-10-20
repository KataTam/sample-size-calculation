const {chromium}=require('playwright'),fs=require('fs'),assert=require('node:assert/strict');
const base=process.argv[2]||'http://127.0.0.1:8769';
const axePath=process.env.AXE_PATH||require.resolve('axe-core/axe.min.js');
(async()=>{const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});const page=await browser.newPage({viewport:{width:1280,height:900}});let results=[];
for(const path of ['book/clinical-question.html','book/power.html','book/calculations.html','study/?activity=pain_one_many']){
 await page.goto(base+'/'+path);await page.waitForTimeout(1000);
 for(const theme of (path.startsWith('book')?[0,1,2]:[0])){
 await page.evaluate(theme=>{let b=document.querySelector('.book');if(b){b.classList.remove('color-theme-1','color-theme-2');if(theme)b.classList.add('color-theme-'+theme)}document.querySelectorAll('details').forEach(d=>d.open=true)},theme);
 await page.addScriptTag({path:axePath});let r=await page.evaluate(()=>axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa']}}));
 results.push({path,theme,violations:r.violations.map(v=>({id:v.id,impact:v.impact,nodes:v.nodes.map(n=>({target:n.target,summary:n.failureSummary,html:n.html}))}))});
 }
}
await page.goto(base+'/book/clinical-question.html');await page.locator('.skip-to-content').focus();assert.equal(await page.locator(':focus').innerText(),'Skip to main content');await page.keyboard.press('Enter');assert(await page.locator(':focus').evaluate(e=>e.matches('section.normal')));
for(const chapter of ['clinical-question','power','calculations']){await page.goto(base+'/book/'+chapter+'.html');await page.setViewportSize({width:320,height:800});await page.evaluate(()=>document.querySelectorAll('details').forEach(d=>d.open=true));let bad=await page.locator('section.normal').evaluate(el=>({scroll:el.scrollWidth,width:el.clientWidth}));assert(bad.scroll<=bad.width+2,JSON.stringify({chapter,bad}));}
await page.setViewportSize({width:1400,height:1000});await page.goto(base+'/study/?activity=pain_one_many');const s=page.locator('#panel-separator');await s.focus();const start=Number(await s.getAttribute('aria-valuenow'));await page.keyboard.press('ArrowRight');assert(Number(await s.getAttribute('aria-valuenow'))>start);await page.keyboard.press('Home');assert.equal(await s.getAttribute('aria-valuenow'),'20');

fs.mkdirSync('build/a11y',{recursive:true});fs.writeFileSync('build/a11y/latest.json',JSON.stringify(results,null,2));console.log(results.map(r=>({path:r.path,theme:r.theme,issues:r.violations.map(v=>v.id+':'+v.nodes.length)})));await browser.close();assert.equal(results.reduce((n,r)=>n+r.violations.length,0),0,'Automated accessibility violations; see build/a11y/latest.json')})().catch(e=>{console.error(e);process.exit(1)});

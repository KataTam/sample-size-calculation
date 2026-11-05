/* Exercise the shared exporter with Unicode, links, tables and a long response. */
const {chromium}=require('playwright');
const fs=require('node:fs'), assert=require('node:assert/strict');
const base=(process.argv[2]||'http://127.0.0.1:8769').replace(/\/$/,'');
(async()=>{
  const browser=await chromium.launch({headless:true,...(process.platform==='win32'?{channel:'msedge'}:{})});
  try {
    const page=await browser.newPage({acceptDownloads:true});
    await page.goto(base+'/assumptions_report/');
    const long=Array.from({length:32},(_,i)=>`Response ${i+1}: The population difference is 30 percentage points. More patients improve precision; more repetitions stabilize the simulation summary.`).join('\n');
    const html=`<!doctype html><html lang="en"><title>Pain relief simulation report</title><body>
      <h1>Pain relief simulation report</h1><p>Generated for export verification</p>
      <h2>Population assumptions</h2><p>Standard treatment: 30%. Novel treatment: 60%. μ = 3; σ = 5; α = 0.05. Tamási’s example.</p>
      <table><caption>Assumptions and results</caption><thead><tr><th>Quantity</th><th>Value</th></tr></thead><tbody>
      <tr><td>Target difference</td><td>30 percentage points</td></tr><tr><td>Patients per group</td><td>20</td></tr><tr><td>Confidence interval</td><td>−5 to 20 percentage points</td></tr></tbody></table>
      <h2>Your reflection</h2><p>&lt;img src=x onerror="window.injected=true"&gt;</p><p>${long}</p>
      <h2>Resources and licenses</h2><p>Teaching materials: <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a>. Code: <a href="https://opensource.org/license/mit">MIT</a>.</p>
      <script type="application/json">{"schema":"private-backup"}</script></body></html>`;
    fs.mkdirSync('build/report-downloads',{recursive:true});
    const model=await page.evaluate(html=>ReportExports.parse(html),html);
    fs.writeFileSync('build/report-downloads/stress.model.json',JSON.stringify(model));
    for(const format of ['pdf','docx']) {
      const pending=page.waitForEvent('download');
      await page.evaluate(({html,format})=>ReportExports.download(html,format,'stress'),{html,format});
      const file=await pending;assert.equal(file.suggestedFilename(),'stress.'+format);
      await file.saveAs('build/report-downloads/stress.'+format);
      console.log('Shared exporter:',format,'generated');
    }
    assert.equal(await page.evaluate(()=>window.injected),undefined);
  }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exit(1)});

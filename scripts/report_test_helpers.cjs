/* Exercise the real download controls and preserve their source for file checks. */
const fs = require('node:fs'), assert = require('node:assert/strict');
async function saveReport(page, frame, selector, stem, format) {
  await frame.evaluate(() => {
    if (window.__captureReportExport) return;
    window.__captureReportExport = true;
    const original = ReportExports.download;
    ReportExports.download = function(html, ...args) {
      window.__reportSource = html;
      window.__reportModel = ReportExports.parse(html);
      return original(html, ...args);
    };
  });
  const pending = page.waitForEvent('download', {timeout:60000});
  await frame.locator(selector).click();
  const file = await pending;
  assert(file.suggestedFilename().endsWith('.'+format), file.suggestedFilename());
  fs.mkdirSync('build/report-downloads', {recursive:true});
  await file.saveAs('build/report-downloads/'+stem+'.'+format);
  const bytes = fs.readFileSync(await file.path());
  assert.equal(bytes.subarray(0, format==='pdf'?5:2).toString(), format==='pdf'?'%PDF-':'PK');
  const result = await frame.evaluate(() => ({html:window.__reportSource, model:window.__reportModel}));
  fs.writeFileSync('build/report-downloads/'+stem+'.model.json', JSON.stringify(result.model));
  return result;
}
async function saveReportPair(page, frame, selector, wordSelector, stem) {
  const pdf = await saveReport(page, frame, selector, stem, 'pdf');
  const word = await saveReport(page, frame, wordSelector, stem, 'docx');
  assert.deepEqual(word.model, pdf.model, stem+' PDF and Word share current report content');
  return pdf;
}
module.exports = {saveReport, saveReportPair};

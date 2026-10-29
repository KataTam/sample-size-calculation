const {chromium} = require('playwright');
const assert = require('node:assert/strict');
const base = process.argv[2] || 'http://127.0.0.1:8769';
(async () => {
  const browser = await chromium.launch({headless:true, ...(process.platform === 'win32' ? {channel:'msedge'} : {})});
  try {
    const page = await browser.newPage();
    await page.goto(`${base}/book/common-mistakes.html`);
    const boxes = page.locator('.page-inner details.misconception');
    assert.equal(await boxes.count(), 15);
    assert.equal(await boxes.evaluateAll(nodes => nodes.filter(n => n.open).length), 0);
    assert.equal(await page.locator('.page-inner h2').count(), 0);
    assert.equal(await page.locator('.summary a[href*="common-mistakes.html#"]').count(), 0);
    await boxes.first().locator('summary').click();
    assert(await boxes.first().locator('p').isVisible());
    await page.goto(`${base}/book/index.html`);
    await page.locator('a[aria-label="Search"], a[title="Search"]').first().click();
    const input = page.locator('#search-box');
    await input.fill('Monte Carlo');
    const results = page.locator('#tutorial-search-results a');
    await results.first().waitFor();
    const urls = await results.evaluateAll(nodes => nodes.map(n => n.getAttribute('href')));
    assert(urls.some(u => u.startsWith('simulation.html#')));
    assert(urls.some(u => u.startsWith('glossary.html#')));
    assert(await results.first().locator('.search-chapter').isVisible());
    await input.fill('20% better');
    await page.locator('#tutorial-search-results a[href*="does-20-better"]').waitFor();
    await page.locator('#tutorial-search-results a[href*="does-20-better"]').click();
    await page.waitForURL('**/common-mistakes.html#does-20-better-mean-20-percentage-points');
    assert(await page.locator('#does-20-better-mean-20-percentage-points').evaluate(n => n.open));
    await page.goto(`${base}/book/clinical-question.html`);
    const pico = page.locator('tr', {hasText:'Research question: PICO'});
    assert((await pico.innerText()).includes('Richardson'));
    assert(await pico.locator('a[href*="ref-richardson1995"]').count());
    console.log('Reference-page disclosures, PICO citation, whole-tutorial search and anchored results verified.');
  } finally { await browser.close(); }
})().catch(e => {console.error(e); process.exit(1);});

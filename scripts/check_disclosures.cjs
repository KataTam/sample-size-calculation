// Run against the author's loopback preview: node scripts/check_disclosures.cjs [base URL]
const {chromium} = require('playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
let browser;

(async () => {
  browser = await chromium.launch({channel: 'msedge', headless: true});
  const page = await browser.newPage({viewport: {width: 1400, height: 1000}});
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  fs.mkdirSync('build/browser-checks', {recursive: true});
  await page.goto(base + '/book/clinical-question.html');
  assert.equal(await page.locator('.learning-goals li').count(), 3);
  const misconception = page.locator('#misconception-pilot-effect');
  assert.equal(await misconception.getAttribute('open'), null);
  assert.equal(await misconception.locator('p').isVisible(), false);
  assert.equal(await misconception.evaluate(el => getComputedStyle(el).backgroundColor), 'rgb(255, 244, 214)');
  await misconception.locator('summary').click();
  assert.equal(await misconception.locator('p').isVisible(), true);
  await misconception.locator('summary').press('Enter');
  assert.equal(await misconception.locator('p').isVisible(), false);
  await misconception.locator('summary').press('Space');
  assert.equal(await misconception.locator('p').isVisible(), true);
  await misconception.locator('summary').press('Space');

  const code = page.locator('details.r-code-output').first();
  assert.equal(await code.getAttribute('open'), null);
  assert.equal(await code.locator('pre').first().isVisible(), false);
  const output = page.locator('pre:not(.sourceCode):not(.r)').first();
  assert.equal(await output.isVisible(), false);
  const savedOutput = await output.innerText();
  await code.locator('summary').click();
  assert.equal(await code.locator('pre').first().isVisible(), true);
  await code.locator('summary').press('Enter');
  assert.equal(await code.locator('pre').first().isVisible(), false);
  assert.equal(await output.innerText(), savedOutput);
  assert.equal(await output.isVisible(), false);
  assert.equal(await page.locator('.figure img').first().isVisible(), true);
  assert.equal(await page.locator('a[href*="activity=assumptions_report"]').first().getAttribute('href'), '../study/?activity=assumptions_report');

  await page.evaluate(() => document.querySelector('.book').classList.add('color-theme-2'));
  assert.equal(await misconception.evaluate(el => getComputedStyle(el).backgroundColor), 'rgb(73, 59, 32)');
  await page.evaluate(() => document.querySelector('.book').classList.remove('color-theme-2'));
  await misconception.scrollIntoViewIfNeeded();
  await page.screenshot({path: 'build/browser-checks/misconceptions-desktop.png'});
  await page.setViewportSize({width: 390, height: 844});
  if (await page.locator('.book').evaluate(el => el.classList.contains('with-summary'))) {
    await page.getByRole('link', {name: 'Toggle Sidebar', exact: true}).click();
    await page.waitForTimeout(500);
  }
  await misconception.scrollIntoViewIfNeeded();
  assert.equal(await misconception.evaluate(el => { const r = el.getBoundingClientRect(); return r.left >= 0 && r.right <= innerWidth; }), true);
  await page.screenshot({path: 'build/browser-checks/misconceptions-mobile.png'});

  for (const chapter of ['power', 'calculations', 'curves', 'simulation', 'feasibility', 'exercises', 'study-designs', 'glossary', 'common-mistakes', 'appendix']) {
    // Resolve filenames from the shared anchor map, including numbered chapters.
    const response = await page.request.get(base + '/chapter-anchors.json');
    const anchors = await response.json();
    assert(anchors[chapter], chapter + ' anchor');
    await page.goto(base + '/' + anchors[chapter]);
    assert.equal(await page.locator('.learning-goals').count(), 1);
    assert(await page.locator('.learning-goals li').count() >= 2);
    for (const element of await page.locator('details.misconception, details.r-code-output').all()) {
      assert.equal(await element.getAttribute('open'), null);
    }
  }

  await page.setViewportSize({width: 1400, height: 1000});
  await page.goto(base + '/book/exercises.html');
  const discharge = page.locator('#misconception-percentage-points');
  assert.equal(await discharge.isVisible(), false);
  await page.locator('summary').filter({hasText: 'Show the calculation and interpretation'}).click();
  assert.equal(await discharge.isVisible(), true);
  assert.equal(await discharge.locator('p').isVisible(), false);
  await discharge.locator('summary').click();
  assert.equal(await discharge.locator('p').isVisible(), true);

  await page.goto(base + '/book/Sample_size_open_module.html');
  assert.equal(await page.locator('.learning-goals ul').count(), 11);
  assert.equal(await page.locator('details.misconception').count(), 12);
  for (const element of await page.locator('details.misconception').all()) {
    assert.equal(await element.getAttribute('open'), null);
  }
  await page.locator('details.r-code-output').first().waitFor();
  const sourceBlocks = page.locator('pre.r');
  assert(await sourceBlocks.count() > 20);
  for (const source of await sourceBlocks.all()) assert.equal(await source.isVisible(), false);
  const standaloneOutput = page.locator('pre:not(.r):not(.sourceCode)').first();
  assert.equal(await standaloneOutput.isVisible(), false);
  await page.locator('details.r-code-output summary').first().click();
  await sourceBlocks.first().waitFor({state: 'visible'});
  await page.waitForFunction(() => !document.querySelector('.collapsing'));
  await page.locator('details.r-code-output summary').first().click();
  await sourceBlocks.first().waitFor({state: 'hidden'});
  assert.equal(await standaloneOutput.isVisible(), false);
  // RStudio can serve a knit result below /rmd_output/ rather than /book/.
  // Test the unassembled render there, not only the site's rewritten links.
  const previewURL = base + '/rmd_output/preview/tutorial.html';
  await page.route(previewURL, route => route.fulfill({
    contentType: 'text/html', body: fs.readFileSync('docs/book/Sample_size_open_module.html', 'utf8')
  }));
  await page.goto(previewURL);
  const activityLink = page.getByRole('link', {name: 'Open the assumptions report activity', exact: true});
  const activityURL = 'http://127.0.0.1:8769/study/?activity=assumptions_report';
  assert.equal(await activityLink.getAttribute('href'), activityURL);
  await Promise.all([page.waitForURL(activityURL), activityLink.click()]);
  await page.waitForFunction(() => document.getElementById('app-status').textContent.startsWith('Activity loaded.'));
  assert(page.frames().some(frame => frame.url().includes('/assumptions_report/')));
  assert.deepEqual(errors, []);
  console.log('DISCLOSURE CHECK PASSED: learning-outcome lists, twelve closed amber boxes, keyboard controls, folded R code and raw output with visible formatted results, nested exercise answer, night theme, mobile width, standalone HTML, local activity links, RStudio-style /rmd_output/ activity launch.');
  await browser.close();
})().catch(async error => { console.error(error); if (browser) await browser.close(); process.exitCode = 1; });

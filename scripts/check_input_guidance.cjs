/* Browser checks for shared question help and example-only answer placeholders. */
const {chromium} = require('playwright');
const assert = require('node:assert/strict'), fs = require('node:fs');
const base = (process.argv[2] || 'http://127.0.0.1:8769').replace(/\/$/, '');
(async () => {
  const browser = await chromium.launch({headless: true, ...(process.platform === 'win32' ? {channel: 'msedge'} : {})});
  try {
    fs.mkdirSync('build/input-guidance', {recursive: true});
    const page = await browser.newPage({viewport: {width: 1360, height: 1000}, acceptDownloads: true});
    for (const [app, control] of [['two_means','delta'], ['two_proportions','pi1'], ['dropout_adjustment','reasoning'], ['prevalence_precision','justification'], ['sampling_distributions','interpretation'], ['power_explorer','study_question']]) {
      if (process.argv[3] && process.argv[3] !== app) continue;
      await page.goto(base + '/' + app + '/');
      let frame;
      for (let attempt = 0; attempt < 180; attempt++) {
        for (const candidate of page.frames()) if (await candidate.locator('#' + control).count()) frame = candidate;
        if (frame) break;
        await page.waitForTimeout(1000);
      }
      assert(frame, app + ' loaded');
      await frame.waitForFunction(() => window.Shiny?.shinyapp?.$socket?.readyState === 1);
      await frame.waitForFunction(() => [...document.querySelectorAll('.input-guidance-source')].every(el => el.dataset.attached === 'true'));
      const fields = await frame.locator('textarea').evaluateAll(items => items.map(el => ({id: el.id, placeholder: el.placeholder, value: el.value, gray: getComputedStyle(el, '::placeholder').color})));
      for (const field of fields) {
        assert.match(field.placeholder, /^Model answer: .{30}/, app + '/' + field.id);
        assert.equal(field.value, '', 'Examples must not become learner responses');
        assert.equal(field.gray, 'rgb(97, 97, 97)');
      }
      if (app === 'power_explorer') await frame.locator('#lab-settings > summary').click();
      if (app === 'dropout_adjustment') { await frame.getByRole('tab',{name:'Report',exact:true}).click(); await frame.getByText('Activity: Treatment changes and missing outcomes',{exact:true}).click(); }
      if (app === 'sampling_distributions') await frame.getByRole('tab',{name:'Report',exact:true}).click();
      const question = frame.locator('.input-question:visible').first();
      await question.focus();
      const tip = frame.locator('#' + await question.getAttribute('aria-controls'));
      assert.equal(await tip.isVisible(), true);
      assert.doesNotMatch(await tip.innerText(), /Model answer:/, 'Help does not repeat the example in the text box');
      assert.notEqual((await tip.innerText()).trim(), (await question.innerText()).trim(), 'Help adds information to the question');
      await page.keyboard.press('Escape'); assert.equal(await tip.isVisible(), false);
      if (app === 'power_explorer') {
        await frame.getByRole('tab', {name: 'My study', exact: true}).click();
        await frame.locator('#study_question').fill('Does a new treatment improve the four-week outcome?');
        await frame.getByRole('tab', {name: 'Report', exact: true}).click();
        await frame.locator('#justification').fill('My own recommendation for this teaching case.');
        const pending = page.waitForEvent('download'); await frame.locator('#download_plan').click();
        const download = await pending, text = fs.readFileSync(await download.path(), 'utf8');
        assert.match(text, /My own recommendation/); assert.match(text, /Analyzable participants:/);
        assert.doesNotMatch(text, /List of \d|\$ study_question|Model answer:/);
        assert.match(text, /Clinical relevance<\/p>\s*<p>Not yet specified/);
        await download.saveAs('build/input-guidance/lab-report.html');
      }
      await page.screenshot({path: 'build/input-guidance/' + app + '.png', fullPage: true});
      console.log(app + ': all help sources attached; gray examples remain empty inputs; keyboard help passed');
    }
    await page.goto(base + '/assumptions_report/');
    await page.addScriptTag({path: process.env.AXE_PATH || require.resolve('axe-core/axe.min.js')});
    for (const width of [1360, 390, 320]) {
      await page.setViewportSize({width, height: 1000});
      await page.waitForFunction(() => [...document.querySelectorAll('textarea')].filter(el => el.checkVisibility() && !el.value).every(el => el.scrollHeight <= el.clientHeight + 2));
      assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth + 1));
      await page.screenshot({path: 'build/input-guidance/report-' + width + '.png', fullPage: true});
      const result = await page.evaluate(() => axe.run(document, {runOnly: {type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21aa', 'wcag22aa']}}));
      assert.deepEqual(result.violations.map(v => ({id: v.id, nodes: v.nodes.map(n => n.target)})), [], 'Report accessibility at width ' + width);
      await page.locator('#intervention-question').click();
      const popup = page.locator('.input-guidance-popover:not([hidden])');
      assert.doesNotMatch(await popup.innerText(), /Model answer:/);
      const box = await popup.boundingBox();
      assert(box.x >= 0 && box.x + box.width <= width + 1, 'Help remains within the viewport');
      await page.keyboard.press('Escape');
      await page.locator('details').evaluateAll(items => items.forEach(el => { el.dataset.wasOpen = String(el.open); el.open = true; }));
      await page.waitForFunction(() => [...document.querySelectorAll('textarea')].filter(el => el.checkVisibility() && !el.value).every(el => el.scrollHeight <= el.clientHeight + 2));
      await page.locator('details').evaluateAll(items => items.forEach(el => { el.open = el.dataset.wasOpen === 'true'; }));
    }
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });

/* A written justification activity; numerical results come from the calculators. */
(() => {
  'use strict';
  const app = 'assumptions_report', storageKey = 'sample-size-assumptions-report-v1';
  const form = document.getElementById('plan-form');
  const status = document.getElementById('status');
  const groups = [
    ['Question and design', [
      ['question', 'Research question', 'State the population and question. Include the intervention and comparator when relevant.', 'The research question is'],
      ['outcome_detail', 'Primary outcome and time point', 'Define what will be measured and when.', 'The primary outcome and time point are'],
      ['design', 'Design, sampling and allocation', 'Describe how participants or records are selected, how observations are related, and any treatment allocation.', 'The design, sampling and allocation are']
    ]],
    ['Effects and supporting evidence', [
      ['scale', 'Effect scale and direction of benefit', 'Use treatment minus control. Specify whether a positive or negative difference is beneficial.', 'The effect scale and direction of benefit are'],
      ['expected', 'Expected difference', 'Give the best current expectation, its evidence source and uncertainty.', 'The expected difference and supporting evidence are'],
      ['clinical', 'Clinically important difference (clinical threshold)', 'Give the smallest between-group benefit that matters to patients and justify that judgment.', 'The clinical threshold and its justification are', 'comparison'],
      ['planning', 'Target difference: used in the calculation', 'Give the difference used to evaluate power and explain why it is appropriate.', 'The target difference and its justification are', 'power'],
      ['variation', 'Variation or event rates', 'Give the standard deviation or anticipated event rates, their evidence sources, population and time point.', 'The variation or event rates used for planning are'],
      ['evidence_review', 'Evidence relevance and uncertainty', 'Which assumptions are least certain? Explain whether previous evidence fits this population, outcome and follow-up time.', 'The relevance and uncertainty of the evidence are'],
      ['sensitivity', 'Sensitivity analysis: alternative assumptions', 'Give plausible alternative differences, standard deviations or event rates and their sources. Distinguish recalculating required counts from evaluating the original sample held fixed.', 'The sensitivity scenarios and their evidence are'],
      ['progression', 'Feasibility objectives and progression criteria', 'State each feasibility outcome and denominator, unacceptable and desirable levels, and the decisions to proceed, amend or stop.', 'The feasibility objectives and progression criteria are', 'feasibility']
    ]],
    ['Analysis and information target', [
      ['analysis', 'Planned analysis', 'Name the test and confidence interval method. State the sidedness and relevant assumptions.', 'The planned analysis is'],
      ['power', 'Type I error rate and target power', 'State Type I error rate and target power as percentages. With fixed resources, record attainable power and the effect at which it is evaluated.', 'The Type I error rate and power specification is', 'power'],
      ['precision', 'Precision: desired confidence interval width', 'State the desired full confidence interval width, its units and the confidence level. With fixed resources, record attainable precision.', 'The precision specification is', 'precision']
    ]],
    ['Sample size, recruitment and conclusion', [
      ['counts', 'Sample size needed or available for analysis', 'Record analyzable participants per group and total, or one total for a single-population estimate. State the method, result and rounding. For existing data, explain why the sample is fixed.', 'The analyzable sample size and calculation are'],
      ['recruitment', 'Losses, missing data and recruitment', 'State expected losses and adjusted recruitment counts, or completeness and missing observations in an existing dataset. Explain possible bias separately from the count adjustment.', 'The loss allowance, missing data and recruitment are'],
      ['resources', 'Feasibility and resources', 'Record the recruitment rate and period, available patients, costs or constraints, and whether the target is feasible.', 'The recruitment feasibility and resources are'],
      ['conclusion', 'Intended conclusion and limitations', 'Explain what the design could establish, what remains uncertain and which planning decisions still need to be resolved.', 'The intended conclusion and limitations are']
    ]]
  ];
  const fields = groups.flatMap(group => group[1]);
  const names = ['study_type', 'outcome', 'goal', ...fields.map(field => field[0])];
  const choices = {study_type: ['comparison', 'single', 'other'], outcome: ['binary', 'continuous'], goal: ['testing', 'precision', 'fixed', 'both', 'feasibility']};
  const goalText = {testing: 'testing a specified hypothesis', precision: 'estimation with a precision target', fixed: 'assessing what fixed resources or existing data could establish', both: 'testing and estimation', feasibility: 'supporting a pilot or feasibility decision'};
  function validate(value) {
    if (!value || typeof value !== 'object' || Array.isArray(value) || Object.keys(value).some(key => !names.includes(key))) throw Error('Choose a supported assumptions-report file.');
    const clean = {};
    for (const name of names) {
      const text = value[name] ?? (name === 'study_type' ? 'comparison' : name === 'outcome' ? 'binary' : name === 'goal' ? 'testing' : '');
      if (typeof text !== 'string' || text.length > 5000 || (choices[name] && !choices[name].includes(text))) throw Error('The file contains an invalid answer or selection.');
      clean[name] = text;
    }
    return clean;
  }
  for (const [title, definitions] of groups) {
    const group = document.createElement('fieldset'), legend = document.createElement('legend');
    legend.textContent = title; group.append(legend);
    for (const [id, title, help] of definitions) {
      const wrapper = document.createElement('div'); wrapper.id = 'field-' + id;
      const label = document.createElement('label'); label.htmlFor = id; label.textContent = title;
      if (id === 'power') {
        const alpha = document.createElement('a'), power = document.createElement('a');
        alpha.href = '../student-materials/glossary.html#alpha'; alpha.textContent = 'Type I error rate';
        power.href = '../student-materials/glossary.html#statistical-power'; power.textContent = 'power';
        for (const link of [alpha, power]) { link.target = '_blank'; link.rel = 'noopener'; }
        label.replaceChildren(alpha, ' and target ', power);
      }
      const guidance = document.createElement('p'); guidance.className = 'field-help'; guidance.id = id + '-help'; guidance.textContent = help;
      const input = document.createElement('textarea'); input.id = id; input.name = id; input.rows = 3; input.maxLength = 5000; input.setAttribute('aria-describedby', guidance.id);
      wrapper.append(label, guidance, input); group.append(wrapper);
    }
    document.getElementById('fields').append(group);
  }
  const snapshot = () => Object.fromEntries(names.map(name => [name, form.elements[name].value]));
  function active(field, value) {
    if (field[4] === 'comparison') return value.study_type !== 'single';
    if (field[4] === 'power') return !['precision', 'feasibility'].includes(value.goal) && !(value.study_type === 'single' && value.goal === 'fixed');
    if (field[4] === 'precision') return value.goal !== 'testing';
    if (field[4] === 'feasibility') return value.goal === 'feasibility';
    return true;
  }
  const sentence = text => /[.!?]$/.test(text.trim()) ? text.trim() : text.trim() + '.';
  function notifyParent(type, extra = {}) { if (parent !== window) parent.postMessage({type: 'sample-size:' + type, app, ...extra}, location.origin); }
  function render(persist = true) {
    const value = snapshot(), article = document.getElementById('report'); article.replaceChildren();
    const single = value.study_type === 'single';
    for (const option of form.elements.goal.options) option.disabled = single && ['testing', 'both'].includes(option.value);
    if (single && ['testing', 'both'].includes(value.goal)) { value.goal = 'precision'; form.elements.goal.value = 'precision'; }
    document.getElementById('outcome-scale-help').textContent = value.outcome === 'binary' ? 'Report event rates as percentages (e.g. 60%) and absolute differences or interval widths in percentage points. State the denominator.' : 'Report means, differences, interval widths and standard deviations in the outcome’s units.';
    const wording = single ? {
      scale: ['Outcome scale and interpretation', 'State the percentage or mean to estimate and its units; there is no treatment difference for a descriptive estimate.', 'The outcome scale and interpretation are'],
      expected: ['Anticipated percentage or mean', 'Give an anticipated value and its evidence, if available. Distinguish it from the result observed in existing data.', 'The anticipated value and supporting evidence are']
    } : {};
    for (const id of ['scale', 'expected']) {
      const field = fields.find(field => field[0] === id), copy = wording[id];
      document.querySelector('label[for="' + id + '"]').textContent = copy ? copy[0] : field[1];
      document.getElementById(id + '-help').textContent = copy ? copy[1] : field[2];
    }
    const intro = document.createElement('p');
    const structure = {comparison: 'a two-group comparison', single: 'an estimate of one population percentage or mean', other: 'another design requiring a specified planning method'};
    intro.textContent = 'This study concerns ' + structure[value.study_type] + ' with a ' + value.outcome + ' outcome. Its planning goal is ' + goalText[value.goal] + '.'; article.append(intro);
    let completed = 0, required = 0;
    for (const [title, definitions] of groups) {
      const heading = document.createElement('h3'); heading.textContent = single && title === 'Effects and supporting evidence' ? 'Outcome and supporting evidence' : title; article.append(heading);
      for (const field of definitions) {
        const [id, originalLabel, , originalPrefix] = field, enabled = active(field, value);
        const label = wording[id] ? wording[id][0] : originalLabel, prefix = wording[id] ? wording[id][2] : originalPrefix;
        document.getElementById('field-' + id).hidden = !enabled;
        if (!enabled) continue;
        required++;
        const answer = value[id].trim(), paragraph = document.createElement('p');
        if (answer) { completed++; paragraph.textContent = prefix + ': ' + sentence(answer); }
        else { paragraph.className = 'missing'; paragraph.textContent = label + ': not yet specified.'; }
        article.append(paragraph);
      }
    }
    const progress = document.getElementById('progress');
    progress.textContent = completed === required ? 'All ' + required + ' prompts answered. Review the assumptions and calculations before sharing.' : 'Draft: ' + completed + ' of ' + required + ' prompts answered.';
    if (persist) { try { localStorage.setItem(storageKey, JSON.stringify(value)); } catch (_) { status.textContent = 'Browser saving is unavailable. Save your entries to a file.'; } }
    notifyParent('state', {state: value});
  }
  function apply(value) { const clean = validate(value); for (const name of names) form.elements[name].value = clean[name]; render(); }
  function download(text, type, filename) {
    const url = URL.createObjectURL(new Blob([text], {type})), link = document.createElement('a');
    link.href = url; link.download = filename; document.body.append(link); link.click(); link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }
  form.addEventListener('input', () => render());
  form.addEventListener('submit', event => event.preventDefault());
  document.getElementById('clear').addEventListener('click', () => { apply({}); status.textContent = 'Entries cleared. You can start a new plan.'; });
  document.getElementById('save').addEventListener('click', () => {
    download(JSON.stringify({schema: 'sample-size-assumptions-report', version: 1, entries: snapshot()}, null, 2), 'application/json', 'study-plan-entries.json'); status.textContent = 'Entries saved to a file.';
  });
  document.getElementById('download').addEventListener('click', () => {
    const lines = ['Study-plan report', document.getElementById('progress').textContent, '', ...Array.from(document.querySelectorAll('#report > *'), node => node.textContent)];
    download(lines.join('\n\n'), 'text/plain;charset=utf-8', 'study-plan-report.txt'); status.textContent = 'Report downloaded with the current answers and any missing entries marked.';
  });
  document.getElementById('restore').addEventListener('change', async event => {
    const file = event.target.files[0]; if (!file) return;
    try {
      if (file.size > 1000000) throw Error('Choose an entries file smaller than 1 MB.');
      const document = JSON.parse(await file.text());
      if (document.schema !== 'sample-size-assumptions-report' || document.version !== 1) throw Error('Choose a supported assumptions-report file.');
      apply(document.entries); status.textContent = 'Saved entries restored.';
    } catch (error) { status.textContent = 'Entries were not changed. ' + error.message; }
    event.target.value = '';
  });
  document.getElementById('example').addEventListener('click', async () => {
    try {
      const response = await fetch('../teaching-cases.json'); if (!response.ok) throw Error('Example unavailable.');
      const cases = await response.json(), input = cases.pain_one_many.inputs;
      const percent = value => Number((100 * value).toFixed(8));
      apply({study_type: 'comparison', outcome: 'binary', goal: 'fixed', question: 'Does a novel treatment improve pain relief compared with standard treatment in adults with chronic pain?',
        outcome_detail: 'Pain relief (yes/no) at four weeks',
        design: 'An individually randomized superiority trial with two independent groups and equal allocation',
        scale: 'Treatment minus control, in percentage points; a positive difference favors treatment',
        expected: percent(input.expected_p) + ' percentage points. The hypothetical pilot observed relief in 7/10 treated patients (70%) and 3/10 controls (30%); this small pilot gives an uncertain expectation',
        clinical: percent(input.threshold_p) + ' percentage points. This is an illustrative judgment about meaningful benefit that needs justification with patients and clinicians',
        planning: percent(input.plan_p1 - input.plan_p0) + ' percentage points, an illustrative difference judged worthwhile and realistic. Power at the smaller 20-point clinical threshold will be lower; a real plan must justify accepting that uncertainty',
        variation: percent(input.plan_p0) + '% relief in controls and ' + percent(input.plan_p1) + '% in the treatment group',
        evidence_review: 'The pilot contains only 10 patients per group. Check comparable studies, outcome definitions and follow-up times; the event rates and expected difference remain uncertain',
        sensitivity: 'Compare smaller true benefits while keeping the original sample size fixed. Specify plausible ranges using evidence beyond the pilot',
        analysis: 'A two-sided pooled score test without continuity correction, with a Newcombe-Wilson confidence interval; independent observations and allocation are assumed',
        power: 'Type I error rate ' + percent(input.alpha) + '%. Evaluate attainable power at the ' + percent(input.plan_p1 - input.plan_p0) + '-percentage-point target difference using the matched pain-relief activity',
        precision: 'Evaluate the attainable 95% confidence interval width at the fixed sample size. The activity compares it with a full width of ' + percent(input.width_p) + ' percentage points',
        counts: input.fixed_n + ' analyzable patients per group, ' + (2 * input.fixed_n) + ' in total; the illustrative sample size is held fixed to assess power and precision rather than selected to meet a target power',
        recruitment: percent(input.dropout) + '% expected losses. Recruit ' + Math.ceil(input.fixed_n / (1 - input.dropout)) + ' per group, ' + (2 * Math.ceil(input.fixed_n / (1 - input.dropout))) + ' in total using the expected-loss adjustment; this does not guarantee the final analyzable count',
        resources: 'The feasibility of the recruitment target must be assessed from eligible patients, consent, recruitment period and costs',
        conclusion: 'Assess power and precision at this fixed sample size before deciding what the trial could establish. A significant result alone does not establish a clinically meaningful benefit'});
      status.textContent = 'Hypothetical pain-relief example loaded. Replace illustrative assumptions and unresolved decisions with a justified plan.';
    } catch (error) { status.textContent = error.message + ' Your entries were not changed.'; }
  });
  window.addEventListener('message', event => {
    if (event.origin !== location.origin || event.source !== parent) return;
    if (event.data?.type === 'sample-size:activity' && event.data.activity === 'assumptions_report') {
      if (event.data.reset) { apply({}); status.textContent = 'Entries cleared. You can start a new plan.'; }
      else notifyParent('state', {state: snapshot()});
    }
  });
  try { const saved = localStorage.getItem(storageKey); if (saved) { apply(JSON.parse(saved)); status.textContent = 'Restored your entries from this browser.'; } else render(false); }
  catch (_) { render(false); status.textContent = 'Previous entries could not be restored. You can start a new plan or open a saved file.'; }
  notifyParent('ready');
})();

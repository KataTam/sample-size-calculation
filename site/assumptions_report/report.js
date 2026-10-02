/* A written justification activity; numerical results come from the calculators. */
(() => {
  'use strict';
  const app = 'assumptions_report', storageKey = 'sample-size-assumptions-report-v1';
  const form = document.getElementById('plan-form');
  const status = document.getElementById('status');
  const groups = [
    ['Question and design', [
      ['question', 'Clinical question', 'State the population, intervention and comparator.', 'The clinical question is'],
      ['outcome_detail', 'Primary outcome and time point', 'Define what will be measured and when.', 'The primary outcome and time point are'],
      ['design', 'Design and allocation', 'Describe two independent treatment groups, randomisation and the allocation ratio.', 'The design and allocation are']
    ]],
    ['Effects and supporting evidence', [
      ['scale', 'Effect scale and direction of benefit', 'Use treatment minus control. Specify whether a positive or negative difference is beneficial.', 'The effect scale and direction of benefit are'],
      ['expected', 'Expected effect', 'Give the best current expectation, its evidence source and uncertainty.', 'The expected effect and supporting evidence are'],
      ['clinical', 'Clinical threshold', 'Give the smallest benefit that matters to patients and justify that judgement.', 'The clinical threshold and its justification are'],
      ['planning', 'Planning effect', 'Give the difference used to evaluate power and explain why it is appropriate.', 'The planning effect and its justification are', 'power'],
      ['variation', 'Variation or event rates', 'For a continuous outcome, give the common standard deviation. For a binary outcome, give control and treatment percentages.', 'The variation or event rates used for planning are'],
      ['sensitivity', 'Sensitivity scenarios', 'Give plausible alternative effects, standard deviations or event rates and their sources.', 'The sensitivity scenarios and their evidence are']
    ]],
    ['Analysis and information target', [
      ['analysis', 'Planned analysis', 'Name the test and confidence interval method. State the sidedness and relevant assumptions.', 'The planned analysis is'],
      ['power', 'Alpha and power', 'State alpha and target power as percentages. With fixed resources, record attainable power and the effect at which it is evaluated.', 'The alpha and power specification is', 'power'],
      ['precision', 'Precision target', 'State the desired full confidence interval width, its units and the confidence level. With fixed resources, record attainable precision.', 'The precision specification is', 'precision']
    ]],
    ['Sample size, recruitment and conclusion', [
      ['counts', 'Analysable sample size', 'Record patients per group and total analysable patients, the calculation method and its result. Mark calculations still to be completed.', 'The analysable sample size and calculation are'],
      ['recruitment', 'Losses and recruitment target', 'State expected losses as a percentage, recruitment counts per group and total, and how the adjustment was made.', 'The loss allowance and recruitment target are'],
      ['resources', 'Feasibility and resources', 'Record the recruitment rate and period, available patients, costs or constraints, and whether the target is feasible.', 'The recruitment feasibility and resources are'],
      ['conclusion', 'Intended conclusion and limitations', 'Explain what the design could establish, what remains uncertain and which planning decisions still need to be resolved.', 'The intended conclusion and limitations are']
    ]]
  ];
  const fields = groups.flatMap(group => group[1]);
  const names = ['outcome', 'goal', ...fields.map(field => field[0])];
  const choices = {outcome: ['binary', 'continuous'], goal: ['testing', 'precision', 'fixed', 'both']};
  const goalText = {testing: 'testing for a treatment difference', precision: 'estimating the treatment difference with a precision target', fixed: 'assessing what fixed resources could establish', both: 'testing and estimating the treatment difference'};
  function validate(value) {
    if (!value || typeof value !== 'object' || Array.isArray(value) || Object.keys(value).some(key => !names.includes(key))) throw Error('Choose a supported assumptions-report file.');
    const clean = {};
    for (const name of names) {
      const text = value[name] ?? (name === 'outcome' ? 'binary' : name === 'goal' ? 'testing' : '');
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
        alpha.href = '../student-materials/glossary.html#alpha'; alpha.textContent = 'Alpha';
        power.href = '../student-materials/glossary.html#statistical-power'; power.textContent = 'power';
        for (const link of [alpha, power]) { link.target = '_blank'; link.rel = 'noopener'; }
        label.replaceChildren(alpha, ' and ', power);
      }
      const guidance = document.createElement('p'); guidance.className = 'field-help'; guidance.id = id + '-help'; guidance.textContent = help;
      const input = document.createElement('textarea'); input.id = id; input.name = id; input.rows = 3; input.maxLength = 5000; input.setAttribute('aria-describedby', guidance.id);
      wrapper.append(label, guidance, input); group.append(wrapper);
    }
    document.getElementById('fields').append(group);
  }
  const snapshot = () => Object.fromEntries(names.map(name => [name, form.elements[name].value]));
  function active(field, goal) { return field[4] === 'power' ? goal !== 'precision' : field[4] === 'precision' ? goal !== 'testing' : true; }
  const sentence = text => /[.!?]$/.test(text.trim()) ? text.trim() : text.trim() + '.';
  function notifyParent(type, extra = {}) { if (parent !== window) parent.postMessage({type: 'sample-size:' + type, app, ...extra}, location.origin); }
  function render(persist = true) {
    const value = snapshot(), article = document.getElementById('report'); article.replaceChildren();
    document.getElementById('outcome-scale-help').textContent = value.outcome === 'binary' ? 'Report event rates as percentages (e.g. 60%) and absolute differences in percentage points (e.g. 30 percentage points).' : 'Report treatment differences and standard deviations in the primary outcome’s units.';
    const intro = document.createElement('p'); intro.textContent = 'This two-arm clinical trial has a ' + value.outcome + ' primary outcome. Its planning goal is ' + goalText[value.goal] + '.'; article.append(intro);
    let completed = 0, required = 0;
    for (const [title, definitions] of groups) {
      const heading = document.createElement('h3'); heading.textContent = title; article.append(heading);
      for (const field of definitions) {
        const [id, label, , prefix] = field, enabled = active(field, value.goal);
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
      apply({outcome: 'binary', goal: 'fixed', question: 'Does a novel treatment improve pain relief compared with standard treatment in adults with chronic pain?',
        outcome_detail: 'Pain relief (yes/no) at four weeks',
        design: 'An individually randomised superiority trial with two independent groups and equal allocation',
        scale: 'Treatment minus control, in percentage points; a positive difference favours treatment',
        expected: percent(input.expected_p) + ' percentage points. The hypothetical pilot observed relief in 7/10 treated patients (70%) and 3/10 controls (30%); this small pilot gives an uncertain expectation',
        clinical: percent(input.threshold_p) + ' percentage points. This is an illustrative judgement about meaningful benefit that needs justification with patients and clinicians',
        planning: percent(input.plan_p1 - input.plan_p0) + ' percentage points, smaller than the expected benefit to allow for uncertainty in the pilot effect',
        variation: percent(input.plan_p0) + '% relief in controls and ' + percent(input.plan_p1) + '% in the treatment group',
        sensitivity: 'Compare smaller true benefits while keeping the original sample size fixed. Specify plausible ranges using evidence beyond the pilot',
        analysis: 'A two-sided pooled score test without continuity correction, with a Newcombe-Wilson confidence interval; independent observations and allocation are assumed',
        power: 'Alpha ' + percent(input.alpha) + '%. Evaluate attainable power at the ' + percent(input.plan_p1 - input.plan_p0) + '-percentage-point planning effect using the matched pain-relief activity',
        precision: 'Evaluate the attainable 95% confidence interval width at the fixed sample size. The activity compares it with a full width of ' + percent(input.width_p) + ' percentage points',
        counts: input.fixed_n + ' analysable patients per group, ' + (2 * input.fixed_n) + ' in total; the illustrative sample size is held fixed to assess power and precision rather than selected to meet a target power',
        recruitment: percent(input.dropout) + '% expected losses. Recruit ' + Math.ceil(input.fixed_n / (1 - input.dropout)) + ' per group, ' + (2 * Math.ceil(input.fixed_n / (1 - input.dropout))) + ' in total using the expected-loss adjustment; this does not guarantee the final analysable count',
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

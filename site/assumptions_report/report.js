/* A written justification activity; numerical results come from the calculators. */
(() => {
  'use strict';
  if (new URL(location.href).searchParams.get('guided') === '1') document.body.classList.add('guided');
  const app = 'assumptions_report', storageKey = 'sample-size-assumptions-report-v1';
  const form = document.getElementById('plan-form');
  const status = document.getElementById('status');
  const groups = [
    ['Question and design', [
      ['question', 'Research question', 'Your question should identify the decision the study will inform. The PICO fields below describe its components.', 'The research question is'],
      ['population', 'Population', 'Who should the findings apply to? Your description should include the setting and key eligibility criteria (PICO; SPIRIT 2025 items 13–14).', 'The population is'],
      ['intervention', 'Intervention or exposure', 'For an intervention, describe what is delivered, how much, how often, for how long and by whom. An observational study should define the exposure or group of interest (PICO; SPIRIT 2025 item 15).', 'The intervention or exposure is', 'comparison'],
      ['comparator', 'Comparator', 'Your description should identify the comparison condition and explain its choice. Usual care should be described, including permitted additional treatments (PICO; SPIRIT 2025 item 15).', 'The comparator is', 'comparison'],
      ['outcome_detail', 'Primary outcome and time point', 'The outcome definition should identify the measurement, how results are summarized and the assessment time (PICO; SPIRIT 2025 item 16).', 'The primary outcome and time point are'],
      ['design', 'Design, sampling and allocation', 'Describe how participants or records are selected, how observations are related, and any treatment allocation.', 'The design, sampling and allocation are']
    ]],
    ['Assumptions and evidence', [
      ['scale', 'Effect scale and direction of benefit', 'The effect scale gives the units of the comparison: for example, a difference in event percentages is in percentage points, while a mean difference may be in pain-score units. Use treatment minus control and specify which direction is beneficial.', 'The effect scale and direction of benefit are'],
      ['expected', 'Expected difference', 'Give the best current expectation, its evidence source and uncertainty.', 'The expected difference and supporting evidence are'],
      ['clinical', 'Clinically important difference (clinical threshold)', 'Give the smallest between-group benefit that matters to patients and justify that judgment.', 'The clinical threshold and its justification are', 'comparison'],
      ['planning', 'Target difference: used in the calculation', 'Give the difference used to evaluate power and explain why it is appropriate.', 'The target difference and its justification are', 'power'],
      ['variation', 'Variation or event probabilities', 'Give the standard deviation or anticipated event probabilities, their evidence sources, population and time point.', 'The variation or event probabilities used for planning are'],
      ['evidence_review', 'Evidence relevance and uncertainty', 'Which assumptions are least certain? Explain whether previous evidence fits this population, outcome and follow-up time.', 'The relevance and uncertainty of the evidence are'],
      ['sensitivity', 'Sensitivity analysis: alternative assumptions', 'Give plausible alternative differences, standard deviations or event probabilities and their sources. Distinguish recalculating required counts from evaluating the original sample held fixed.', 'The sensitivity scenarios and their evidence are'],
      ['progression', 'Feasibility objectives and progression criteria', 'State each feasibility outcome and denominator, unacceptable and desirable levels, and the decisions to proceed, amend or stop.', 'The feasibility objectives and progression criteria are', 'feasibility']
    ]],
    ['Calculation', [
      ['analysis', 'Planned analysis', 'Name the test and confidence interval method. State the sidedness and relevant assumptions.', 'The planned analysis is'],
      ['software', 'Calculation procedure and software', 'Your record should identify the calculation method, software and relevant versions, code version or source, and saved inputs. For simulation, it should also include the generating procedure, repetitions and random-number settings. Guidance is linked above.', 'The calculation procedure, software and reproducibility record are'],
      ['power', 'Type I error probability and target power', 'State Type I error probability and target power as percentages. With fixed resources, record attainable power and the effect at which it is evaluated.', 'The Type I error probability and power specification is', 'power'],
      ['precision', 'Precision: desired confidence interval width', 'State the desired full confidence interval width, its units and the confidence level. With fixed resources, record attainable precision.', 'The precision specification is', 'precision']
    ]],
    ['Recruitment and conclusion', [
      ['counts', 'Sample size needed or available for analysis', 'Record analyzable participants per group and total, or one total for a single-population estimate. State the method, result and rounding. For existing data, explain why the sample is fixed.', 'The analyzable sample size and calculation are'],
      ['recruitment', 'Losses, missing data and recruitment', 'Your expected losses should draw on comparable studies, routine records or pilot follow-up, with the population, time point and uncertainty recorded. There is no universal default. Give adjusted recruitment counts and plausible alternative losses, or completeness and missing observations in an existing dataset. Explain how missing outcomes could affect the comparison. Record anticipated treatment switching, adherence and rescue medication, and whether their impact is already included in the calculation.', 'The loss allowance, missing data and recruitment are'],
      ['resources', 'Feasibility and resources', 'Record the recruitment rate and period, available patients, costs or constraints, and whether the target is feasible.', 'The recruitment feasibility and resources are'],
      ['conclusion', 'Intended conclusion and limitations', 'Explain what the design could establish, what remains uncertain and which planning decisions still need to be resolved.', 'The intended conclusion and limitations are']
    ]]
  ];
  groups[2][1].push(groups[3][1].shift());
  const fields = groups.flatMap(group => group[1]);
  let reportLines = [];
  const questions = {
    question: 'What question should your study answer?',
    population: 'Who is the study about? (Population)',
    intervention: 'What intervention or exposure will you study? (Intervention)',
    comparator: 'What will you compare it with? (Comparator)',
    outcome_detail: 'What outcome will you measure, and when? (Outcome)',
    design: 'How will participants be selected and, where relevant, allocated?',
    scale: 'How will you express the difference between groups?',
    expected: 'What difference do you expect, and what supports it?',
    clinical: 'What between-group difference would matter clinically?',
    planning: 'What target difference will you use for the power calculation?',
    variation: 'What event percentages or standard deviation will you assume?',
    evidence_review: 'How relevant and reliable is the supporting evidence?',
    sensitivity: 'Which alternative assumptions could change your recommendation?',
    progression: 'Which results would support proceeding, amending or stopping?',
    analysis: 'How will you analyze the primary outcome?',
    software: 'How could someone reproduce your calculation?',
    power: 'What Type I error probability and power will you use?',
    precision: 'What confidence interval width would be useful?',
    counts: 'How many participants are needed or available for analysis?',
    recruitment: 'How will losses or treatment changes affect your plan?',
    resources: 'Can you recruit enough participants with the available resources?',
    conclusion: 'What could the study establish, and what remains uncertain?'
  };
  const modelAnswers = {
    question: 'Does a novel treatment improve pain relief at four weeks compared with standard treatment in adults with chronic pain?',
    population: 'Adults with chronic pain attending the participating clinics. Eligibility criteria should specify the pain condition, its duration and relevant exclusions.',
    intervention: 'A novel pain treatment. Its dose or intensity, delivery, provider and schedule still need to be specified in the protocol.',
    comparator: 'Standard treatment over the same follow-up period. Its content, permitted additional care and the reason for choosing it should be documented.',
    outcome_detail: 'The percentage of patients reporting pain relief four weeks after treatment starts, using the same prespecified definition of relief in both groups.',
    design: 'An individually randomized superiority trial with two independent groups and equal allocation. Eligible patients will be recruited from participating clinics.',
    scale: 'The difference in pain-relief percentages, novel minus standard treatment, in percentage points. A positive difference favors the novel treatment.',
    expected: '40 percentage points: the hypothetical pilot observed relief in 70% versus 30%. With 10 patients per group, this estimate is uncertain.',
    clinical: '20 percentage points, an illustrative between-group threshold. A real plan should justify this judgment using patient and clinical input.',
    planning: '30 percentage points, judged worthwhile and realistic for this teaching example. The choice needs evidence; power will be lower at the 20-point clinical threshold.',
    variation: '30% relief with standard treatment and 60% with novel treatment for the calculation. These illustrative percentages imply the 30-point target difference.',
    evidence_review: 'The small pilot provides uncertain event percentages. Comparable studies should be checked for the same population, definition of relief and four-week assessment.',
    sensitivity: 'Assess power at benefits of 20, 30 and 40 percentage points while keeping the selected sample fixed and standard-treatment relief at 30%. Evidence should support the plausible range.',
    progression: 'Retention at four weeks among all enrolled patients will inform feasibility. Proceed, amend and stop thresholds should be agreed with the study team before data collection.',
    analysis: 'A two-sided test of the difference in pain-relief percentages between independent groups, with a 95% confidence interval. The selected calculation should use the planned test.',
    software: 'The two-proportion app uses the tutorial normal approximation. The dated report records inputs, rounding and source version; the exact software versions should be saved with the calculation.',
    power: 'A 5% Type I error probability and 90% target power at a 30-percentage-point difference, using a two-sided test.',
    precision: 'A 95% confidence interval with a full width of 20 percentage points would give a margin of about 10 points. Its usefulness should be justified for the clinical decision.',
    counts: '56 analyzable patients per group, 112 in total, using the tutorial approximation with 30% versus 60% relief, 5% Type I error probability and 90% power.',
    recruitment: 'With illustrative 10% expected losses, 56 / 0.90 rounds up to 63 patients per group (126 total). Evidence should support the loss assumption; missing outcomes and treatment changes also need an analysis plan.',
    resources: 'The clinics expect 20 eligible patients per month and 70% consent: about 14 recruits per month. Recruiting 126 would take about nine months before allowing for interruptions.',
    conclusion: 'The plan evaluates power at the target difference. A smaller benefit could be missed; the estimate and confidence interval will help judge clinical importance. The assumptions and recruitment capacity need review.'
  };
  function examples(value) {
    const result = {...modelAnswers};
    if (value.outcome === 'continuous') Object.assign(result, {
      question: 'Does the novel treatment improve the mean pain-improvement score at four weeks compared with standard treatment in adults with chronic pain?',
      outcome_detail: 'Mean improvement in pain score from baseline to four weeks, using a prespecified scoring rule. Larger improvement means greater benefit.',
      scale: 'The between-group mean difference in pain-improvement score, novel minus standard treatment, in score units.',
      expected: '4 score units, the best current expectation in the teaching example. Its evidence source and uncertainty need to be justified.',
      clinical: '2 score units between groups, an illustrative threshold requiring patient and clinical justification.',
      planning: '3 score units, the target difference used for power. A smaller 2-unit benefit would have lower power at the same sample size.',
      variation: 'A common standard deviation of 5 score units, supported by studies with comparable patients and measurement times.',
      analysis: 'A two-sided comparison of independent group means with a 95% confidence interval for the mean difference. The analysis should reflect the distribution and design.',
      software: 'The two-mean app uses the tutorial normal approximation. The report records the difference, SD, error probabilities, rounding and source version.',
      power: 'A 5% Type I error probability and 90% target power at a between-group mean difference of 3 score units.',
      precision: 'A 95% confidence interval with a full width of 4 score units would have a margin of about 2 units. Its usefulness needs clinical justification.',
      counts: '59 analyzable patients per group, 118 total, using the tutorial normal approximation with a 3-unit target, SD 5, 5% Type I error probability and 90% power.',
      recruitment: 'With illustrative 10% expected losses, 59 / 0.90 rounds up to 66 patients per group (132 total). Missing outcomes and treatment changes also need an analysis plan.',
      resources: 'At 20 eligible patients per month and 70% consent, recruitment of 132 would take about ten months, allowing only for whole months.',
      sensitivity: 'Assess power at true differences of 2, 3 and 4 units, and plausible SDs around 5, holding the selected sample fixed. The ranges need evidence.',
      evidence_review: 'The expected difference and SD should come from comparable patients, measurement methods and follow-up times. Small pilot estimates can be unstable.'
    });
    if (value.study_type === 'single') Object.assign(result, {
      question: value.outcome === 'binary' ? 'What percentage of adults in the target population have the condition during the specified survey period?' : 'What is the mean pain score in the target population at the specified assessment time?',
      population: 'Adults registered with the participating clinics during the survey period, sampled using a prespecified eligibility and sampling procedure.',
      outcome_detail: value.outcome === 'binary' ? 'Presence of the condition (yes/no), assessed using the same definition at the survey visit.' : 'Pain score measured with the same scale at the survey visit.',
      design: 'A cross-sectional survey with independent sampling from the defined population. The sampling procedure and nonresponse should be documented.',
      scale: value.outcome === 'binary' ? 'The population percentage with the condition; confidence interval width is measured in percentage points.' : 'The population mean pain score; confidence interval width is measured in score units.',
      expected: value.outcome === 'binary' ? '20%, based on a previous survey. Its population, assessment period and uncertainty should be checked.' : 'A previous comparable survey suggests a mean pain score of 5; its relevance and uncertainty should be checked.',
      variation: value.outcome === 'binary' ? 'An anticipated percentage of 20%, with 50% examined as a conservative planning assumption if prior evidence is weak.' : 'An SD of 2 score units from a comparable survey, with larger SDs assessed in sensitivity analyses.',
      analysis: value.outcome === 'binary' ? 'The observed percentage and a 95% Wilson confidence interval for independent binary outcomes.' : 'The sample mean and a 95% confidence interval appropriate to the sampling design.',
      precision: value.outcome === 'binary' ? 'A 95% confidence interval with full width 10 percentage points (a margin of about 5 points), chosen to inform service planning.' : 'A 95% confidence interval with full width 1 score unit, chosen to inform service planning.',
      counts: value.outcome === 'binary' ? '246 participants for analysis using the normal approximation with an anticipated 20%, 95% confidence and a 5-point margin of error.' : '62 participants using the normal approximation with SD 2 and a 0.5-unit margin of error at 95% confidence; the final method should be checked.',
      recruitment: 'The recruitment allowance should reflect the expected nonresponse and missing measurements. The denominator and reasons for missing observations will be recorded.',
      resources: 'The sampling frame, contact rate, expected consent and assessment time should support the required total within the available period.',
      software: 'The calculation record includes the one-population method, confidence level, interval-width target, assumptions, software version and rounding.',
      sensitivity: 'Compare required counts across plausible population values and variation, then evaluate attainable interval width at the selected sample.',
      evidence_review: 'The earlier survey should be checked for comparable sampling, outcome definitions and assessment time. Nonresponse could limit applicability.',
      conclusion: 'The study will estimate the population value with a confidence interval. Sampling coverage and nonresponse affect how well the findings represent the population.'
    });
    if (value.goal === 'fixed') Object.assign(result, {
      counts: value.study_type === 'single' ? '246 eligible records are available for the new question. Outcome completeness and the achievable interval width should be assessed.' : '20 analyzable participants per group (40 total) are available in this illustrative scenario. The sample remains fixed when assessing power and precision.',
      power: value.outcome === 'binary' ? 'Use a 5% Type I error probability and evaluate attainable power at a 30-point true difference with 20 patients per group. The app result should be recorded.' : 'Use a 5% Type I error probability and evaluate attainable power at a 3-unit difference with 20 patients per group. The app result should be recorded.',
      recruitment: value.study_type === 'single' ? 'The available records will be checked for missing outcomes and eligibility. The report will give the usable denominator and reasons for exclusions.' : 'With illustrative 10% expected losses, 20 / 0.90 rounds up to 23 per group (46 total). Actual retention can vary.',
      conclusion: 'The available sample sets the limit on precision and power at prespecified differences. These results should determine which conclusions the study can support.'
    });
    if (value.goal === 'feasibility') Object.assign(result, {
      question: 'Can the planned recruitment and follow-up procedures be delivered within the available time and resources?',
      outcome_detail: value.outcome === 'binary' ? 'Retention at four weeks (yes/no), with all enrolled participants in the denominator.' : 'Time needed to complete the study assessment, in minutes, measured for every participant.',
      scale: value.outcome === 'binary' ? 'The percentage retained at four weeks, reported overall and by group if relevant.' : 'Mean assessment time in minutes, reported overall and by group if relevant.',
      expected: value.outcome === 'binary' ? 'Previous follow-up suggests about 80% retention. The population and follow-up period should be comparable.' : 'Previous sessions suggest a mean assessment time of 30 minutes. Its relevance to these procedures should be checked.',
      variation: value.outcome === 'binary' ? 'An anticipated retention of 80%, with a plausible lower value included in sensitivity analysis.' : 'The SD of assessment times should be estimated from comparable procedures and its uncertainty examined.',
      counts: 'The required total will be justified from the feasibility objective, desired precision and prespecified progression criteria.',
      analysis: 'A summary and confidence interval for each feasibility outcome, compared with its prespecified progression criteria.',
      precision: 'The interval-width target should be narrow enough to support the agreed progression decision. The outcome units and confidence level will be recorded.',
      progression: 'The team will agree acceptable recruitment and follow-up performance, with prospective criteria for proceeding, amending or stopping.',
      conclusion: 'The feasibility estimates and agreed progression criteria will inform whether the study should proceed, be amended or stop.'
    });
    if (value.study_type === 'other') {
      result.design = 'A study with repeated measurements within participants. The allocation unit, measurement times and dependence between observations will be specified.';
      result.counts = 'A design-specific calculation is needed. The report should give both the number of independent participants or clusters and the observations within each.';
      result.analysis = 'A method that accounts for the allocation structure and dependence between observations, specified with statistical advice.';
    }
    if (value.goal === 'fixed' && value.study_type !== 'single') {
      result.resources = 'The recruitment target in this example is 46 patients for an expected 40 analyzable outcomes. At 14 recruits per month, this would take about four whole months, allowing for no interruptions.';
    }
    const recorded = fields.some(([id]) => (value[id] || '').trim());
    // Written entries can contain any study's assumptions. Numerical guidance
    // refers to those entries; it never guesses parameters from free text.
    if (recorded || ['precision', 'both', 'feasibility'].includes(value.goal) || value.study_type === 'other') {
      Object.assign(result, {
        expected: value.study_type === 'single' ? 'My anticipated population percentage or mean follows the evidence recorded for this population, outcome and assessment time.' : 'My expected between-group difference follows the evidence recorded for this population, outcome and assessment time.',
        clinical: 'My clinical threshold is the smallest between-group benefit judged worthwhile, supported by patient and clinical input.',
        planning: 'My target difference is the between-group difference at which the recorded calculation evaluates power. Its size should be worthwhile and supported by evidence.',
        variation: value.outcome === 'binary' ? 'The event percentages in my calculation use the same event definition, population and time point as my study question.' : 'The standard deviation in my calculation describes variation between participants on the stated outcome scale.',
        evidence_review: 'My evidence review checks the population, outcome definition, follow-up time and uncertainty of each assumption recorded above.',
        sensitivity: 'My sensitivity analysis evaluates plausible alternative assumptions using the selected sample size. I also record any revised sample size needed to meet the planning target.',
        power: value.goal === 'fixed' ? 'I report the attainable power at the recorded sample size and specified true difference, together with the Type I error probability and test sidedness.' : 'I report the Type I error probability, target power, target difference and test sidedness used for the calculation.',
        precision: 'I report the confidence level, desired full interval width and attainable width at the selected sample size, in the outcome units.',
        counts: value.goal === 'fixed' ? 'I report the number available for analysis, its source and any exclusions, with per-group and total counts where applicable.' : value.goal === 'both' ? 'I compare the counts required for power and precision and use the larger requirement, recording the method and final upward rounding.' : value.goal === 'feasibility' ? 'I justify the total from the feasibility outcomes, their desired precision and the agreed progression criteria.' : 'I report the analyzable count returned by the method appropriate to this design and planning goal, including upward rounding and per-group or total counts.',
        recruitment: value.goal === 'fixed' && value.study_type === 'single' ? 'I document eligibility and missing measurements in the available records and report the resulting usable denominator.' : 'I divide the required analyzable count by the expected retained fraction and round upward. My report records the resulting recruitment count, supporting evidence and plans for missing outcomes and treatment changes.',
        resources: 'I compare the recorded recruitment requirement with eligible participants, expected consent and the time available, allowing for interruptions and other constraints.',
        software: 'I record the procedure used for the current design and goal, its software and source version, numerical inputs and rounding. A simulation record also identifies the generating assumptions and repetitions.'
      });
      if (value.goal === 'feasibility') {
        result.expected = 'My anticipated retention percentage or assessment time follows evidence from comparable procedures and follow-up.';
        result.variation = value.outcome === 'binary' ? 'My anticipated feasibility percentage has an explicit denominator and a plausible range supported by prior evidence.' : 'My assumed SD describes variation in assessment time, in minutes, based on comparable procedures.';
      }
    }
    return result;
  }
  const names = ['study_type', 'outcome', 'goal', ...fields.map(field => field[0])];
  const choices = {study_type: ['comparison', 'single', 'other'], outcome: ['binary', 'continuous'], goal: ['testing', 'precision', 'fixed', 'both', 'feasibility']};
  const goalText = {testing: 'planning sample size to achieve specified power', precision: 'estimation with a precision target', fixed: 'assessing what fixed resources or existing data could establish', both: 'meeting both power and precision requirements', feasibility: 'supporting a pilot or feasibility decision'};
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
  for (const [index, [title, definitions]] of groups.entries()) {
    const group = document.createElement('details'), heading = document.createElement('summary');
    group.className = 'plan-section'; group.id = 'plan-section-' + index; group.open = index === 0;
    heading.textContent = title; group.append(heading);
    for (const [id, title, help] of definitions) {
      const wrapper = document.createElement('div'); wrapper.id = 'field-' + id;
      const label = document.createElement('label'); label.htmlFor = id; label.textContent = questions[id] || title;
      const input = document.createElement('textarea'); input.id = id; input.name = id; input.rows = 4; input.maxLength = 5000;
      wrapper.append(label, input); group.append(wrapper);

    }
    document.getElementById('fields').append(group);
  }
  document.getElementById('plan-section-0').append(document.getElementById('study-settings'));
  const preview = document.getElementById('preview');
  preview.addEventListener('click', () => {
    const pane = document.getElementById('report-pane'), show = pane.hidden;
    pane.hidden = !show; document.body.classList.toggle('report-visible', show);
    preview.setAttribute('aria-expanded', String(show));
    preview.textContent = show ? 'Back to questions' : 'Preview report';
    if (show) document.getElementById('report-title').focus();
    else preview.focus();
  });
  for (const [id, help] of Object.entries({
    study_type: 'Your choice controls which questions are relevant. Another design needs its own sample-size method.',
    outcome: 'A binary outcome records two possibilities, such as relief or no relief. A continuous outcome records a numerical measurement, such as a pain score.',
    goal: 'Power describes the probability of detecting a specified true difference. A precision target specifies a desired confidence interval width. With a fixed sample, you assess the attainable power or precision.'
  })) {
    const label = document.querySelector('label[for="' + id + '"]'), input = form.elements[id];
    const text = label.firstChild.textContent; label.after(input); label.textContent = text;
    InputGuidance.attach(label, help, input);
  }
  const snapshot = () => Object.fromEntries(names.map(name => [name, form.elements[name].value]));
  function active(field, value) {
    if (field[0] === 'clinical' && value.goal === 'feasibility') return false;
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
    const wording = single ? {
      scale: ['Outcome scale and interpretation', 'Your description should specify the population percentage or mean and its units.', 'The outcome scale and interpretation are', 'What population value will you estimate, and in which units?'],
      expected: ['Anticipated percentage or mean', 'Your anticipated value should have an evidence source, if available. An estimate from existing data is a result to report.', 'The anticipated value and supporting evidence are', 'What population percentage or mean do you anticipate?']
    } : {};
    if (value.goal === 'feasibility') Object.assign(wording, {
      scale: ['Feasibility outcome scale', 'The units should match the feasibility objective, such as retention percentage or assessment time.', 'The feasibility outcome scale is', 'How will you express the feasibility outcome?'],
      expected: ['Anticipated feasibility outcome', 'Prior evidence should inform the expected recruitment, retention or other feasibility outcome.', 'The anticipated feasibility outcome is', 'What feasibility result do you anticipate?']
    });
    const answers = examples(value);
    for (const field of fields) {
      const [id, title, help] = field, copy = wording[id];
      const label = document.querySelector('label[for="' + id + '"]');
      label.textContent = copy ? copy[3] : questions[id] || title;
      InputGuidance.attach(label, copy ? copy[1] : help, form.elements[id], answers[id]);
    }
    const intro = document.createElement('p');
    const structure = {comparison: 'a two-group comparison', single: 'an estimate of one population percentage or mean', other: 'another design requiring a specified planning method'};
    intro.textContent = 'This study concerns ' + structure[value.study_type] + ' with a ' + value.outcome + ' outcome. Its planning goal is ' + goalText[value.goal] + '.';
    reportLines = [intro.textContent];
    const missing = document.querySelector('#report-missing ul'); missing.replaceChildren();
    let completed = 0, required = 0;
    for (const [title, definitions] of groups) {
      const heading = document.createElement('h3'); heading.textContent = title;
      const paragraphs = [];
      reportLines.push(title);
      for (const field of definitions) {
        const [id, originalLabel, , originalPrefix] = field, enabled = active(field, value);
        const label = wording[id] ? wording[id][0] : originalLabel, prefix = wording[id] ? wording[id][2] : originalPrefix;
        document.getElementById('field-' + id).hidden = !enabled;
        if (!enabled) continue;
        required++;
        const answer = value[id].trim(), paragraph = document.createElement('p');
        if (answer) { completed++; paragraph.textContent = prefix + ': ' + sentence(answer); paragraphs.push(paragraph); }
        else { const item = document.createElement('li'); item.textContent = label; missing.append(item); paragraph.textContent = label + ': not yet specified.'; }
        reportLines.push(paragraph.textContent);
      }
      if (paragraphs.length) article.append(heading, ...paragraphs);
    }
    if (completed) article.prepend(intro);
    else { const empty = document.createElement('p'); empty.textContent = 'Your report will appear here as you answer the questions. You can leave decisions open and return to them later.'; article.append(empty); }
    document.getElementById('report-missing').hidden = completed === required;
    const progress = document.getElementById('progress');
    const progressText = completed === required ? 'All ' + required + ' prompts answered. Your assumptions and calculations still need review.' : 'Draft: ' + completed + ' of ' + required + ' prompts answered.';
    if (progress.textContent !== progressText) progress.textContent = progressText;
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
  const escapeHTML = text => String(text).replace(/[&<>"']/g, c => ({'&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;'}[c]));
  function reportDocument() {
    const entries = snapshot(), payload = JSON.stringify({schema: 'sample-size-assumptions-report', version: 2, entries}).replace(/</g, '\\u003c');
    const headings = new Set(groups.map(group => group[0]));
    const content = reportLines.map(line => headings.has(line) ? '<h2>' + escapeHTML(line) + '</h2>' : '<p>' + escapeHTML(line) + '</p>').join('\n');
    return '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Study-plan report</title>' +
      '<style>body{max-width:800px;margin:2rem auto;padding:0 1rem;font:17px/1.6 system-ui,sans-serif;color:#20343e}p{white-space:pre-wrap;overflow-wrap:anywhere}h2{margin-top:1.5em;font-size:1.2em}a{color:#006481}footer{border-top:1px solid #abc;margin-top:2rem;font-size:.9em}@media print{body{margin:0;max-width:none;font-size:11pt}h2{break-after:avoid}a{color:inherit}}</style></head><body><h1>Study-plan report</h1>' +
      '<p>' + escapeHTML(document.getElementById('progress').textContent) + '</p>' + content +
      '<footer><p>This draft contains your entries and identifies unanswered decisions. You can print it or save it as PDF using your browser. To continue editing, reopen this HTML file in the <a href="https://katatam.github.io/sample-size-calculation/assumptions_report/">study-plan activity</a>.</p>' +
      document.getElementById('guidance-credit').innerHTML.replace(/<(\/?)(?:details)[^>]*>/g, '<$1section>').replace(/<(\/?)(?:summary)>/g, '<$1h2>') + '</footer>' +
      '<script type="application/json" id="study-plan-data">' + payload + '</script></body></html>';
  }
  function saveReport() {
    download(reportDocument(), 'text/html;charset=utf-8', 'study-plan-report.html');
    status.textContent = 'Readable HTML report saved. You can reopen this file here to continue editing.';
  }
  document.getElementById('save').addEventListener('click', saveReport);
  document.getElementById('download').addEventListener('click', saveReport);
  document.getElementById('download-text').addEventListener('click', () => {
    const lines = ['Study-plan report', document.getElementById('progress').textContent, '', ...reportLines,
      'Guidance: PICO (Richardson et al., 1995), https://doi.org/10.7326/ACPJC-1995-123-3-A12; SPIRIT 2025, https://www.consort-spirit.org/; DELTA² (Cook et al., 2018), https://doi.org/10.1136/bmj.k3750. Educational selection; a full protocol should use its complete design-specific guidance.',
      'Teaching materials: CC BY-SA 4.0, https://creativecommons.org/licenses/by-sa/4.0/. Software: MIT, https://opensource.org/license/mit.'];
    download(lines.join('\n\n'), 'text/plain;charset=utf-8', 'study-plan-report.txt'); status.textContent = 'Plain-text report downloaded.';
  });
  document.getElementById('restore').addEventListener('change', async event => {
    const file = event.target.files[0]; if (!file) return;
    try {
      if (file.size > 1000000) throw Error('Choose a saved report or entries file smaller than 1 MB.');
      const text = await file.text();
      const payload = text.match(/<script\b(?=[^>]*\bid=["']study-plan-data["'])(?=[^>]*\btype=["']application\/json["'])[^>]*>([\s\S]*?)<\/script\s*>/i);
      const saved = JSON.parse(text.trim().startsWith('{') ? text : payload?.[1] || 'null');
      if (!saved || saved.schema !== 'sample-size-assumptions-report' || ![1, 2].includes(saved.version)) throw Error('Choose an HTML report or earlier JSON entries file saved by this activity.');
      apply(saved.entries); status.textContent = 'Saved entries restored.';
    } catch (error) { status.textContent = 'Entries were not changed. ' + error.message; }
    event.target.value = '';
  });
  document.getElementById('example').addEventListener('click', async () => {
    try {
      const response = await fetch('../teaching-cases.json'); if (!response.ok) throw Error('Example unavailable.');
      const cases = await response.json(), input = cases.pain_one_many.inputs;
      const percent = value => Number((100 * value).toFixed(8));
      apply({study_type: 'comparison', outcome: 'binary', goal: 'fixed', question: 'Does a novel treatment improve pain relief compared with standard treatment in adults with chronic pain?',
        population: modelAnswers.population,
        intervention: modelAnswers.intervention,
        comparator: modelAnswers.comparator,
        outcome_detail: 'Pain relief (yes/no) at four weeks',
        design: 'An individually randomized superiority trial with two independent groups and equal allocation',
        scale: 'Treatment minus control, in percentage points; a positive difference favors treatment',
        expected: percent(input.expected_p) + ' percentage points. The hypothetical pilot observed relief in 7/10 treated patients (70%) and 3/10 controls (30%); this small pilot gives an uncertain expectation',
        clinical: percent(input.threshold_p) + ' percentage points. This is an illustrative judgment about meaningful benefit that needs justification with patients and clinicians',
        planning: percent(input.plan_p1 - input.plan_p0) + ' percentage points, an illustrative difference judged worthwhile and realistic. Power at the smaller 20-point clinical threshold will be lower; a real plan must justify accepting that uncertainty',
        variation: percent(input.plan_p0) + '% relief in controls and ' + percent(input.plan_p1) + '% in the treatment group',
        evidence_review: 'The pilot contains only 10 patients per group. Check comparable studies, outcome definitions and follow-up times; the event probabilities and expected difference remain uncertain',
        sensitivity: 'Compare smaller true benefits while keeping the original sample size fixed. Specify plausible ranges using evidence beyond the pilot',
        analysis: 'A two-sided pooled score test without continuity correction, with a Newcombe-Wilson confidence interval; independent observations and allocation are assumed',
        power: 'Type I error probability ' + percent(input.alpha) + '%. Evaluate attainable power at the ' + percent(input.plan_p1 - input.plan_p0) + '-percentage-point target difference using the matched pain-relief activity',
        precision: 'Evaluate the attainable 95% confidence interval width at the fixed sample size. The activity compares it with a full width of ' + percent(input.width_p) + ' percentage points',
        counts: input.fixed_n + ' analyzable patients per group, ' + (2 * input.fixed_n) + ' in total; the illustrative sample size is held fixed to assess power and precision',
        recruitment: percent(input.dropout) + '% expected losses. Recruit ' + Math.ceil(input.fixed_n / (1 - input.dropout)) + ' per group, ' + (2 * Math.ceil(input.fixed_n / (1 - input.dropout))) + ' in total using the expected-loss adjustment; actual retention may vary',
        resources: 'The feasibility of the recruitment target must be assessed from eligible patients, consent, recruitment period and costs',
        conclusion: 'Assess power and precision at this fixed sample size before deciding what the trial could establish. Clinical interpretation should compare the estimate and confidence interval with zero and the clinical threshold'});
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

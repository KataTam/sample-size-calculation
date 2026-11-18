/* Conditional study-design prompts. Teaching text CC BY-SA 4.0; code MIT. */
(() => {
  'use strict';
  const features = {
    clustered: ['Clustered or multicenter study', 'cluster_details', 'Clusters and sites',
      'How do clusters or sites enter the calculation?',
      'Your record should distinguish randomization to whole groups from individual randomization within sites. Include cluster/site counts, sizes and relevant correlations, with the analysis used.',
      '[Allocation unit]; [number of clusters or sites] with [size and size variation]. The calculation uses [correlation assumptions and evidence] and [analysis method].'],
    paired: ['Paired or repeated measurements', 'paired_details', 'Related measurements',
      'Which measurements are related, and how is this accounted for?',
      'Your answer should give the measurement schedule, pairing or repeated-measures structure, correlations and their sources. The calculation and analysis should use the same structure.',
      'Each participant contributes [measurements at specified times or sites]. [Correlation or SD of differences] from [source] is used with [analysis method].'],
    survival: ['Time-to-event outcome', 'survival_details', 'Events and follow-up',
      'How many events and participants are needed, and over what period?',
      'Your record should define the event, effect measure, event assumptions, accrual and follow-up periods, and censoring. Give the required event count and the recruitment needed to observe it.',
      '[Event] is measured from [time origin]. Assuming [survival or event pattern] and [effect measure], [events] are required. Recruitment lasts [duration], with [follow-up] and [censoring assumptions], giving [participants].'],
    margins: ['Noninferiority or equivalence', 'margin_details', 'Noninferiority or equivalence margin',
      'What margin and hypotheses define the comparison?',
      'Your answer should specify the margin, scale, direction, clinical justification and supporting evidence. Include the null and alternative hypotheses and error probability for the chosen testing procedure.',
      '[Noninferiority or equivalence] uses [margin and units], justified by [clinical and historical evidence]. The hypotheses are [H0 and H1], tested with [procedure and error probability].'],
    multiple: ['Multiple endpoints or comparisons', 'testing_details', 'Confirmatory claims',
      'Which claims must succeed, and how are multiple tests handled?',
      'Your record should identify the primary claims, whether all or any must succeed, their testing order, and the error-control method. Planning may also need correlations between outcomes.',
      'Success requires [all or specified claims]. [Testing order and error-control method] apply to [family of hypotheses], with [outcome correlations and evidence] used for planning.'],
    interim: ['Interim analyses or adaptations', 'interim_details', 'Interim decisions and sample size',
      'When can the study stop or change, and how is that planned?',
      'Your record should specify the timing, information available and rules for stopping or adaptation, including the final analysis. Give maximum and expected sample sizes where applicable, with the scenarios used.',
      'At [times or information fractions], [decision rules] may stop or adapt the study. [Final method] gives [error probability and power] under [scenarios]. Maximum sample size is [count]; expected sample size is [count under stated scenario].'],
    simulation: ['Simulation-based calculation', 'simulation_details', 'Simulation record',
      'How was the design evaluated by simulation?',
      'Your record should give the data-generating assumptions, analysis and decision rules, repetitions, performance criteria and Monte Carlo uncertainty. The software entry should identify code versions and random-number settings.',
      '[Generating assumptions and scenarios] were evaluated using [analysis and decision rules] over [repetitions]. [Performance estimates and Monte Carlo uncertainty] support [selected sample size and decision].']
  };
  const selected = value => new Set([...(value.advanced_features || '').split(',').filter(Boolean), ...(value.outcome === 'survival' ? ['survival'] : [])]);
  const complex = value => value.study_type === 'other' || ['survival','other'].includes(value.outcome) || selected(value).size > 0;
  const fields = Object.entries(features).map(([key, [,id,title,,help]]) => [id,title,help,'The '+title.toLowerCase()+' are','feature:'+key]);
  const formats = Object.fromEntries(Object.values(features).map(([,id,,,,answer]) => [id,answer]));
  const questions = Object.fromEntries(Object.values(features).map(([,id,,question]) => [id,question]));
  function validate(value) {
    const keys=(value.advanced_features || '').split(',').filter(Boolean);
    if(keys.some(key=>!Object.hasOwn(features,key)) || new Set(keys).size!==keys.length) throw Error('Invalid design selection.');
  }
  function init(form) {
    const holder=document.getElementById('advanced-features');
    Object.entries(features).forEach(([key,[title]])=>{
      const label=document.createElement('label'), input=document.createElement('input');
      input.type='checkbox';input.dataset.planFeature=key;
      input.addEventListener('input',event=>{
        event.stopPropagation();
        form.elements.advanced_features.value=[...holder.querySelectorAll('input:checked')].map(el=>el.dataset.planFeature).join(',');
        form.elements.advanced_features.dispatchEvent(new Event('input',{bubbles:true}));
      });
      label.append(input,document.createTextNode(title));holder.append(label);
    });
  }
  function sync(value) {
    document.getElementById('advanced-features').hidden=value.plan_level!=='advanced';
    const keys=selected(value);
    document.querySelectorAll('[data-plan-feature]').forEach(input=>{
      input.checked=keys.has(input.dataset.planFeature);
      input.disabled=value.outcome==='survival' && input.dataset.planFeature==='survival';
    });
  }
  function wording(value) {
    if(!complex(value))return {};
    return {
      scale:['Outcome or effect measure','Your answer should name the measure, units and direction of interpretation, such as a hazard ratio or a population event rate.','The outcome or effect measure is','Which measure will answer your research question?'],
      expected:['Evidence for planning values','Your answer should identify relevant prior estimates, sources and uncertainty for the chosen measure.','The evidence for planning values is','What prior estimates inform the calculation?'],
      clinical:['Clinically important result','Your answer should explain what result would matter clinically, with supporting evidence or patient input. Design-specific margins have their own prompt below.','The clinically important result is','What result would matter clinically?'],
      planning:['Effect assumed for power','Your answer should specify the effect at which power is evaluated, on the scale used by the calculation, and justify that choice.','The effect assumed for power is','At what effect will power be evaluated?'],
      variation:['Distribution and event assumptions','Your record should specify the distribution, variability or event pattern needed by the selected method, with evidence. Correlations and survival follow-up have additional prompts below.','The distribution and event assumptions are','Which distribution or event assumptions does the method need?'],
      power:['Type I error probability and power','Your record should give the error probability, sidedness and power criterion for the stated hypothesis or family of claims.','The statistical criteria are','What error probability and power criterion will you use?']
    };
  }
  window.AdvancedPlan={features,fields,formats,questions,selected,complex,validate,init,sync,wording};
})();

/* Calculation provenance is separate from the learner's written answers. MIT. */
(() => {
  'use strict';
  let prepared;
  const node = (tag, text) => { const el=document.createElement(tag); el.textContent=text; return el; };
  const records = value => { try {return JSON.parse(value.calculation_records || '[]');} catch (_) {return [];} };
  const selected = value => records(value).filter(r=>r.kind==='calculation').at(-1);
  const compatible = (value, record) => record && record.facts?.outcome===value.outcome &&
    record.facts?.study_type===value.study_type && record.facts?.goal===value.goal;
  const showPrepared = value => prepared && value.plan_basis==='pain' && value.study_type==='comparison' &&
    value.outcome==='binary' && value.goal==='testing' && !selected(value);
  const pct = x => Number((100*x).toFixed(2)) + '%';
  function answers(value, result, formats) {
    if(value.plan_basis!=='pain') return result;
    const attached=selected(value);
    if(!attached) {
      if(showPrepared(value)) result.software='Normal approximation using stats::power.prop.test(), two-sided with strict = TRUE; R '+prepared.r_version+', stats '+prepared.stats_version+'. The prepared calculation record gives the command, inputs, date and source version.';
      return result;
    }
    for(const id of ['software','counts','recruitment','resources','power','planning','variation','sensitivity']) result[id]=formats[id];
    if(!compatible(value,attached)) return result;
    const f=attached.facts;
    result.software=attached.lines.filter(line=>/^(Procedure:|R stats::|M =|Software:)/.test(line)).join('\n') || formats.software;
    if(Number.isFinite(f.analyzable)) result.counts=f.analyzable+' analyzable patients per group, '+2*f.analyzable+' total, from the attached calculation.';
    if(Number.isFinite(f.alpha)&&Number.isFinite(f.power)) result.power='Type I error probability '+pct(f.alpha)+'; target power '+pct(f.power)+', using a two-sided test at the attached target difference.';
    const lossRecord=records(value).filter(r=>r.kind==='recruitment').at(-1);
    if(lossRecord) result.recruitment=lossRecord.lines.join('\n');
    else if(Number.isFinite(f.recruitment)&&Number.isFinite(f.dropout)) result.recruitment='With '+pct(f.dropout)+' expected unavailable primary outcomes, '+f.recruitment+' recruits per group ('+2*f.recruitment+' total). The loss assumption and missing-data analysis need justification.';
    if(Number.isFinite(f.p_treatment)&&Number.isFinite(f.p_control)) {
      result.variation=pct(f.p_control)+' with standard treatment and '+pct(f.p_treatment)+' with novel treatment, from the attached calculation. Evidence should support both values.';
      result.planning=Number((100*Math.abs(f.p_treatment-f.p_control)).toFixed(2))+' percentage points between groups, from the attached calculation; its clinical importance and plausibility need justification.';
    } else if(Number.isFinite(f.target_difference)&&Number.isFinite(f.sd)) {
      result.planning=f.target_difference+' outcome units between groups, from the attached calculation; supporting evidence is needed.';
      result.variation='Common SD '+f.sd+' outcome units, from the attached calculation; supporting evidence is needed.';
    }
    return result;
  }
  function decorate(value, article, lines) {
    const container=document.getElementById('example-calculation');
    const visible=Boolean(showPrepared(value)); container.hidden=!visible;
    if(!visible) return;
    const heading='Prepared chronic pain calculation';
    container.replaceChildren(node('summary','Example calculation and software'));
    const section=document.createElement('section');section.append(node('h4',heading));
    const stamp='Calculated '+prepared.captured.slice(0,10)+'. This record uses the prepared 5% loss assumption. Your written answers remain separate.';
    for(const parent of [container,section]) {
      parent.append(node('p',stamp));
      for(const line of prepared.lines) parent.append(node(line.startsWith('Reproducible R command:')?'pre':'p',line));
    }
    article.append(section);lines.push(heading,stamp,...prepared.lines);
  }
  window.PlanCalculationRecord={answers,decorate};
  fetch('example-calculation.json').then(r=>{if(!r.ok)throw Error('Example calculation unavailable');return r.json();})
    .then(record=>{prepared=record;window.dispatchEvent(new Event('plan-calculation-ready'));})
    .catch(()=>{document.getElementById('calculation-load-status').textContent='The prepared software record could not be loaded. The linked tutorial example contains the calculation.';});
})();

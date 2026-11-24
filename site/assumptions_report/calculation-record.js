/* Calculation provenance is separate from the learner's written answers. MIT. */
(() => {
  'use strict';
  let prepared;
  const node = (tag, text) => { const el=document.createElement(tag); el.textContent=text; return el; };
  const records = value => { try {return JSON.parse(value.calculation_records || '[]');} catch (_) {return [];} };
  const selected = value => records(value).filter(r=>r.kind==='calculation').at(-1);
  const compatible = (value, record) => !AdvancedPlan.complex(value) && record && record.facts?.outcome===value.outcome &&
    record.facts?.study_type===value.study_type && record.facts?.goal===value.goal;
  const showPrepared = value => !AdvancedPlan.complex(value) && prepared && value.plan_basis==='pain' && value.study_type==='comparison' &&
    value.outcome==='binary' && value.goal==='testing' && !selected(value);
  const pct = x => Number((100*x).toFixed(2)) + '%';
  function answers(value, result, formats) {
    if(value.plan_basis!=='pain' || AdvancedPlan.complex(value)) return result;
    const attached=selected(value);
    if(!attached) {
      if(showPrepared(value)) result.software='Normal approximation using stats::power.prop.test(), two-sided with strict = TRUE; R '+prepared.r_version+', stats '+prepared.stats_version+'. Both rejection tails are included.';
      return result;
    }
    for(const id of ['software','counts','recruitment','resources','power','planning','variation','sensitivity']) result[id]=formats[id];
    if(!compatible(value,attached)) return result;
    const f=attached.facts;
    result.software=attached.lines.filter(line=>/^(Procedure:|R stats::|M =|Software:)/.test(line)).map(cleanLine).join('\n') || formats.software;
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
  const cleanLine = line => line.replace(/;?\s*source version:.*$/i,'').replace(/\bYour written answers remain separate\.?/g,'').trim();
  function appendSaved(value, record, article) {
    const section=document.createElement('section');
    section.append(node('h3',record.kind==='recruitment'?'Recruitment calculation':record.kind==='exploration'?'Sensitivity calculation':'Calculation record'));
    const allAnswers=Object.entries(value).filter(([key])=>!['calculation_records','decision_statuses'].includes(key)).map(([,answer])=>answer).join(' ');
    for(const raw of record.lines) {
      const line=cleanLine(raw);
      if(!line || /^(Saved |Captured |Prepared |This record|Your |Selected scenario:)/.test(line)) continue;
      if(allAnswers.includes(line)) continue;
      // Written entries are the report's current statements. Keep additional
      // result details when the corresponding entry has not been completed.
      const written = /^(Procedure:|R stats::|M =|Software:|Reproducible R command:)/.test(line)?value.software:
        /^(Inputs:|Population:|Planning:)/.test(line)?value.variation:
        /^(Analyzable sample:|Sample size:)/.test(line)?value.counts:
        /^(Expected unavailable|Recruitment:|Expected dropout:)/.test(line)?value.recruitment:'';
      if(written?.trim()) continue;
      section.append(node('p',line));
    }
    if(section.children.length>1) article.append(section);
  }
  function decorate(value) {
    const container=document.getElementById('example-calculation');
    const visible=Boolean(showPrepared(value)); container.hidden=!visible;
    if(!visible) return;
    container.replaceChildren(node('summary','Example calculation and software'));
    for(const raw of prepared.lines) {
      const line=cleanLine(raw);
      if(line) container.append(node(line.startsWith('Reproducible R command:')?'pre':'p',line));
    }
  }
  window.PlanCalculationRecord={answers,decorate,appendSaved};
  fetch('example-calculation.json').then(r=>{if(!r.ok)throw Error('Example calculation unavailable');return r.json();})
    .then(record=>{prepared=record;window.dispatchEvent(new Event('plan-calculation-ready'));})
    .catch(()=>{document.getElementById('calculation-load-status').textContent='The prepared software record could not be loaded. The linked tutorial example contains the calculation.';});
})();

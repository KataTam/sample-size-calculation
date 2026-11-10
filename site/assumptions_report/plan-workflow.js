/* One developing assignment, explicit snapshots, and review states. MIT. */
(() => {
  'use strict';
  const metaNames = ['plan_title', 'plan_basis', 'decision_statuses', 'calculation_records'];
  const stages = {
    question: {title:'Question and design', sections:[0], fields:['question','population','intervention','comparator','outcome_detail','design'], text:'Your first contribution is the research question and study design. Initial assumptions can remain provisional while you look for evidence.'},
    power: {title:'Statistical criteria', sections:[2,3], fields:['power','conclusion'], text:'Your plan should explain the chosen error probability and power, and what the study could establish under its assumptions.'},
    calculation: {title:'Calculation', sections:[1,2], fields:['expected','clinical','planning','variation','analysis','software','counts'], text:'Your calculation record should contain the inputs, method, analyzable sample size, and your justification. A calculator can add a selected result to this report.'},
    recruitment: {title:'Recruitment and conclusion', sections:[3], fields:['recruitment','sensitivity','resources','conclusion'], text:'Your final contribution is the recruitment target and its justification. You can then review the concise sample size calculation report and its supporting study plan, generated from your existing answers.'},
    review: {title:'Review your complete study plan', sections:[], fields:[], text:'The review below identifies unresolved decisions and mismatches between saved calculations. Your reasoning and evidence still need your own review.'}
  };
  const read = (text, fallback) => { try {return JSON.parse(text || '')} catch (_) {return fallback} };
  const element = (tag, text, cls) => { const node=document.createElement(tag); if(text!==undefined)node.textContent=text;if(cls)node.className=cls;return node; };
  function validateRecords(text) {
    let records;
    try {records=JSON.parse(text||'[]');} catch (_) {throw Error('Invalid saved calculation records.');}
    if(!Array.isArray(records)||records.length>30)throw Error('Invalid saved calculation records.');
    records.forEach(r=>{
      if(!r||typeof r!=='object'||!['calculation','recruitment','exploration'].includes(r.kind)||typeof r.title!=='string'||r.title.length>300||!Array.isArray(r.lines)||r.lines.length>100||r.lines.some(x=>typeof x!=='string'||x.length>12000))throw Error('Invalid calculation record.');
      if(r.facts && (typeof r.facts!=='object'||Array.isArray(r.facts)||Object.values(r.facts).some(x=>!['string','number','boolean'].includes(typeof x)||(typeof x==='number'&&!Number.isFinite(x)))))throw Error('Invalid calculation values.');
      if(r.captured && (typeof r.captured!=='string'||!Number.isFinite(Date.parse(r.captured))))throw Error('Invalid calculation date.');
    });return records;
  }
  function validateMetadata(value) {
    validateRecords(value.calculation_records||'[]');
    let statuses;
    try {statuses=JSON.parse(value.decision_statuses||'{}');} catch (_) {throw Error('Invalid decision status.');}
    if(!statuses||Array.isArray(statuses)||typeof statuses!=='object'||Object.values(statuses).some(s=>!['provisional','evidence','reviewed','changed'].includes(s)))throw Error('Invalid review status.');
  }
  let form, fields, groups, statusNodes={}, currentRecords=[], review, pending;
  function changed(){form.dispatchEvent(new Event('input',{bubbles:true}));}
  function setStatuses(values){form.elements.decision_statuses.value=JSON.stringify(values);}
  function init(f, definitions, sections) {
    form=f;fields=definitions;groups=sections;
    for(const name of metaNames.filter(n=>!form.elements[n])){const input=element('input');input.type='hidden';input.name=name;form.append(input);}
    const setup=document.getElementById('plan-start');
    setup.querySelectorAll('input,select').forEach(input=>{input.setAttribute('form',form.id);input.addEventListener('input',()=>form.dispatchEvent(new CustomEvent('plan-identity-input',{detail:{name:input.name,value:input.value}})));});
    groups.forEach(([title, definitions],index)=>{
      const box=element('div',undefined,'section-review'),row=element('label');
      const checkbox=element('input');checkbox.type='checkbox';checkbox.id='section-'+index+'-reviewed';
      checkbox.setAttribute('aria-label',title+': ready for review');
      row.append(checkbox,document.createTextNode(' Ready for review'));
      const note=element('span',undefined,'section-review-note');note.id=checkbox.id+'-note';checkbox.setAttribute('aria-describedby',note.id);
      checkbox.addEventListener('input',event=>event.stopPropagation());
      checkbox.addEventListener('change',()=>{
        const statuses=read(form.elements.decision_statuses.value,{});
        statuses['section-'+index]=checkbox.checked?'reviewed':'provisional';
        for(const [id] of definitions)delete statuses[id];
        setStatuses(statuses);changed();
      });
      box.append(row,note);document.getElementById('plan-section-'+index).append(box);
      statusNodes[index]={checkbox,note};
    });
    review=document.getElementById('plan-review');
    const nav=document.getElementById('plan-stages');
    for(const [id,s] of Object.entries(stages)){
      const a=element('a',({question:'Question',power:'Statistical criteria',calculation:'Calculation',recruitment:'Recruitment',review:'Review'})[id]);a.href='?stage='+id;a.addEventListener('click',e=>{e.preventDefault();showStage(id);});nav.append(a);
    }
    document.getElementById('study_type').addEventListener('change',()=>{
      if(form.elements.study_type.value==='other'){document.getElementById('plan-section-0').open=true;document.getElementById('design').focus();}
    });
    document.getElementById('plan-basis').addEventListener('change',()=>{
      document.getElementById('example').hidden=document.getElementById('plan-basis').value!=='pain';
    });
  }
  function showStage(id) {
    const s=stages[id]||stages.question;
    const intro=document.getElementById('plan-stage-guidance');intro.replaceChildren(element('h2',s.title),element('p',s.text));
    document.querySelectorAll('#plan-stages a').forEach(a=>a.setAttribute('aria-current',a.search==='?stage='+id?'step':'false'));
    for(let i=0;i<4;i++)document.getElementById('plan-section-'+i).open=s.sections.includes(i);
    const url=new URL(location.href);url.searchParams.set('stage',id);history.replaceState(null,'',url);
    review.open=id==='review';
    intro.scrollIntoView({block:'nearest'});
  }
  function decorate(value, article, lines, active) {
    const statuses=read(value.decision_statuses,{}), records=validateRecords(value.calculation_records||'[]');currentRecords=records;
    const issues=[];let readySections=0;
    groups.forEach(([title,definitions],index)=>{
      const relevant=definitions.filter(field=>active(field,value));
      const missing=relevant.filter(([id])=>!value[id].trim());
      const key='section-'+index;
      // Earlier work files used one status per field. Preserve their review meaning.
      const savedStatus=statuses[key]||(!missing.length&&relevant.every(([id])=>statuses[id]==='reviewed')?'reviewed':'provisional');
      const ready=!missing.length&&savedStatus==='reviewed';
      const node=statusNodes[index];node.checkbox.checked=ready;node.checkbox.disabled=!!missing.length;
      node.note.textContent=missing.length?'Available after the applicable questions are answered.':savedStatus==='changed'?'Updated since review.':ready?'':'Your evidence and interpretation should be checked before marking this section.';
      if(missing.length)issues.push(title+' — still to complete: '+missing.map(([id,label])=>label).join('; ')+'.');
      else if(!ready)issues.push(title+' — '+(savedStatus==='changed'?'updated since review.':'ready for your review.'));
      const evidence=relevant.filter(([id])=>statuses[id]==='evidence');
      if(evidence.length)issues.push(title+' — earlier notes marked evidence needed: '+evidence.map(([,label])=>label).join('; ')+'.');
      if(ready)readySections++;
    });
    const calc=[...records].reverse().find(r=>r.kind==='calculation'), recruitment=[...records].reverse().find(r=>r.kind==='recruitment');
    if(!calc)issues.push('No calculator result has been attached. An external calculation can be documented in the calculation and software answers.');
    if(calc?.facts?.study_type==='comparison' && calc.facts.analyzable && recruitment?.facts?.starting_n && calc.facts.analyzable!==recruitment.facts.starting_n)issues.push('The recruitment calculation starts with '+recruitment.facts.starting_n+' per group, while the selected calculation requires '+calc.facts.analyzable+'. The recruitment calculation needs review.');
    if(calc?.facts?.outcome && calc.facts.outcome!==value.outcome)issues.push('The attached calculation uses a different outcome type from the current study settings.');
    if(calc?.facts?.study_type && calc.facts.study_type!==value.study_type)issues.push('The attached calculation uses a different study structure from the current study settings.');
    if(calc?.facts?.goal && calc.facts.goal!==value.goal && value.goal!=='both')issues.push('The attached calculation uses a different planning goal from the current study settings.');
    const list=review.querySelector('ul');list.replaceChildren(...issues.map(text=>element('li',text)));
    if(!issues.length)list.append(element('li','All applicable answers are ready for your final review. Check the evidence, written values, and interpretation before submitting.'));
    review.querySelector('.review-note').textContent='Checks compare saved structured results. Numerical values in your written answers need your own review.';
    const studyTitle=value.plan_title.trim()||'My study plan';
    document.querySelector('#plan-identity > summary').textContent=value.plan_title.trim()?'Study title and starting point: '+value.plan_title.trim():'Study title and starting point';
    if(pending&&!document.getElementById('transfer-preview').hidden)document.querySelector('.transfer-title').textContent='Add '+pending.title+' to '+studyTitle+'?';
    lines.push('Section review',...issues);
    const summary=element('p',`${readySections} of ${groups.length} sections marked ready for review.`);
    article.append(summary);lines.push(summary.textContent);
    const recordList=document.getElementById('saved-calculations');recordList.parentElement.hidden=records.length===0;recordList.replaceChildren();
    records.forEach((record,index)=>{
      const section=element('section');section.append(element('h4',record.title));
      const stamp='Saved '+new Date(record.captured||Date.now()).toLocaleString('en-US');
      section.append(element('p',stamp),...record.lines.map(line=>element('p',line)));
      const remove=element('button','Remove this saved result');remove.type='button';remove.addEventListener('click',()=>{const next=[...currentRecords];next.splice(index,1);form.elements.calculation_records.value=JSON.stringify(next);changed();});
      const display=element('details');display.append(element('summary',record.title),element('p',stamp),...record.lines.map(line=>element('p',line)),remove);recordList.append(display);
      article.append(section);lines.push('Saved calculation: '+record.title,stamp,...record.lines);
    });
    document.getElementById('example').hidden=value.plan_basis!=='pain';
  }
  function loadPending() {
    const params=new URLSearchParams(location.search),id=params.get('transfer');
    showStage(params.get('stage')||'question');
    // Keep title and starting point available when returning to a saved plan.
    if(!id||!/^[-a-zA-Z0-9]+$/.test(id))return;
    try {
      const raw=localStorage.getItem('sample-size-pending-'+id);if(!raw)throw Error('This transfer is no longer available. You can return to the app and add its current calculation.');
      pending=validateRecords('['+raw+']')[0];
      const panel=document.getElementById('transfer-preview');panel.hidden=false;
      panel.querySelector('.transfer-title').textContent='Add '+pending.title+' to '+(form.elements.plan_title.value||'your study plan')+'?';
      panel.querySelector('.transfer-lines').replaceChildren(...pending.lines.map(line=>element('p',line)));
      panel.querySelector('.transfer-scope').textContent='This saves the displayed inputs and result in your report. Your written answers remain in place. Check that this example and calculation belong to your study.';
      document.getElementById('accept-transfer').onclick=()=>{
        const records=validateRecords(form.elements.calculation_records.value||'[]');
        if(document.getElementById('replace-calculation').checked)for(let i=records.length-1;i>=0;i--)if(records[i].kind===pending.kind)records.splice(i,1);
        if(records.length>=30){document.getElementById('status').textContent='Remove an older saved result before adding another.';return;}
        records.push(pending);form.elements.calculation_records.value=JSON.stringify(records);
        invalidate(pending.kind==='recruitment'?[3]:[2,3]);
        changed();panel.hidden=true;localStorage.removeItem('sample-size-pending-'+id);
        document.getElementById('status').textContent='Calculation added. The affected sections need review against your written answers.';
      };
      document.getElementById('cancel-transfer').onclick=()=>{panel.hidden=true;localStorage.removeItem('sample-size-pending-'+id);};
    }catch(error){document.getElementById('status').textContent=error.message;}
  }
  function invalidate(indices){
    const statuses=read(form.elements.decision_statuses.value,{});
    for(const index of new Set(indices)){
      const key='section-'+index;
      if(statuses[key]==='reviewed'||groups[index][1].some(([id])=>statuses[id]==='reviewed'))statuses[key]='changed';
      else if(!statuses[key])statuses[key]='provisional';
      // Legacy evidence flags remain visible until this section is reviewed.
      for(const [id] of groups[index][1])if(statuses[id]==='reviewed')delete statuses[id];
    }
    setStatuses(statuses);
  }
  function onEdit(name){
    if(['study_type','outcome','goal','plan_basis'].includes(name)){invalidate([0,1,2,3]);return;}
    const index=groups.findIndex(([,definitions])=>definitions.some(([id])=>id===name));
    if(index<0)return;
    invalidate([index,...(['question','design','outcome_detail','expected','clinical','planning','variation','analysis','power','precision','counts','sensitivity'].includes(name)?[2,3]:[])]);
  }
  window.PlanWorkflow={onEdit,metaNames,validateMetadata,init,decorate,loadPending,showStage};
})();

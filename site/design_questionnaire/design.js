/* Original software, MIT license. */
(()=>{
'use strict';
const {fields,relevant,recommend,links}=DesignQuestionnaire;
const form=document.getElementById('design-form'),result=document.getElementById('result'),status=document.getElementById('status');
let shown=false;
function answers(){return Object.fromEntries(new FormData(form));}
const help={
 aim:'The main purpose determines what you need to estimate or compare. A treatment question often uses PICO: population, intervention, comparator and outcome.',
 data:'Existing records may support several designs. Relevant variables, timing, selection and missing data should be checked for your question.',
 structure:'Independent observations come from separate participants or units. Paired measurements come from the same person or matched units. Clusters contain observations that may be correlated, such as patients within a clinic.',
 outcome:'The primary outcome is the main measurement used to answer your question. Its definition and assessment time should be specified before choosing the analysis and sample-size method.',
 allocation:'This concerns who assigns treatment. Individual randomization assigns participants; cluster randomization assigns groups such as clinics. In an observational study, treatment is determined outside the study.',
 comparison:'Parallel groups receive different treatments. In a crossover study, the same participants receive treatments in successive periods. A before–after comparison measures change around an intervention.',
 claim:'Superiority tests a difference between treatments. Noninferiority and equivalence use prespecified, justified margins. The intended claim determines the hypothesis and calculation.',
 crossover:'Carryover occurs when an earlier treatment affects a later period. Suitability depends on the condition, reversibility of effects and whether carryover can be controlled.',
 sampling:'Selection and timing distinguish these designs. A cohort starts with an eligible population, case-control sampling starts with outcome status, and a cross-sectional study assesses a defined time.',
 reference:'The reference standard provides the comparison used to establish whether the target condition is present. Its suitability and application affect interpretation of diagnostic accuracy.',
 prediction:'Development fits or updates a model. External evaluation examines an existing model in new patients. Comparing models or feature sets requires a defined performance measure.'
};
const groups=[['Purpose and data',['aim','data']],['Observations and outcome',['structure','outcome']],['Design details',['allocation','comparison','claim','crossover','sampling','reference','prediction']]];
for(const [number,[title,ids]] of groups.entries()){
 const group=document.createElement('section');group.className='design-group';group.dataset.fields=ids.join(' ');
 const heading=document.createElement('h3');heading.textContent=`${number+1}. ${title}`;heading.id='design-group-'+number;group.setAttribute('aria-labelledby',heading.id);group.append(heading);
 for(const id of ids){
  const [,title,options]=fields.find(f=>f[0]===id);
  const wrapper=document.createElement('div');wrapper.id='field-'+id;wrapper.className='design-field';
  const label=document.createElement('label');label.htmlFor=id;label.textContent=title;
  const select=document.createElement('select');select.id=id;select.name=id;select.required=true;
  const placeholder=new Option('Choose an answer','',true,true);placeholder.disabled=true;select.add(placeholder);
  for(const [value,text] of options)select.add(new Option(text,value));
  const guidance=document.createElement('div');guidance.className='input-guidance-source';guidance.dataset.for=id;guidance.textContent=help[id];
  const full=document.createElement('p');full.id=id+'-selection';full.className='selected-answer';full.hidden=true;select.setAttribute('aria-describedby',full.id);
  wrapper.append(label,select,full,guidance);group.append(wrapper);
 }
 document.getElementById('questions').append(group);
}
const canvas=document.createElement('canvas'),measure=canvas.getContext('2d');
function selectedText(){
 for(const select of form.querySelectorAll('select')){
  const full=document.getElementById(select.id+'-selection'),text=select.selectedOptions[0]?.textContent||'';
  measure.font=getComputedStyle(select).font;
  const clipped=select.value && select.checkVisibility() && measure.measureText(text).width>select.clientWidth-50;
  full.hidden=!clipped;full.textContent=clipped?'Selected answer: '+text:'';
 }
}
new ResizeObserver(selectedText).observe(form);
function update(){
 const a=answers();
 for(const f of fields){const active=relevant(f,a);document.getElementById('field-'+f[0]).hidden=!active;document.getElementById(f[0]).disabled=!active;}
 for(const group of document.querySelectorAll('.design-group'))group.hidden=!group.dataset.fields.split(' ').some(id=>!document.getElementById(id).disabled);
 const active=fields.filter(f=>relevant(f,a)),answered=active.filter(f=>a[f[0]]).length;
 document.getElementById('question-progress').textContent=`${answered} of ${active.length} questions answered`;
 document.getElementById('question-progress-bar').max=active.length;document.getElementById('question-progress-bar').value=answered;
 selectedText();
 if(shown){result.replaceChildren();const p=document.createElement('p');p.textContent='Your answers changed. “Show design suggestions” will update the result.';result.append(p);shown=false;}
}
function list(title,items){if(!items.length)return;const h=document.createElement('h3');h.textContent=title;const ul=document.createElement('ul');for(const text of items){const li=document.createElement('li');li.textContent=text;ul.append(li);}result.append(h,ul);}
function render(){
 document.getElementById('result-panel').hidden=false;document.body.classList.add('has-results');
 const a=answers(),r=recommend(a);result.replaceChildren();
 const title=document.createElement('h3');title.id='suggested-design';title.textContent=r.title;result.append(title);
 list('Why this fits your answers',r.why);list('Implications for sample size',r.planning);list('Decisions still needed',r.decisions);
 const heading=document.createElement('h3');heading.textContent='Related apps and guidance';const ul=document.createElement('ul');
 for(const key of r.resources){const li=document.createElement('li'),a=document.createElement('a');a.textContent=links[key][0];a.href=links[key][1];a.target='_blank';a.rel='noopener';li.append(a);ul.append(li);}result.append(heading,ul);
 const details=document.createElement('details'),summary=document.createElement('summary');summary.textContent='Your answers';details.append(summary);const dl=document.createElement('dl');
 for(const [id,title,options] of fields){if(!relevant(fields.find(f=>f[0]===id),a)||!a[id])continue;const dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=title;dd.textContent=options.find(o=>o[0]===a[id])?.[1]||'';dl.append(dt,dd);}details.append(dl);result.append(details);
 shown=true;status.textContent='Design suggestion updated.';document.getElementById('result-heading').focus();
}
function reset(){form.reset();shown=false;update();document.getElementById('result-panel').hidden=true;document.body.classList.remove('has-results');result.innerHTML='<p>The suggestion and its reasoning will appear here after you complete the questions.</p>';status.textContent='Answers cleared.';document.getElementById('aim').focus();}
form.addEventListener('change',update);form.addEventListener('submit',e=>{e.preventDefault();render();});document.getElementById('start-again').addEventListener('click',reset);
window.addEventListener('message',e=>{if(e.origin!==location.origin||e.source!==parent)return;if(e.data?.type==='sample-size:activity'&&e.data.activity==='design_questionnaire'&&e.data.reset)reset();});
update();if(parent!==window)parent.postMessage({type:'sample-size:ready',app:'design_questionnaire'},location.origin);
})();

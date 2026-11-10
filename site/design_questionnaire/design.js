/* Original software, MIT license. */
(()=>{
'use strict';
if (new URL(location.href).searchParams.get('guided') === '1') document.body.classList.add('guided');
const {fields,relevant,recommend,links}=DesignQuestionnaire;
const form=document.getElementById('design-form'),result=document.getElementById('result'),status=document.getElementById('status');
let shown=false;
function answers(){return Object.fromEntries(new FormData(form));}
const help={
 aim:'Your primary question should determine this choice. If the study has several aims, you can run the questionnaire separately for each.',
 data:'For existing records, you should check whether the required variables, assessment times, and eligible participants are available, including the extent of missing data.',
 structure:'Repeated measurements on one person are paired. Patients within clinics may be clustered. Counting all measurements as independent can overstate the information available.',
 outcome:'Any admission during follow-up is binary; the number of admissions is a count; time to first admission is a time-to-event outcome. The definition should match your primary question.',
 allocation:'Treatment chosen during routine care is observed. Randomization can assign individual patients or whole groups, such as clinics, depending on how the intervention is delivered.',
 comparison:'Receiving both treatments in successive periods is a crossover. Measurements before and after a single intervention form a before–after comparison; treatment order and timing matter.',
 claim:'Noninferiority needs a justified limit on acceptable disadvantage; equivalence needs limits in both directions. These margins and the intended claim should be specified before analysis.',
 crossover:'An earlier treatment may affect later measurements. A sufficiently stable condition, reversible effects, and control of carryover are needed; uncertainty should remain marked for assessment.',
 sampling:'The starting point matters: an eligible population, people selected by outcome status, or a snapshot at one time. Existing records can support a cohort when the time sequence is clear.',
 reference:'A reference standard is the best available method for establishing whether the target condition is present. An error-free reference is sometimes called a gold standard. You should check its accuracy and whether participants can receive it.',
 prediction:'Fitting or updating coefficients counts as development. Testing an unchanged model in new patients is external evaluation. Comparing feature sets needs a shared performance measure and evaluation data.'
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
const storageKey='sample-size-design-questionnaire-v1';
function persist(){try{localStorage.setItem(storageKey,JSON.stringify({answers:answers(),shown}));}catch(_) {}}
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
 const definition=document.createElement('p');definition.className='design-definition';definition.textContent=r.why[0]||r.decisions[0]||'';result.append(definition);list('Why this fits your answers',r.why.slice(1));list('Implications for sample size',r.planning);list('Decisions still needed',r.decisions);
 const heading=document.createElement('h3');heading.textContent='Related apps and guidance';const ul=document.createElement('ul');
 for(const key of r.resources){const li=document.createElement('li'),a=document.createElement('a');a.textContent=links[key][0];a.href=links[key][1];a.target='_blank';a.rel='noopener';li.append(a);ul.append(li);}result.append(heading,ul);
 const details=document.createElement('details'),summary=document.createElement('summary');summary.textContent='Your answers';details.append(summary);const dl=document.createElement('dl');
 for(const [id,title,options] of fields){if(!relevant(fields.find(f=>f[0]===id),a)||!a[id])continue;const dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=title;dd.textContent=options.find(o=>o[0]===a[id])?.[1]||'';dl.append(dt,dd);}details.append(dl);result.append(details);
 shown=true;persist();status.textContent='Design suggestion updated.';document.getElementById('result-heading').focus();
}
function reset(){try{localStorage.removeItem(storageKey);}catch(_){}form.reset();shown=false;update();document.getElementById('result-panel').hidden=true;document.body.classList.remove('has-results');result.innerHTML='<p>The suggestion and its reasoning will appear here after you complete the questions.</p>';status.textContent='Answers cleared.';document.getElementById('aim').focus();}
form.addEventListener('change',()=>{update();persist();});form.addEventListener('submit',e=>{e.preventDefault();render();});document.getElementById('start-again').addEventListener('click',reset);
window.addEventListener('message',e=>{if(e.origin!==location.origin||e.source!==parent)return;if(e.data?.type==='sample-size:activity'&&e.data.activity==='design_questionnaire'&&e.data.reset)reset();});
try{const saved=JSON.parse(localStorage.getItem(storageKey)||'null');if(saved){for(const [id,value] of Object.entries(saved.answers)){if(fields.some(f=>f[0]===id&&f[2].some(o=>o[0]===value)))document.getElementById(id).value=value;}update();if(saved.shown)render();}else update();}catch(_){update();}if(parent!==window)parent.postMessage({type:'sample-size:ready',app:'design_questionnaire'},location.origin);
})();

/* Original software, MIT license. */
(()=>{
'use strict';
const {fields,relevant,recommend,links}=DesignQuestionnaire;
const form=document.getElementById('design-form'),result=document.getElementById('result'),status=document.getElementById('status');
let shown=false;
function answers(){return Object.fromEntries(new FormData(form));}
for(const [id,title,options] of fields){
 const label=document.createElement('label');label.htmlFor=id;label.id='field-'+id;label.append(title);
 const select=document.createElement('select');select.id=id;select.name=id;select.required=true;
 const placeholder=new Option('Choose an answer','',true,true);placeholder.disabled=true;placeholder.selected=true;select.add(placeholder);
 for(const [value,text] of options)select.add(new Option(text,value));
 label.append(select);document.getElementById('questions').append(label);
}
function update(){
 const a=answers();
 for(const f of fields){const active=relevant(f,a);document.getElementById('field-'+f[0]).hidden=!active;document.getElementById(f[0]).disabled=!active;}
 if(shown){result.replaceChildren();const p=document.createElement('p');p.textContent='Your answers changed. “Show design suggestions” will update the result.';result.append(p);shown=false;}
}
function list(title,items){if(!items.length)return;const h=document.createElement('h3');h.textContent=title;const ul=document.createElement('ul');for(const text of items){const li=document.createElement('li');li.textContent=text;ul.append(li);}result.append(h,ul);}
function render(){
 const a=answers(),r=recommend(a);result.replaceChildren();
 const title=document.createElement('h3');title.id='suggested-design';title.textContent=r.title;result.append(title);
 list('Why this fits your answers',r.why);list('Decisions still needed',r.decisions);list('Implications for sample size',r.planning);
 const heading=document.createElement('h3');heading.textContent='Related apps and guidance';const ul=document.createElement('ul');
 for(const key of r.resources){const li=document.createElement('li'),a=document.createElement('a');a.textContent=links[key][0];a.href=links[key][1];a.target='_blank';a.rel='noopener';li.append(a);ul.append(li);}result.append(heading,ul);
 const details=document.createElement('details'),summary=document.createElement('summary');summary.textContent='Your answers';details.append(summary);const dl=document.createElement('dl');
 for(const [id,title,options] of fields){if(!relevant(fields.find(f=>f[0]===id),a)||!a[id])continue;const dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=title;dd.textContent=options.find(o=>o[0]===a[id])?.[1]||'';dl.append(dt,dd);}details.append(dl);result.append(details);
 shown=true;status.textContent='Design suggestion updated.';document.getElementById('result-heading').focus();
}
function reset(){form.reset();shown=false;update();result.innerHTML='<p>The suggestion and its reasoning will appear here after you complete the questions.</p>';status.textContent='Answers cleared.';}
form.addEventListener('change',update);form.addEventListener('submit',e=>{e.preventDefault();render();});document.getElementById('start-again').addEventListener('click',reset);
window.addEventListener('message',e=>{if(e.origin!==location.origin||e.source!==parent)return;if(e.data?.type==='sample-size:activity'&&e.data.activity==='design_questionnaire'&&e.data.reset)reset();});
update();if(parent!==window)parent.postMessage({type:'sample-size:ready',app:'design_questionnaire'},location.origin);
})();

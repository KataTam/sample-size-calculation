/* Original software: MIT. The tables remain readable when JavaScript is unavailable. */
(()=>{
 const controls=document.getElementById('flashcard-controls');if(!controls)return;
 const route=document.getElementById('flashcard-route'),search=document.getElementById('flashcard-search');
 const sections=[...document.querySelectorAll('.flashcard-level')];
 const normalize=text=>text.normalize('NFKD').replace(/[\u0300-\u036f]/g,'').toLocaleLowerCase();
 const rows=sections.flatMap(section=>[...section.querySelectorAll('tbody tr')].map(row=>({row,section,text:normalize(row.textContent)})));
 const hideAnswers=document.getElementById('hide-answers');
 const answers=rows.map(({row})=>{
  const cell=row.cells[1], content=document.createElement('div'), reveal=document.createElement('button');
  content.className='card-answer';content.id='answer-'+row.dataset.card;content.append(...cell.childNodes);
  reveal.type='button';reveal.className='secondary reveal-answer';reveal.textContent='Show answer';reveal.hidden=true;
  reveal.setAttribute('aria-controls',content.id);reveal.setAttribute('aria-expanded','false');
  reveal.addEventListener('click',()=>{content.hidden=!content.hidden;reveal.textContent=content.hidden?'Show answer':'Hide answer';reveal.setAttribute('aria-expanded',String(!content.hidden));});
  cell.append(reveal,content);return {content,reveal};
 });
 hideAnswers.addEventListener('click',()=>{
  const hidden=hideAnswers.getAttribute('aria-pressed')!=='true';hideAnswers.setAttribute('aria-pressed',String(hidden));
  hideAnswers.textContent=hidden?'Show all answers':'Hide answers';
  answers.forEach(({content,reveal})=>{content.hidden=hidden;reveal.hidden=!hidden;reveal.textContent='Show answer';reveal.setAttribute('aria-expanded',String(!hidden));});
 });
 function update(){
  const terms=normalize(search.value.trim()).split(/\s+/).filter(Boolean);let count=0;
  for(const item of rows){const shown=(route.value==='all'||item.section.dataset.level===route.value)&&terms.every(term=>item.text.includes(term));item.row.hidden=!shown;count+=Number(shown)}
  for(const section of sections){const all=rows.filter(item=>item.section===section),visible=all.filter(item=>!item.row.hidden).length;section.hidden=!visible;section.querySelector('.level-count').textContent=`(${visible} ${visible===1?'card':'cards'})`}
  document.getElementById('flashcard-count').textContent=`${count} of ${rows.length} cards shown`;
  document.getElementById('flashcard-empty').hidden=count!==0;
  document.getElementById('clear-search').disabled=!search.value;
 }
 controls.hidden=false;route.addEventListener('change',update);search.addEventListener('input',update);
 document.getElementById('clear-search').addEventListener('click',()=>{search.value='';update();search.focus()});
 update();window.InputGuidance?.init();
})();

/* Original software: MIT. The tables remain readable when JavaScript is unavailable. */
(()=>{
 const controls=document.getElementById('flashcard-controls');if(!controls)return;
 const route=document.getElementById('flashcard-route'),search=document.getElementById('flashcard-search');
 const sections=[...document.querySelectorAll('.flashcard-level')];
 const normalize=text=>text.normalize('NFKD').replace(/[\u0300-\u036f]/g,'').toLocaleLowerCase();
 const rows=sections.flatMap(section=>[...section.querySelectorAll('tbody tr')].map(row=>({row,section,text:normalize(row.textContent)})));
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

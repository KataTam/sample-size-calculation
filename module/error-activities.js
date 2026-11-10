/* Selectable error reviews. Original software: MIT. Answers stay local. */
(() => {
 'use strict';
 let active=null;
 function enhance(root) {
  if(root.dataset.spotReady) return;
  root.dataset.spotReady='true';
  const choices=[...root.querySelectorAll('.spot-choice')];
  const key=`sample-size:spot-errors:${root.dataset.version}:${root.id}`;
  let checked=new Set(),current=null,closeTimer;
  try { const saved=JSON.parse(localStorage.getItem(key)); if(Array.isArray(saved)) checked=new Set(saved.map(String)); } catch(_){}
  const popup=document.createElement('div');
  popup.className='spot-popover'; popup.id=`${root.id}-popover`; popup.hidden=true;
  popup.setAttribute('role','dialog'); popup.setAttribute('aria-label','Passage explanation'); popup.tabIndex=-1;
  const closeButton=document.createElement('button');
  closeButton.type='button'; closeButton.className='spot-close'; closeButton.textContent='Close';
  const content=document.createElement('div');
  popup.append(closeButton,content);root.append(popup);
  const save=()=>{try{localStorage.setItem(key,JSON.stringify([...checked]));}catch(_){}};
  function update() {
   let found=0,total=0;
   choices.forEach(choice=>{
    const selected=checked.has(choice.dataset.choice),error=choice.dataset.error==='true';
    choice.classList.toggle('spot-found',selected&&error);
    choice.classList.toggle('spot-checked',selected&&!error);
    if(error){total++;if(selected)found++;}
   });
   root.querySelector('.spot-status').textContent=`${found} of ${total} problem areas found.`;
  }
  function close(restoreFocus=false) {
   clearTimeout(closeTimer);
   const previous=current;
   popup.hidden=true;current=null;
   if(previous) previous.setAttribute('aria-expanded','false');
   if(active?.popup===popup) active=null;
   if(restoreFocus&&previous) previous.focus({preventScroll:true});
  }
  function position(choice) {
   const rect=choice.getBoundingClientRect(),width=Math.min(460,window.innerWidth-24);
   popup.style.width=`${width}px`;
   popup.style.left=`${Math.max(12,Math.min(rect.left,window.innerWidth-width-12))}px`;
   popup.style.top='12px';
   const height=popup.getBoundingClientRect().height;
   const below=rect.bottom+8,above=rect.top-height-8;
   popup.style.top=`${below+height<=innerHeight-12?below:Math.max(12,Math.min(above,innerHeight-height-12))}px`;
  }
  function open(choice,mark=false,focus=false) {
   clearTimeout(closeTimer);
   if(active&&active.popup!==popup) active.close();
   if(current&&current!==choice) current.setAttribute('aria-expanded','false');
   if(mark){checked.add(choice.dataset.choice);save();update();}
   const explanation=root.querySelector(`.spot-answer-key li[data-choice="${choice.dataset.choice}"] .spot-explanation`);
   content.replaceChildren(explanation.cloneNode(true));
   current=choice;popup.hidden=false;choice.setAttribute('aria-expanded','true');
   active={popup,choice,close,position:()=>position(choice)};position(choice);
   if(focus) popup.focus({preventScroll:true});
  }
  const leave=()=>{clearTimeout(closeTimer);closeTimer=setTimeout(()=>{
   if(!popup.matches(':hover')&&!current?.matches(':hover')&&!popup.contains(document.activeElement)) close();
  },220);};
  choices.forEach(choice=>{
   choice.setAttribute('role','button');choice.tabIndex=0;
   choice.setAttribute('aria-expanded','false');choice.setAttribute('aria-controls',popup.id);
   choice.setAttribute('aria-haspopup','dialog');
   choice.addEventListener('click',()=>open(choice,true,true));
   choice.addEventListener('keydown',event=>{
    if(event.key==='Enter'||event.key===' '){event.preventDefault();open(choice,true,true);}
   });
   choice.addEventListener('mouseenter',()=>{if(checked.has(choice.dataset.choice))open(choice);});
   choice.addEventListener('mouseleave',leave);
  });
  popup.addEventListener('mouseenter',()=>clearTimeout(closeTimer));
  popup.addEventListener('mouseleave',leave);
  popup.addEventListener('focusout',()=>setTimeout(()=>{if(!popup.contains(document.activeElement)&&!current?.contains(document.activeElement))close();},0));
  closeButton.addEventListener('click',()=>close(true));
  root.querySelector('.spot-reset').addEventListener('click',()=>{
   close();checked.clear();save();update();root.querySelector('.spot-answer-key').open=false;
  });
  update();
 }
 const init=()=>document.querySelectorAll('.spot-activity').forEach(enhance);
 document.addEventListener('DOMContentLoaded',init);
 if(document.readyState!=='loading')init();
 document.addEventListener('keydown',event=>{if(event.key==='Escape'&&active){event.preventDefault();active.close(true);}});
 document.addEventListener('pointerdown',event=>{if(active&&!active.popup.contains(event.target)&&!active.choice.contains(event.target))active.close();});
 window.addEventListener('resize',()=>active?.close());
 document.addEventListener('scroll',event=>{
  if(!active||active.popup.contains(event.target))return;
  const rect=active.choice.getBoundingClientRect();
  // A delayed scroll event from bringing the passage into view should retain
  // its explanation. Close only when the selected passage leaves the viewport.
  if(rect.bottom<0||rect.top>innerHeight)active.close();else active.position();
 },true);
 window.addEventListener('beforeprint',()=>{
  active?.close();document.querySelectorAll('.spot-answer-key').forEach(key=>{key.dataset.spotWasOpen=String(key.open);key.open=true;});
 });
 window.addEventListener('afterprint',()=>document.querySelectorAll('.spot-answer-key').forEach(key=>{
  key.open=key.dataset.spotWasOpen==='true';delete key.dataset.spotWasOpen;
 }));
})();

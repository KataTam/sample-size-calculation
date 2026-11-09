/* Explicit calculation snapshots for the developing study plan. MIT. */
(() => {
  if (window.SampleSizePlanTransfer) return;
  window.SampleSizePlanTransfer = true;
  document.addEventListener('click', event => {
    const button = event.target.closest('.plan-transfer-button');
    if (!button) return;
    const box = button.closest('.plan-transfer'), status = box.querySelector('[role="status"]');
    try {
      const record = JSON.parse(box.querySelector('.plan-transfer-data').textContent);
      const id = crypto.randomUUID();
      record.captured = new Date().toISOString();
      localStorage.setItem('sample-size-pending-' + id, JSON.stringify(record));
      const root = window.SampleSizeSiteRoot || new URL('../', location.href).href;
      const target = new URL('assumptions_report/?stage=review&transfer=' + id, root);
      const link = document.createElement('a'); link.href = target.href; link.target = '_blank'; link.rel = 'noopener';
      link.textContent = 'Review this calculation in my study plan';
      status.replaceChildren(link); link.click();
    } catch (_) { status.textContent = 'The calculation could not be transferred. Browser storage may be unavailable; you can copy the report into your study plan.'; }
  });
})();

// Save editable inputs independently of numerical results and simulation batches.
(() => {
  function init() {
    const app=window.SampleSizeApp;
    if(!app||!window.jQuery)return;
    let activity='';let frame=window;
    try{while(frame){const url=new URL(frame.location.href);activity=url.searchParams.get('activity')||activity;if(frame===frame.parent)break;frame=frame.parent;}}catch(_){}
    let key='sample-size-app-inputs-v1-'+app+'-'+activity;
    const ignored=new Set(['activity_choice','stage','calculator_view','recruitment_view','precision_view','error_view','upload_plan']);
    const controls=()=>[...document.querySelectorAll('input[id],select[id],textarea[id]')].filter(el=>!ignored.has(el.id)&&!el.id.endsWith('-number')&&!['file','hidden','button','submit','radio'].includes(el.type)&&el.closest('.shiny-input-container'));
    const snapshot=()=>Object.fromEntries(controls().map(el=>[el.id,el.classList.contains('js-range-slider')?jQuery(el).data('ionRangeSlider')?.result.from:el.type==='checkbox'?el.checked:el.value]));
    let saved;
    const box=document.createElement('details');box.className='activity-details app-resume';
    const summary=document.createElement('summary');summary.textContent='Help and saved inputs';
    const text=document.createElement('p');text.textContent='Underlined questions have hover, keyboard and tap help. Example answers open separately. Your edited inputs are saved in this browser; a restored simulation needs a new run.';
    box.append(summary,text);
      const button=document.createElement('button');button.type='button';button.className='btn btn-default';button.textContent='Restore previous inputs';
      function refreshSaved(){saved=null;try{saved=JSON.parse(localStorage.getItem(key)||'null')}catch(_){};button.hidden=!saved||typeof saved!=='object'||Array.isArray(saved);button.disabled=false;}
      refreshSaved();
      button.addEventListener('click',()=>{
        for(const el of controls()){
          const value=saved[el.id];if(value===undefined||!['number','string','boolean'].includes(typeof value))continue;
          const slider=jQuery(el).data('ionRangeSlider');
          if(slider){const n=Number(value);if(Number.isFinite(n)&&n>=slider.options.min&&n<=slider.options.max){slider.update({from:n});jQuery(el).trigger('change');}}
          else if(el.type==='checkbox'&&typeof value==='boolean'){el.checked=value;jQuery(el).trigger('change');}
          else if(el.tagName==='SELECT'){if([...el.options].some(o=>o.value===String(value))){el.value=value;jQuery(el).trigger('change');}}
          else if(String(value).length<=10000){const old=el.value;el.value=value;if(el.checkValidity())jQuery(el).trigger('change');else el.value=old;}
        }
        text.textContent='Previous inputs restored. A new simulation run will use these settings.';button.disabled=true;
      });box.append(button);
    const plan=document.createElement('a');plan.href=new URL('assumptions_report/',window.SampleSizeSiteRoot||new URL('../',location.href)).href;plan.target='_blank';plan.rel='noopener';plan.textContent='My study plan';box.append(plan);
    document.querySelector('.container-fluid')?.prepend(box);
    let timer;const save=()=>{clearTimeout(timer);timer=setTimeout(()=>{timer=null;try{localStorage.setItem(key,JSON.stringify(snapshot()))}catch(_){}},250)};
    function changeActivity(next, reset=false){
      if(next===activity&&!reset)return;
      if(timer){clearTimeout(timer);timer=null;try{localStorage.setItem(key,JSON.stringify(snapshot()))}catch(_){}}
      activity=next;key='sample-size-app-inputs-v1-'+app+'-'+activity;
      if(reset)try{localStorage.removeItem(key)}catch(_){}
      refreshSaved();
      text.textContent='Underlined questions have hover, keyboard and tap help. Example answers open separately. Your edited inputs are saved in this browser; a restored simulation needs a new run.';
    }
    document.addEventListener('input',e=>{if(e.isTrusted&&e.target.id!=='activity_choice'&&e.target.closest('.shiny-input-container'))save();});
    document.addEventListener('change',e=>{if(!e.isTrusted)return;if(e.target.id==='activity_choice')changeActivity(e.target.value);else if(e.target.closest('.shiny-input-container'))save();});
    document.addEventListener('pointerup',e=>{if(e.target.closest('.shiny-input-container')&&!e.target.closest('.shiny-input-container').querySelector('#activity_choice'))save();});
    jQuery(document).on('shiny:inputchanged.appSavedInputs',e=>{if(e.name==='activity_choice'&&typeof e.value==='string')changeActivity(e.value);});
    window.addEventListener('sample-size:activity-context',e=>changeActivity(e.detail.activity,e.detail.reset));
  }
  if(window.jQuery)jQuery(document).one('shiny:connected',init);
})();

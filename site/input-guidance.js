/* Hover, focus and tap help shared by the written activity and Shiny apps. MIT. */
(() => {
  'use strict';
  if (window.InputGuidance) return;
  let current = null, closeTimer, counter = 0;
  const records = new WeakMap();
  const models = {};
  function fitExample(field) {
    if (field.tagName !== 'TEXTAREA' || !field.checkVisibility()) return;
    field.style.height = 'auto';
    field.style.height = (field.scrollHeight + 2) + 'px';
  }
  const widths = new WeakMap();
  const sizes = new ResizeObserver(entries => entries.forEach(({target, contentRect}) => {
    if (widths.get(target) === contentRect.width) return;
    widths.set(target, contentRect.width); fitExample(target);
  }));
  function close() {
    clearTimeout(closeTimer);
    if (!current) return;
    current.tip.hidden = true;
    current.button.setAttribute('aria-expanded', 'false');
    current = null;
  }
  function position(record) {
    const rect = record.button.getBoundingClientRect(), tip = record.tip;
    tip.style.maxHeight = Math.max(120, innerHeight - 24) + 'px';
    const above = rect.top - tip.offsetHeight - 5;
    const top = above >= 12 ? above : rect.bottom + 5;
    tip.style.left = Math.max(12, Math.min(rect.left, innerWidth - tip.offsetWidth - 12)) + 'px';
    tip.style.top = Math.max(12, Math.min(top, innerHeight - tip.offsetHeight - 12)) + 'px';
  }
  function show(record) {
    clearTimeout(closeTimer);
    if (current !== record) close();
    current = record; record.tip.hidden = false;
    record.button.setAttribute('aria-expanded', 'true'); position(record);
  }
  function delayedClose() { clearTimeout(closeTimer); closeTimer = setTimeout(close, 180); }
  function attach(label, help, field, modelAnswer = '', exampleLabel = 'Example answer') {
    if (!label || !field) return;
    let record = records.get(field);
    if (!record) {
      const button = document.createElement('button'), tip = document.createElement('div');
      button.type = 'button'; button.className = 'input-question'; button.id = field.id + '-question';
      button.textContent = label.textContent; button.setAttribute('aria-expanded', 'false');
      tip.className = 'input-guidance-popover'; tip.id = field.id + '-guidance-' + (++counter); tip.role = 'tooltip'; tip.hidden = true;
      button.setAttribute('aria-controls', tip.id); button.setAttribute('aria-describedby', tip.id);
      field.addEventListener('focus', close);
      field.addEventListener('input', close);
      field.setAttribute('aria-describedby', [...new Set([...(field.getAttribute('aria-describedby') || '').split(/\s+/).filter(Boolean), tip.id])].join(' '));
      record = {button, tip, label, field, links: [...label.querySelectorAll('a')].map(a => a.cloneNode(true))};
      label.classList.add('guidance-label'); label.before(button); document.body.append(tip); records.set(field, record);
      if (field.tagName === 'TEXTAREA') {
        sizes.observe(field);
        field.addEventListener('input', () => fitExample(field));
      }
      button.addEventListener('pointerenter', event => { if (event.pointerType !== 'touch') show(record); });
      button.addEventListener('pointerleave', delayedClose);
      button.addEventListener('focus', () => show(record));
      button.addEventListener('blur', event => { if (!tip.contains(event.relatedTarget)) delayedClose(); });
      button.addEventListener('click', event => { event.preventDefault(); show(record); });
      tip.addEventListener('pointerenter', () => clearTimeout(closeTimer));
      tip.addEventListener('pointerleave', delayedClose);
      tip.addEventListener('focusout', event => { if (!tip.contains(event.relatedTarget)) delayedClose(); });
    }
    if (record.button.textContent !== label.textContent) record.button.textContent = label.textContent;
    const p = document.createElement('p'); p.textContent = help;
    if (record.tip.firstChild?.textContent !== help) record.tip.replaceChildren(p);
    if (modelAnswer) {
      field.placeholder = 'Your answer';
      field.dataset.exampleAnswer = modelAnswer;
      if (!record.example) {
        const details=document.createElement('details'); details.className='input-example';
        const summary=document.createElement('summary'); summary.textContent=exampleLabel;
        record.example=document.createElement('p');record.example.className='input-model-answer';
        details.append(summary,record.example);field.after(details);
      }
      record.example.parentElement.querySelector('summary').textContent=exampleLabel;
      if(record.example.textContent!==modelAnswer)record.example.textContent=modelAnswer;
      fitExample(field);
    }
    if (record.links.length && !record.tip.querySelector('a')) {
      const links = document.createElement('p'); links.append('Further explanation: ');
      record.links.forEach((link, i) => { if (i) links.append(' · '); links.append(link.cloneNode(true)); }); record.tip.append(links);
    }
    if (current === record) position(record);
    return record;
  }
  function init() {
    document.querySelectorAll('.input-guidance-source:not([data-attached])').forEach(source => {
      const field = document.getElementById(source.dataset.for);
      const label = field && (document.querySelector('label[for="' + field.id + '"]') || document.getElementById(field.id + '-label'));
      if (!label) return;
      attach(label, source.textContent, field, models[field.id] || source.dataset.model || ''); source.dataset.attached = 'true';
    });
  }
  function updateModels(answers) {
    Object.assign(models, answers);
    for (const [id, answer] of Object.entries(answers)) {
      const field = document.getElementById(id), record = field && records.get(field);
      const source = [...document.querySelectorAll('.input-guidance-source')].find(el => el.dataset.for === id);
      if (source) source.dataset.model = answer;
      if (record && source) attach(record.label, source.textContent, field, answer);
    }
    init();
  }
  function updateHelp(items) {
    for (const [id, content] of Object.entries(items)) {
      const field=document.getElementById(id), record=field&&records.get(field);
      const source=[...document.querySelectorAll('.input-guidance-source')].find(el=>el.dataset.for===id);
      if(source)source.textContent=content.help;
      const label=record?.label||document.querySelector('label[for="'+id+'"]');
      if(label&&content.question)label.textContent=content.question;
      if(label&&field&&source)attach(label,content.help,field,models[id]||source.dataset.model||'');
    }
    init();
  }
  if (window.Shiny) Shiny.addCustomMessageHandler('activity-model-answers', updateModels);
  if (window.Shiny) Shiny.addCustomMessageHandler('activity-question-help', updateHelp);
  document.addEventListener('keydown', event => { if (event.key === 'Escape') close(); });
  document.addEventListener('pointerdown', event => { if (current && !current.button.contains(event.target) && !current.tip.contains(event.target)) close(); });
  document.addEventListener('scroll', () => { if (current) position(current); }, true);
  document.addEventListener('toggle', event => {
    if (event.target instanceof HTMLDetailsElement && event.target.open)
      event.target.querySelectorAll('textarea').forEach(fitExample);
  }, true);
  window.addEventListener('resize', () => { if (current) position(current); });
  window.InputGuidance = {attach, close, init};
  document.addEventListener('DOMContentLoaded', init);
  new MutationObserver(init).observe(document.documentElement, {childList: true, subtree: true});
  init();
})();

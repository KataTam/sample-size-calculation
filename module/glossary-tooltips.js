(function () {
  'use strict';
  const entries = JSON.parse(document.getElementById('glossary-definitions').textContent);
  const byId = new Map(entries.map(entry => [entry.id, entry]));
  const byLabel = new Map(entries.flatMap(entry => entry.aliases.map(label => [label.toLowerCase(), entry])));
  const bound = new WeakSet();
  let popup, active, timer, anchorTop;
  function close() {
    clearTimeout(timer);
    if (popup) popup.hidden = true;
    if (active) active.removeAttribute('aria-describedby');
    active = null;
  }
  function later() { clearTimeout(timer); timer = setTimeout(close, 200); }
  function show(link, entry) {
    clearTimeout(timer);
    if (active && active !== link) active.removeAttribute('aria-describedby');
    active = link;
    if (!popup) {
      popup = document.createElement('div');
      popup.id = 'glossary-tooltip'; popup.className = 'glossary-tooltip';
      popup.setAttribute('role', 'tooltip');
      popup.addEventListener('mouseenter', () => clearTimeout(timer));
      popup.addEventListener('mouseleave', later);
      document.body.append(popup);
    }
    const title = document.createElement('strong'); title.textContent = entry.label;
    const text = document.createElement('p'); text.textContent = entry.definition;
    popup.replaceChildren(title, text); popup.hidden = false;
    link.setAttribute('aria-describedby', popup.id);
    const rect = link.getBoundingClientRect(), width = Math.min(380, innerWidth - 24);
    anchorTop = rect.top;
    popup.style.width = width + 'px';
    popup.style.left = Math.max(12, Math.min(rect.left, innerWidth - width - 12)) + 'px';
    popup.style.top = Math.max(12, Math.min(rect.bottom + 8, innerHeight - popup.offsetHeight - 12)) + 'px';
  }
  function init() {
    // Link missing first mentions in narrative and tables, keeping interactive
    // controls and collapsed explanations free of nested links.
    const autoIds = new Set(['pico','alternative-hypothesis','null-hypothesis','alpha','beta',
      'statistical-power','confidence-interval','standard-deviation','standard-error',
      'target-difference','clinical-threshold','binary-outcome','sampling-variability','precision']);
    const escape = text => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const aliases = entries.filter(e => autoIds.has(e.id)).flatMap(entry => entry.aliases.map(label => ({label,entry})))
      .sort((a,b) => b.label.length-a.label.length);
    const pattern = new RegExp('\\b(' + aliases.map(x=>escape(x.label)).join('|') + ')\\b','gi');
    const roots = document.querySelectorAll('.print-chapter, .page-inner .section.level1, .main-container > .section.level1');
    for (const root of roots) {
      if (root.id === 'glossary' || root.id === 'tutorial-glossary' || root.closest('.print-chapter') && !root.classList.contains('print-chapter')) continue;
      const seen = new Set(), walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT), nodes=[];
      while (walker.nextNode()) nodes.push(walker.currentNode);
      for (const node of nodes) {
        const parent = node.parentElement;
        if (!parent || parent.closest('pre,code,script,style,svg,math,.MathJax,.MathJax_SVG,.csl-entry,.learning-goals,.app-preview,.spot-choice,h1,h2,h3,h4,.caption,caption,button,[role="button"],details')) continue;
        if (!parent.closest('p,li,td,th')) continue;
        const link=parent.closest('a');
        if(link){const entry=byId.get(decodeURIComponent(new URL(link.href,location.href).hash.slice(1)));if(entry)seen.add(entry.id);continue;}
        const matches=[...node.textContent.matchAll(pattern)];
        if(!matches.length)continue;
        const fragment=document.createDocumentFragment();let start=0,changed=false;
        for(const match of matches){
          const entry=byLabel.get(match[0].toLowerCase());
          if(!entry||seen.has(entry.id))continue;
          fragment.append(node.textContent.slice(start,match.index));
          const a=document.createElement('a');a.textContent=match[0];
          a.href=document.getElementById(entry.id)?'#'+entry.id:'glossary.html#'+entry.id;
          fragment.append(a);start=match.index+match[0].length;seen.add(entry.id);changed=true;
        }
        if(changed){fragment.append(node.textContent.slice(start));node.replaceWith(fragment);}
      }
    }
    const seenByChapter = new Map();
    // Optional boxes must not consume the first definition link in the main text.
    const links = Array.from(document.querySelectorAll('.page-inner a[href], .main-container a[href], main a[href]'));
    const optional = a => !!a.closest('details');
    links.sort((a, b) => Number(optional(a)) - Number(optional(b)));
    links.forEach(link => {
      if (link.closest('pre, code, .csl-entry, .tutorial-contents, #TOC, .core-next, .learning-goals')) return;
      const url = new URL(link.href, location.href);
      const entry = byId.get(decodeURIComponent(url.hash.slice(1)));
      if (!entry) return;
      // Shared explanatory anchors can cover multiple terms; use the term's own short definition.
      const specific = byLabel.get(link.textContent.trim().toLowerCase()) || entry;
      const chapter = link.closest('.print-chapter') || link.closest('.section.level1') ||
        link.closest('.page-inner, .main-container, main');
      if (!seenByChapter.has(chapter)) seenByChapter.set(chapter, new Set());
      const seen = seenByChapter.get(chapter);
      if (seen.has(specific.id)) {
        link.replaceWith(...link.childNodes);
        return;
      }
      seen.add(specific.id);
      if (bound.has(link)) return;
      bound.add(link);
      link.dataset.glossaryTerm = specific.id;
      // An inline definition already explains these occurrences. Keep the link
      // to the full glossary without repeating that explanation on hover/focus.
      if (link.closest('.no-glossary-tooltip')) return;
      link.addEventListener('mouseenter', () => show(link, specific));
      link.addEventListener('mouseleave', later);
      link.addEventListener('focus', () => show(link, specific));
      link.addEventListener('blur', later);
      // Native click/tap still opens the complete definition.
    });
    // A map heading is itself a disclosure control. Its short hint belongs on
    // that control; inserting a link inside it would create nested controls.
    for (const [question, id] of [['q6','alpha'], ['q7','beta']]) {
      const summary = document.querySelector('#sample-size-question-' + question + ' > summary');
      const entry = byId.get(id);
      if (!summary || !entry || bound.has(summary)) continue;
      bound.add(summary); summary.dataset.glossaryHint = id;
      summary.addEventListener('mouseenter', () => show(summary, entry));
      summary.addEventListener('mouseleave', later);
      summary.addEventListener('focus', () => show(summary, entry));
      summary.addEventListener('blur', later);
      summary.addEventListener('click', close);
    }
  }
  document.addEventListener('keydown', event => { if (event.key === 'Escape') close(); });
  window.addEventListener('resize', close);
  window.addEventListener('scroll', () => { if (active && Math.abs(active.getBoundingClientRect().top - anchorTop) > 2) close(); }, true);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
  window.addEventListener('load', () => { init(); if (window.gitbook) window.gitbook.events.bind('page.change', () => { close(); init(); }); });
})();

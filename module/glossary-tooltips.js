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
    const seenByChapter = new Map();
    // Optional boxes must not consume the first definition link in the main text.
    const links = Array.from(document.querySelectorAll('.page-inner a[href], .main-container a[href], main a[href]'));
    links.sort((a, b) => Number(!!a.closest('details')) - Number(!!b.closest('details')));
    links.forEach(link => {
      if (link.closest('pre, code, .csl-entry, .tutorial-contents, #TOC, .core-next')) return;
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
      link.addEventListener('mouseenter', () => show(link, specific));
      link.addEventListener('mouseleave', later);
      link.addEventListener('focus', () => show(link, specific));
      link.addEventListener('blur', later);
      // Native click/tap still opens the complete definition.
    });
  }
  document.addEventListener('keydown', event => { if (event.key === 'Escape') close(); });
  window.addEventListener('resize', close);
  window.addEventListener('scroll', () => { if (active && Math.abs(active.getBoundingClientRect().top - anchorTop) > 2) close(); }, true);
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
  window.addEventListener('load', () => { init(); if (window.gitbook) window.gitbook.events.bind('page.change', () => { close(); init(); }); });
})();

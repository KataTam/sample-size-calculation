/* On-demand tutorial apps. Original software: MIT. */
(() => {
  if (window.SampleSizeInlineAppsInstalled) return;
  window.SampleSizeInlineAppsInstalled = true;
  const allowed = {pain_one_many: 'power_explorer', probiotics_calculation: 'two_proportions'};
  const windows = new Map();
  // Event bindings cannot be serialized with the complete HTML export.
  // Track them in this page's runtime rather than in a copied DOM attribute.
  const bound = new WeakSet();
  function appURL(card) {
    // Book chapters and the complete online HTML live in /book/. The RStudio
    // standalone preview and a downloaded file use the published app instead.
    const here = new URL(location.href);
    const base = /^https?:$/.test(here.protocol) && here.pathname.includes('/book/')
      ? new URL(here.pathname.slice(0, here.pathname.indexOf('/book/') + 1), here.origin)
      : new URL('https://katatam.github.io/sample-size-calculation/');
    return new URL(`${card.dataset.inlineApp}/?activity=${card.dataset.activity}`, base);
  }
  function owns(frame, source) {
    try { for (let w = source; w; w = w.parent) {
      if (w === frame.contentWindow) return true;
      if (w === w.parent) break;
    }} catch (_) { /* An unrelated cross-origin message. */ }
    return false;
  }
  function setup() {
    document.querySelectorAll('.inline-activity').forEach(card => {
      if (bound.has(card) || allowed[card.dataset.activity] !== card.dataset.inlineApp) return;
      bound.add(card);
      const start = card.querySelector('[data-inline-start]'), dedicated = card.querySelector('[data-inline-dedicated]');
      const url = appURL(card); start.href = dedicated.href = url.href;
      start.addEventListener('click', event => {
        if (event.button || event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
        // A downloaded HTML file retains its normal link to the live app.
        if (!/^https?:$/.test(location.protocol) || url.origin !== location.origin) return;
        event.preventDefault(); event.stopPropagation();
        if (windows.has(card)) {
          const item = windows.get(card); item.panel.hidden = false; start.hidden = true;
          item.expand.focus(); return;
        }
        const panel = document.createElement('div'); panel.className = 'inline-app-panel';
        const bar = document.createElement('div'); bar.className = 'inline-app-toolbar';
        const status = document.createElement('span'); status.className = 'inline-app-status';
        status.setAttribute('role', 'status'); status.textContent = 'Loading the app\u2026 First use may take a moment.';
        const expand = document.createElement('button'); expand.type = 'button';
        expand.textContent = '\u26f6'; expand.title = 'Expand app'; expand.setAttribute('aria-label', 'Expand app');
        expand.setAttribute('aria-pressed', 'false');
        const close = document.createElement('button'); close.type = 'button'; close.textContent = '\u00d7';
        close.title = 'Close app window'; close.setAttribute('aria-label', 'Close app window');
        const frame = document.createElement('iframe'); frame.dataset.inlineFrame = card.dataset.activity;
        frame.title = card.getAttribute('aria-label'); frame.style.height = '680px';
        const source = new URL(url); source.searchParams.set('embedded', '1'); source.searchParams.set('guided', '1');
        frame.src = source.href;
        const item = {panel, frame, status, expand, url, expanded: false, ready: false, outside: []};
        function resize(expanded) {
          if (item.expanded === expanded) return;
          item.expanded = expanded; panel.classList.toggle('inline-app-expanded', expanded);
          expand.setAttribute('aria-pressed', String(expanded));
          expand.setAttribute('aria-label', expanded ? 'Restore app size' : 'Expand app');
          expand.title = expand.getAttribute('aria-label'); expand.textContent = expanded ? '\u2199' : '\u26f6';
          if (expanded) {
            panel.setAttribute('role', 'dialog'); panel.setAttribute('aria-modal', 'true');
            panel.setAttribute('aria-label', card.getAttribute('aria-label'));
            let branch = panel;
            while (branch.parentElement) {
              for (const sibling of branch.parentElement.children) if (sibling !== branch && !sibling.inert) {
                sibling.inert = true; item.outside.push(sibling);
              }
              branch = branch.parentElement;
            }
          } else {
            panel.removeAttribute('role'); panel.removeAttribute('aria-modal'); panel.removeAttribute('aria-label');
            item.outside.forEach(el => { el.inert = false; }); item.outside = [];
          }
          // Keep the iframe in its original DOM position, preserving its R session.
          if (!expanded) expand.focus();
        }
        expand.addEventListener('click', () => resize(!item.expanded));
        expand.addEventListener('keydown', event => {
          if (item.expanded && event.key === 'Tab' && event.shiftKey) { event.preventDefault(); close.focus(); }
        });
        close.addEventListener('click', () => {
          resize(false); panel.hidden = true; start.hidden = false; start.focus();
        });
        item.restore = () => resize(false);
        bar.append(status, expand, close); panel.append(bar, frame); start.after(panel); start.hidden = true;
        windows.set(card, item); expand.focus();
        // A timeout leaves a useful message and the dedicated link; it never
        // destroys an app that may still be starting on a slow connection.
        setTimeout(() => { if (!item.ready) status.textContent = 'Still loading. You can also use the dedicated-page link below.'; }, 60000);
      });
    });
  }
  window.addEventListener('message', event => {
    if (event.origin !== location.origin || !event.data || event.data.type !== 'sample-size:inline') return;
    for (const item of windows.values()) {
      if (!owns(item.frame, event.source)) continue;
      const {height, ready, escape, focusToolbar} = event.data;
      if (Number.isFinite(height) && height >= 100 && height <= 40000) item.frame.style.height = `${Math.ceil(height)}px`;
      if (ready) { item.ready = true; item.status.textContent = ''; }
      if (escape && item.expanded) item.restore();
      if (focusToolbar && item.expanded) item.expand.focus();
    }
  });
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') windows.forEach(item => { if (item.expanded) item.restore(); });
  });
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', setup); else setup();
  // Gitbook may replace chapter content without a full page load.
  new MutationObserver(setup).observe(document.documentElement, {childList: true, subtree: true});
})();

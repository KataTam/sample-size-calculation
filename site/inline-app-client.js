/* Compact presentation and intrinsic height for the two tutorial embeds. MIT. */
(() => {
  let shell = window, host = null, origin = null, embedded = false;
  try {
    while (shell) {
      const url = new URL(shell.location.href);
      if (url.searchParams.get('embedded') === '1' &&
          /\/(two_proportions|power_explorer)\/(?:index\.html)?$/.test(url.pathname)) {
        embedded = true; origin = url.origin;
        if (shell !== shell.parent && shell.frameElement?.hasAttribute('data-inline-frame')) host = shell.parent;
        break;
      }
      if (shell === shell.parent) break;
      shell = shell.parent;
    }
  } catch (_) { /* The normal standalone app remains available. */ }
  if (!embedded) return;
  document.documentElement.classList.add('tutorial-embedded');
  const send = payload => { if (host) host.postMessage({type: 'sample-size:inline', ...payload}, origin); };
  let pending, previous = 0, ready = false;
  function measure() {
    clearTimeout(pending); pending = setTimeout(() => {
      const content = document.querySelector('body > .container-fluid');
      if (!content) return;
      // Measure actual content rather than the viewport-sized body: this also
      // lets the outer window shrink after a disclosure or tab is closed.
      const box = content.getBoundingClientRect();
      const height = Math.ceil(box.bottom + scrollY + 16);
      if (Math.abs(height - previous) > 1) { previous = height; send({height, ready}); }
    }, 100);
  }
  function init() {
    const content = document.querySelector('body > .container-fluid');
    if (content) new ResizeObserver(measure).observe(content);
    measure();
  }
  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('toggle', measure, true);
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') send({escape: true});
    if (event.key === 'Tab' && !event.shiftKey) {
      const focusable = [...document.querySelectorAll('a[href],button,input,select,textarea,summary,[tabindex]')]
        .filter(el => el.tabIndex >= 0 && !el.disabled && el.getClientRects().length && !el.closest('[inert]'));
      if (document.activeElement === focusable.at(-1)) {
        try {
          if (shell.frameElement?.closest('.inline-app-expanded')) { event.preventDefault(); send({focusToolbar: true}); }
        } catch (_) { /* Normal keyboard navigation remains available. */ }
      }
    }
  });
  window.addEventListener('resize', measure);
  if (window.jQuery) jQuery(document).on('shiny:idle shiny:message shown.bs.tab', () => {
    ready = true; send({ready: true}); measure();
  });
})();

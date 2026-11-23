/* Resource links open separately; references within the current lesson stay local. */
(() => {
  'use strict';
  if (window.sampleSizeLinks) return;
  const controls = '.book-summary, .book-header, .navigation-prev, .navigation-next, #TOC, .tocify, .toc, [data-link-navigation="same-tab"]';
  function isInlineLink(link) {
    const url = new URL(link.href, location.href);
    return url.origin === location.origin && /^#activity-[a-z_]+$/.test(url.hash) && url.pathname.includes('/book/');
  }
  function isLocalReference(link) {
    const url = new URL(link.href, location.href);
    return Boolean(url.hash) && url.origin === location.origin &&
      url.pathname === location.pathname && url.search === location.search;
  }
  function isResourceLink(link) {
    if (isInlineLink(link) || isLocalReference(link)) return false;
    const href = (link.getAttribute('href') || '').trim();
    if (!href || href === '#' || /^(?:javascript:|mailto:|tel:|data:|blob:)/i.test(href)) return false;
    if (link.hasAttribute('download') || link.hasAttribute('data-question') || link.getAttribute('role') === 'button') return false;
    if (link.matches('.anchor-section, .anchor, .shiny-download-link, .shiny-tab-input, .action-button, .dropdown-toggle, .toggle-dropdown, [data-toggle], [data-bs-toggle]')) return false;
    return !!link.closest('.activity-toc') || !link.closest(controls);
  }
  function apply(root = document) {
    root.querySelectorAll('a[href]').forEach(link => {
      if (isInlineLink(link) || isLocalReference(link)) {
        link.removeAttribute('target');
        const label = link.getAttribute('aria-label');
        if (label?.endsWith(' (opens in a new tab)')) link.setAttribute('aria-label', label.replace(/ \(opens in a new tab\)$/, ''));
        return;
      }
      if (!isResourceLink(link)) return;
      link.setAttribute('target', '_blank');
      const rel = new Set((link.getAttribute('rel') || '').split(/\s+/).filter(Boolean));
      rel.add('noopener');
      link.setAttribute('rel', [...rel].join(' '));
    });
  }
  window.sampleSizeLinks = {apply, isResourceLink};
  apply();
  // Capture before GitBook's delegated navigation can reuse the lesson tab.
  document.addEventListener('click', event => {
    const link = event.target.closest && event.target.closest('a[href]');
    if (!link || event.defaultPrevented || !isResourceLink(link)) return;
    link.setAttribute('target', '_blank');
    const rel = new Set((link.getAttribute('rel') || '').split(/\s+/).filter(Boolean));
    rel.add('noopener'); link.setAttribute('rel', [...rel].join(' '));
    event.stopPropagation();
  }, true);
  new MutationObserver(() => apply()).observe(document.documentElement, {childList: true, subtree: true});
})();

/* Resource links open beside the current lesson or activity; controls stay local. */
(() => {
  'use strict';
  if (window.sampleSizeLinks) return;
  const controls = '.book-summary, .book-header, .navigation-prev, .navigation-next, #TOC, .tocify, .toc, [data-link-navigation="same-tab"]';
  function isResourceLink(link) {
    const href = (link.getAttribute('href') || '').trim();
    if (!href || href === '#' || /^(?:javascript:|mailto:|tel:|data:|blob:)/i.test(href)) return false;
    if (link.hasAttribute('download') || link.hasAttribute('data-question') || link.getAttribute('role') === 'button') return false;
    if (link.matches('.anchor-section, .anchor, .shiny-download-link, .shiny-tab-input, .action-button, .dropdown-toggle, .toggle-dropdown, [data-toggle], [data-bs-toggle]')) return false;
    return !!link.closest('.activity-toc') || !link.closest(controls);
  }
  function apply(root = document) {
    root.querySelectorAll('a[href]').forEach(link => {
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

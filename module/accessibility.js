(() => {
  function enhance() {
    const main = document.querySelector('section.normal') || document.querySelector('main');
    if (!main) return;
    if (!main.id) main.id = 'reading-content';
    main.setAttribute('tabindex', '-1');
    if (!document.querySelector('.skip-to-content')) {
      const skip = document.createElement('a'); skip.className = 'skip-to-content';
      skip.setAttribute('data-link-navigation', 'same-tab'); skip.href = '#' + main.id; skip.textContent = 'Skip to main content';
      skip.addEventListener('click', event => { event.preventDefault(); main.focus(); main.scrollIntoView(); }); document.body.prepend(skip);
    }
    main.querySelectorAll('pre code a').forEach(a => { if (!a.textContent.trim()) a.remove(); });
    main.querySelectorAll('table').forEach(table => {
      if (table.closest('.table-scroll')) return;
      const wrap = document.createElement('div'); wrap.className = 'table-scroll';
      wrap.tabIndex = 0; wrap.setAttribute('role', 'region');
      wrap.setAttribute('aria-label', table.caption?.textContent.trim() || 'Data table');
      table.before(wrap); wrap.append(table);
    });
    main.querySelectorAll('table thead th').forEach(th => { if (!th.hasAttribute('scope')) th.scope = 'col'; });
    main.querySelectorAll('.core-heading > h1, .advanced-heading > h1').forEach(h => {
      if (h.querySelector('.reader-level')) return;
      const badge = document.createElement('span'); badge.className = 'reader-level';
      badge.textContent = h.parentElement.classList.contains('advanced-heading') ? 'Advanced ' : 'Core '; h.prepend(badge);
    });
    main.querySelectorAll('a[target="_blank"]').forEach(a => {
      if (!a.getAttribute('aria-label') && a.textContent.trim()) a.setAttribute('aria-label', a.textContent.trim() + ' (opens in a new tab)');
    });
  }
  enhance(); window.addEventListener('load', enhance);
  if (window.gitbook) window.gitbook.events.bind('page.change', enhance);
})();


/* Use the existing toolbar search, with section-level results across the book. */
(() => {
  let indexPromise;
  let request = 0;
  const normalize = text => text.toLocaleLowerCase().normalize('NFKD').replace(/[\u0300-\u036f]/g, '');
  function panel() {
    let node = document.getElementById('tutorial-search-results');
    if (!node) {
      node = document.createElement('div');
      node.id = 'tutorial-search-results';
      node.setAttribute('aria-live', 'polite');
      document.querySelector('.book-search').after(node);
    }
    return node;
  }
  async function search(input) {
    const sequence = ++request, query = input.value.trim(), results = panel();
    results.replaceChildren();
    document.querySelector('.book-summary').scrollTop = 0;
    document.querySelector('.book-summary').classList.toggle('tutorial-search-active', Boolean(query));
    if (!query) return;
    results.textContent = 'Searching the whole tutorial…';
    try {
      indexPromise ||= fetch(new URL('tutorial-search-index.json', location.href)).then(r => {
        if (!r.ok) throw new Error('Search index unavailable');
        return r.json();
      });
      const index = await indexPromise;
      if (sequence !== request) return;
      const words = normalize(query).split(/\s+/);
      const matches = index.filter(item => {
        const text = normalize(item.chapter + ' ' + item.section + ' ' + item.text);
        return words.every(word => text.includes(word));
      });
      results.replaceChildren();
      const status = document.createElement('p');
      status.textContent = `${matches.length} matching sections across the tutorial`;
      results.append(status);
      for (const item of matches) {
        const link = document.createElement('a'); link.href = item.url;
        link.dataset.linkNavigation = 'same-tab';
        const chapter = document.createElement('span'); chapter.className = 'search-chapter'; chapter.textContent = item.chapter;
        const section = document.createElement('span'); section.className = 'search-section'; section.textContent = item.section;
        const excerpt = document.createElement('span'); excerpt.className = 'search-excerpt';
        const first = Math.max(0, normalize(item.text).indexOf(words[0]) - 55);
        excerpt.textContent = (first ? '…' : '') + item.text.slice(first, first + 180) + (item.text.length > first + 180 ? '…' : '');
        link.append(chapter);
        if (item.section !== item.chapter) link.append(section);
        link.append(excerpt);
        // Full navigation resets the old chapter's sidebar and opens hash targets.
        link.addEventListener('click', e => {
          if (e.button || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
          e.preventDefault(); e.stopPropagation(); location.assign(link.href);
        });
        results.append(link);
      }
    } catch (_) {
      indexPromise = null;
      if (sequence === request) results.textContent = 'Search could not load. Please try again.';
    }
  }
  document.addEventListener('input', e => {
    if (!e.target.matches('.book-search input')) return;
    e.stopImmediatePropagation(); search(e.target);
  }, true);
  document.addEventListener('keyup', e => {
    if (!e.target.matches('.book-search input')) return;
    if (e.key === 'Escape') {
      e.target.value = ''; search(e.target); return;
    }
    e.stopImmediatePropagation();
    if (e.key === 'Enter' || e.key === 'ArrowDown') {
      e.preventDefault(); document.querySelector('#tutorial-search-results a')?.focus();
    }
  }, true);
  document.addEventListener('keydown', e => {
    if (!e.target.matches('#tutorial-search-results a')) return;
    if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp') return;
    e.preventDefault(); e.stopImmediatePropagation();
    const links = [...document.querySelectorAll('#tutorial-search-results a')];
    const next = links.indexOf(e.target) + (e.key === 'ArrowDown' ? 1 : -1);
    if (next < 0) document.getElementById('search-box').focus();
    else links[Math.min(next, links.length - 1)].focus();
  }, true);
  function initialize() {
    const input = document.querySelector('.book-search input');
    if (input) {
      input.placeholder = 'Search the whole tutorial';
      input.setAttribute('aria-label', 'Search the whole tutorial');
      input.title = 'Results show chapters and sections. Enter moves to the first result.';
    }
    const target = document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (target) {
      if (target.matches('details')) target.open = true;
      for (let node = target.parentElement; node; node = node.parentElement) if (node.matches('details')) node.open = true;
    }
  }
  new MutationObserver(initialize).observe(document.querySelector('.book-summary'), {childList:true, subtree:true});
  initialize();
})();

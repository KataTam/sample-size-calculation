(function () {
  // Preserve chapter links shared before the planning sections moved.
  function redirectMovedSection() {
    if (!/\/book\/[\w-]+\.html$/.test(location.pathname)) return false;
    const data = document.getElementById('moved-section-data');
    if (!data) return false;
    const destinations = JSON.parse(data.textContent);
    let anchor;
    try { anchor = decodeURIComponent(location.hash.slice(1)); } catch (_) { return false; }
    if (!destinations[anchor] || location.pathname.endsWith('/' + destinations[anchor] + '.html')) return false;
    const target = new URL(destinations[anchor] + '.html' + location.search + location.hash, location.href);
    // Let the current page load its reader scripts before leaving; interrupting
    // their loading can leave the final inline GitBook startup without its library.
    const redirect = () => location.replace(target);
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', redirect, {once:true});
    else redirect();
    return true;
  }
  if (redirectMovedSection()) return;
  window.addEventListener('hashchange', redirectMovedSection);
  // The same contents panel appears in the book and the embedded lesson.
  const book = document.querySelector('.book');
  const sidebar = book?.querySelector('.book-summary');
  if (sidebar && !document.getElementById('toc-resizer')) {
    const embeddedLesson = window.frameElement?.id === 'lesson-frame';
    const defaultWidth = embeddedLesson ? 180 : 300;
    const storageKey = embeddedLesson ? 'sample-size-toc-width-study' : 'sample-size-toc-width';
    let preferredWidth = defaultWidth, drag = null;
    try {
      const saved = Number(localStorage.getItem(storageKey));
      if (Number.isFinite(saved) && saved >= 160) preferredWidth = saved;
    } catch (_) { /* Resizing also works when browser storage is unavailable. */ }
    sidebar.id ||= 'tutorial-contents-pane';
    const divider = document.createElement('div');
    divider.id = 'toc-resizer'; divider.tabIndex = 0;
    divider.setAttribute('role', 'separator');
    divider.setAttribute('aria-label', 'Adjust table of contents width');
    divider.setAttribute('aria-orientation', 'vertical');
    divider.setAttribute('aria-controls', sidebar.id);
    divider.title = 'Drag to resize the contents. Arrow keys adjust the width; double-click restores the default.';
    const grip = document.createElement('span'); grip.setAttribute('aria-hidden', 'true');
    divider.append(grip); book.append(divider);
    function limits() {
      const available = Math.max(220, book.clientWidth);
      // Leave space for the text on desktop and the menu toggle on phones.
      return {min: 160, max: Math.max(160, available - (available <= 600 ? 60 : 240))};
    }
    function paint() {
      const {min, max} = limits();
      const width = Math.round(Math.min(max, Math.max(min, preferredWidth)));
      book.style.setProperty('--toc-width', width + 'px');
      book.classList.toggle('toc-narrow-reader', book.clientWidth - (book.classList.contains('with-summary') ? width : 0) < 1040);
      divider.setAttribute('aria-valuemin', min);
      divider.setAttribute('aria-valuemax', max);
      divider.setAttribute('aria-valuenow', width);
      divider.setAttribute('aria-valuetext', 'Contents ' + width + ' pixels wide');
      return width;
    }
    function save() {
      try { localStorage.setItem(storageKey, preferredWidth); } catch (_) {}
    }
    function change(value) {
      const {min, max} = limits();
      preferredWidth = Math.min(max, Math.max(min, value)); paint();
    }
    divider.addEventListener('pointerdown', event => {
      if (event.button !== 0) return;
      event.preventDefault(); divider.focus();
      drag = {x: event.clientX, width: paint()};
      book.classList.add('toc-resizing');
      divider.setPointerCapture(event.pointerId);
    });
    divider.addEventListener('pointermove', event => {
      if (drag) change(drag.width + event.clientX - drag.x);
    });
    function stopDrag() {
      if (!drag) return;
      drag = null; book.classList.remove('toc-resizing'); save();
    }
    divider.addEventListener('pointerup', stopDrag);
    divider.addEventListener('pointercancel', stopDrag);
    divider.addEventListener('lostpointercapture', stopDrag);
    divider.addEventListener('dblclick', () => { change(defaultWidth); save(); });
    divider.addEventListener('keydown', event => {
      const {min, max} = limits(), width = paint(), step = event.shiftKey ? 40 : 10;
      const value = {ArrowLeft: width - step, ArrowRight: width + step, Home: min, End: max}[event.key];
      if (value === undefined) return;
      // These arrows resize the panel instead of invoking chapter navigation.
      event.preventDefault(); event.stopPropagation(); change(value); save();
    });
    window.addEventListener('resize', paint);
    let shown = book.classList.contains('with-summary');
    new MutationObserver(() => {
      const next = book.classList.contains('with-summary');
      if (next !== shown) { shown = next; paint(); }
    }).observe(book, {attributes:true, attributeFilter:['class']});
    paint();
  }
  // Follow heading IDs: Bookdown's text-based matching is affected by badges
  // and heading controls. Only the selected branch exposes its deeper entries.
  const contents = document.querySelector('.book-summary .summary');
  if (contents) {
    const currentPath = location.pathname.endsWith('/') ? location.pathname + 'index.html' : location.pathname;
    const localEntries = Array.from(contents.querySelectorAll('li.chapter > a')).filter(a =>
      new URL(a.href).pathname === currentPath);
    function selectEntry(entry) {
      contents.querySelectorAll('.reading-current').forEach(li => li.classList.remove('reading-current'));
      localEntries.forEach(a => a.removeAttribute('aria-current'));
      if (entry) { entry.parentElement.classList.add('reading-current'); entry.setAttribute('aria-current', 'location'); }
    }
    function entryFor(target) {
      while (target) {
        const entry = localEntries.find(a => decodeURIComponent(new URL(a.href).hash.slice(1)) === target.id);
        if (entry) return entry;
        target = target.parentElement?.closest('.section[id]');
      }
      return localEntries.find(a => !new URL(a.href).hash);
    }
    function selectHash() {
      let id; try { id = decodeURIComponent(location.hash.slice(1)); } catch (_) { return; }
      selectEntry(entryFor(document.getElementById(id)));
    }
    contents.addEventListener('click', event => {
      const link = event.target.closest('a');
      if (localEntries.includes(link)) selectEntry(link);
    }, true);
    let scrollFrame;
    function followReading() {
      if (scrollFrame) return;
      scrollFrame = requestAnimationFrame(() => {
        scrollFrame = null;
        // At the bottom, a selected heading may be unable to reach the top.
        // Keep its branch open while that heading remains in the viewport.
        const requested = localEntries.find(a => new URL(a.href).hash === location.hash && location.hash);
        const target = requested && document.getElementById(decodeURIComponent(location.hash.slice(1)));
        const heading = target?.querySelector('h2, h3');
        const atEnd = [...document.querySelectorAll('.book-body, .body-inner')].some(el =>
          el.scrollHeight > el.clientHeight && el.scrollHeight - el.scrollTop - el.clientHeight < 2);
        if (atEnd && heading && heading.getBoundingClientRect().top >= 0 && heading.getBoundingClientRect().top < innerHeight) {
          selectEntry(requested); return;
        }
        let current = document.querySelector('.page-inner .section.level1');
        for (const heading of document.querySelectorAll('.page-inner h2, .page-inner h3')) {
          if (heading.getClientRects().length && heading.getBoundingClientRect().top <= 120)
            current = heading.closest('.section[id]');
        }
        selectEntry(entryFor(current));
      });
    }
    document.querySelectorAll('.book-body, .body-inner').forEach(el => el.addEventListener('scroll', followReading, {passive:true}));
    window.addEventListener('hashchange', selectHash);
    selectHash();
  }
  // Merge each advanced section heading with its native disclosure control.
  document.querySelectorAll('details.advanced-explanation').forEach(details => {
    const heading = details.previousElementSibling;
    if (!heading || !/^H[2-6]$/.test(heading.tagName)) return;
    const summary = details.querySelector(':scope > summary');
    if (!summary) return;
    heading.querySelectorAll('.anchor-section').forEach(a => a.remove());
    summary.replaceChildren(heading);
    details.classList.add('section-disclosure');
  });
  const header = document.querySelector('.book-header');
  if (header && !document.getElementById('feedback-link')) {
    const feedback = document.createElement('a');
    feedback.id = 'feedback-link'; feedback.textContent = 'Feedback';
    feedback.href = 'https://forms.cloud.microsoft/e/j00AMibqi5';
    feedback.target = '_blank'; feedback.rel = 'noopener';
    header.append(feedback);
  }
  const popup = document.createElement('div');
  popup.id = 'citation-tooltip'; popup.className = 'glossary-tooltip';
  popup.setAttribute('role', 'tooltip'); popup.hidden = true; document.body.append(popup);
  let current, timer;
  function hide() { popup.hidden = true; current?.removeAttribute('aria-describedby'); current = null; }
  function show(link) {
    clearTimeout(timer); hide(); current = link;
    popup.textContent = '(' + link.dataset.citationLabel + ')'; popup.hidden = false;
    link.setAttribute('aria-describedby', popup.id);
    popup.style.maxWidth = Math.min(420, innerWidth - 24) + 'px';
    const r = link.getBoundingClientRect();
    popup.style.left = Math.max(12, Math.min(r.left, innerWidth - popup.offsetWidth - 12)) + 'px';
    popup.style.top = Math.max(12, Math.min(r.bottom + 8, innerHeight - popup.offsetHeight - 12)) + 'px';
  }
  document.querySelectorAll('a[data-citation-label]').forEach(link => {
    link.addEventListener('mouseenter', () => show(link));
    link.addEventListener('focus', () => show(link));
    link.addEventListener('mouseleave', () => { timer = setTimeout(hide, 180); });
    link.addEventListener('blur', hide);
    // On touch, the first tap reveals the reference; a second follows the link.
    link.addEventListener('click', event => {
      if (matchMedia('(hover: none)').matches && current !== link) { event.preventDefault(); show(link); }
    });
  });
  popup.addEventListener('mouseenter', () => clearTimeout(timer));
  popup.addEventListener('mouseleave', hide);
  document.addEventListener('keydown', event => { if (event.key === 'Escape') hide(); });
  document.addEventListener('click', event => { if (!event.target.closest('[data-citation-label], #citation-tooltip')) hide(); });

  function revealTarget() {
    let target;
    try { target = document.getElementById(decodeURIComponent(location.hash.slice(1))); } catch (_) { return; }
    if (!target) return;
    const own = target.querySelector(':scope > details.advanced-explanation');
    if (own) own.open = true;
    let parent = target.closest('details');
    while (parent) { parent.open = true; parent = parent.parentElement.closest('details'); }
    if (location.hash) requestAnimationFrame(() => target.scrollIntoView());
  }
  window.addEventListener('hashchange', revealTarget); revealTarget();

  const registry = document.getElementById('activity-menu-data');
  if (!registry || document.getElementById('activity-menu-button')) return;
  const groups = JSON.parse(registry.textContent);
  const dialog = document.createElement('dialog'); dialog.id = 'activity-menu';
  const heading = document.createElement('h2'); heading.textContent = 'Activities';
  heading.id = 'activity-menu-title'; dialog.setAttribute('aria-labelledby', heading.id);
  const close = document.createElement('button'); close.textContent = 'Close'; close.type = 'button';
  close.addEventListener('click', () => dialog.close()); dialog.append(close, heading);
  const slug = location.pathname.split('/').pop().replace(/\.html$/, '');
  const ordered = [...groups].sort((a,b) => Number(b.chapter === slug) - Number(a.chapter === slug));
  const root = location.protocol === 'file:' || location.pathname === 'blank' || location.href === 'about:blank'
    ? 'https://katatam.github.io/sample-size-calculation/' : new URL('../', location.href).href;
  for (const group of ordered) {
    const title = document.createElement('h3'); title.textContent = group.route + ': ' + group.title; title.className=group.route==='Core'?'activity-core-heading':'activity-advanced-heading'; dialog.append(title);
    const list = document.createElement('ul');
    for (const item of group.activities) {
      const li = document.createElement('li'), a = document.createElement('a');
      a.textContent = 'Activity: ' + item.label + ' (' + item.route + ')'; a.href = new URL(item.path, root).href;
      a.target = '_blank'; a.rel = 'noopener'; li.append(a); list.append(li);
    }
    dialog.append(list);
  }
  const flashcards = document.createElement('p');
  const flashcardLink = document.createElement('a');
  flashcardLink.textContent = 'Flashcards';
  flashcardLink.href = new URL('student-materials/flashcards/index.html', root).href;
  flashcardLink.target = '_blank'; flashcardLink.rel = 'noopener';
  flashcards.append(flashcardLink); dialog.append(flashcards);
  const button = document.createElement('button'); button.id = 'activity-menu-button';
  button.type='button'; button.textContent='Activities'; button.setAttribute('aria-haspopup','dialog');
  button.addEventListener('click', () => dialog.showModal());
  dialog.addEventListener('click', event => { if (event.target === dialog) { const r=dialog.getBoundingClientRect(); if(event.clientX<r.left || event.clientX>r.right || event.clientY<r.top || event.clientY>r.bottom) dialog.close(); } });
  document.body.append(dialog);
  const planLink=document.createElement('a');planLink.id='my-study-plan';planLink.textContent='My study plan';planLink.href=new URL('assumptions_report/',root).href;planLink.target='_blank';planLink.rel='noopener';(header||document.body).append(planLink);
  const feedbackLink = document.getElementById('feedback-link');
  if (feedbackLink) feedbackLink.before(button);
  else (header || document.body).append(button);
})();

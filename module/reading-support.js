(function () {
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
    const title = document.createElement('h3'); title.textContent = group.title; dialog.append(title);
    const list = document.createElement('ul');
    for (const item of group.activities) {
      const li = document.createElement('li'), a = document.createElement('a');
      a.textContent = 'Activity: ' + item.label; a.href = new URL(item.path, root).href;
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
  const feedbackLink = document.getElementById('feedback-link');
  if (feedbackLink) feedbackLink.before(button);
  else (header || document.body).append(button);
})();

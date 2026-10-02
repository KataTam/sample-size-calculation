/* One persistent activity beside independently navigable tutorial pages. */
(() => {
  'use strict';
  const lesson = document.getElementById('lesson-frame');
  const app = document.getElementById('app-frame');
  const selector = document.getElementById('activity');
  const status = document.getElementById('app-status');
  const appSeparate = document.getElementById('app-separate');
  const lessonSeparate = document.getElementById('lesson-separate');
  const site = new URL('../', location.href);
  let cases = {}, anchors = {}, selected = '', engine = '', ready = false, state = null;
  let queuedActivity = null;
  const allowedApps = new Set(['power_explorer', 'prevalence_precision', 'sampling_distributions']);
  const send = value => app.contentWindow.postMessage(value, location.origin);
  function setView(view) {
    if (!['lesson', 'app', 'both'].includes(view)) return;
    document.body.dataset.view = view;
    document.querySelectorAll('button[data-view]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.view === view)));
  }
  function lessonUrl(record) {
    const target = new URL(record.return_path || 'book/index.html', site);
    const anchor = target.hash.slice(1);
    return new URL(anchors[anchor] || record.return_path || 'book/index.html', site).href;
  }
  function updateSeparate() {
    const target = new URL(engine + '/', site);
    target.searchParams.set('activity', selected);
    if (state) target.hash = new URLSearchParams({state: JSON.stringify(state)}).toString();
    appSeparate.href = target.href;
  }
  function openActivity(id, reset = false) {
    const record = cases[id];
    if (!record || !allowedApps.has(record.app)) return;
    selected = id;
    selector.value = id;
    document.getElementById('activity-prompt').textContent = record.prompt || record.title;
    const targetLesson = lessonUrl(record);
    if (lesson.src !== targetLesson) lesson.src = targetLesson;
    lessonSeparate.href = targetLesson;
    const next = new URL(location.href);
    next.searchParams.set('activity', id);
    history.replaceState(null, '', next);
    queuedActivity = id;
    state = null;
    if (engine !== record.app || !engine) {
      engine = record.app;
      ready = false;
      const targetApp = new URL(engine + '/', site);
      targetApp.searchParams.set('activity', id);
      targetApp.searchParams.set('guided', '1');
      app.src = targetApp.href;
      status.textContent = 'Loading the activity. You can read the lesson while it starts.';
    } else if (ready) {
      send({type: 'sample-size:activity', activity: id, reset});
      queuedActivity = null;
      status.textContent = 'Activity loaded. Chapter navigation keeps the app open.';
    }
    updateSeparate();
  }
  // Only accept messages from the activity iframe or its same-origin descendants.
  function isActivitySource(source, frame = app.contentWindow) {
    if (source === frame) return true;
    try {
      for (let i = 0; i < frame.frames.length; i++) if (isActivitySource(source, frame.frames[i])) return true;
    } catch (_) { /* Unrelated cross-origin frames are not trusted. */ }
    return false;
  }
  window.addEventListener('message', event => {
    if (event.origin !== location.origin || !isActivitySource(event.source)) return;
    const message = event.data;
    if (!message || message.app !== engine) return;
    if (message.type === 'sample-size:ready') {
      ready = true;
      if (queuedActivity) send({type: 'sample-size:activity', activity: queuedActivity});
      queuedActivity = null;
      status.textContent = 'Activity loaded. Chapter navigation keeps the app open.';
    } else if (message.type === 'sample-size:state' && message.state && typeof message.state === 'object') {
      state = message.state;
      updateSeparate();
    }
  });
  lesson.addEventListener('load', () => {
    try {
      const doc = lesson.contentDocument;
      lessonSeparate.href = lesson.contentWindow.location.href;
      // Delegation also covers chapter content replaced by GitBook navigation.
      doc.addEventListener('click', event => {
        if (event.defaultPrevented) return;
        const link = event.target.closest('a[href]');
        if (!link) return;
        const target = new URL(link.getAttribute('href'), doc.baseURI);
        if (/\/study\/?$/.test(target.pathname) && cases[target.searchParams.get('activity')]) {
          event.preventDefault();
          openActivity(target.searchParams.get('activity'));
          if (matchMedia('(max-width: 900px)').matches) setView('app');
        } else if (target.origin !== location.origin && /^https?:$/.test(target.protocol)) {
          link.target = '_blank'; link.rel = 'noopener';
        } else if (target.pathname.includes('/book/')) {
          lessonSeparate.href = target.href;
        }
      });
    } catch (_) { status.textContent = 'Use the separate lesson link if this page cannot be displayed here.'; }
  });
  selector.addEventListener('change', () => openActivity(selector.value));
  document.getElementById('reset').addEventListener('click', () => openActivity(selected, true));
  document.querySelectorAll('button[data-view]').forEach(button => button.addEventListener('click', () => setView(button.dataset.view)));
  document.getElementById('panel-width').addEventListener('input', event => document.documentElement.style.setProperty('--lesson-width', event.target.value + '%'));
  if (matchMedia('(max-width: 900px)').matches) setView('lesson');
  Promise.all([fetch('../teaching-cases.json').then(response => { if (!response.ok) throw Error('Activities unavailable'); return response.json(); }),
    fetch('../chapter-anchors.json').then(response => { if (!response.ok) throw Error('Lesson index unavailable'); return response.json(); })])
    .then(([registry, map]) => {
      cases = registry; anchors = map;
      selector.replaceChildren();
      Object.entries(cases).forEach(([id, record]) => {
        if (!allowedApps.has(record.app)) return;
        const option = document.createElement('option'); option.value = id; option.textContent = record.title; selector.appendChild(option);
      });
      const requested = new URL(location.href).searchParams.get('activity');
      openActivity(cases[requested] ? requested : 'pain_one_many');
    }).catch(error => { status.textContent = 'The activities could not be loaded. Open the lesson or app separately.'; console.error(error); });
})();

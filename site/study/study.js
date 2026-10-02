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
  const allowedApps = new Set(['power_explorer', 'prevalence_precision', 'sampling_distributions', 'assumptions_report']);
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
    if (state && engine !== 'assumptions_report') target.hash = new URLSearchParams({state: JSON.stringify(state)}).toString();
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
    queuedActivity = {activity: id, reset};
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
      if (queuedActivity) send({type: 'sample-size:activity', ...queuedActivity});
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
      // Content links open separately. Chapter navigation still stays in this pane.
      if (doc.defaultView.sampleSizeLinks) doc.defaultView.sampleSizeLinks.apply(doc);
    } catch (_) { status.textContent = 'Use the separate lesson link if this page cannot be displayed here.'; }
  });
  selector.addEventListener('change', () => openActivity(selector.value));
  document.getElementById('reset').addEventListener('click', () => openActivity(selected, true));
  document.querySelectorAll('button[data-view]').forEach(button => button.addEventListener('click', () => setView(button.dataset.view)));
  const separator = document.getElementById('panel-separator');
  const panels = document.querySelector('.panels');
  let lessonWidth = 50, dragging = false;
  const canResize = () => document.body.dataset.view === 'both' && !matchMedia('(max-width: 900px)').matches;
  function setLessonWidth(value) {
    lessonWidth = Math.max(20, Math.min(80, value));
    document.documentElement.style.setProperty('--lesson-width', lessonWidth + 'fr');
    document.documentElement.style.setProperty('--app-width', (100 - lessonWidth) + 'fr');
    const rounded = Math.round(lessonWidth);
    separator.setAttribute('aria-valuenow', rounded);
    separator.setAttribute('aria-valuetext', `Lesson ${rounded}%, activity ${100 - rounded}%`);
  }
  function resizeAt(event) {
    const bounds = panels.getBoundingClientRect();
    setLessonWidth(100 * (event.clientX - bounds.left - separator.offsetWidth / 2) / (bounds.width - separator.offsetWidth));
  }
  separator.addEventListener('pointerdown', event => {
    if (!canResize() || event.button !== 0) return;
    event.preventDefault();
    separator.focus();
    dragging = true;
    document.body.classList.add('resizing');
    separator.setPointerCapture(event.pointerId);
    resizeAt(event);
  });
  separator.addEventListener('pointermove', event => { if (dragging) resizeAt(event); });
  const endResize = () => { dragging = false; document.body.classList.remove('resizing'); };
  separator.addEventListener('pointerup', endResize);
  separator.addEventListener('pointercancel', endResize);
  separator.addEventListener('lostpointercapture', endResize);
  separator.addEventListener('keydown', event => {
    if (!canResize()) return;
    const step = event.shiftKey ? 10 : 2;
    const next = {ArrowLeft: lessonWidth - step, ArrowRight: lessonWidth + step, Home: 20, End: 80}[event.key];
    if (next === undefined) return;
    event.preventDefault();
    setLessonWidth(next);
  });
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

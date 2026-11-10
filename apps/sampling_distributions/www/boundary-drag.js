/* Original software: MIT. R calculates all probabilities and plot coordinates. */
(() => {
  'use strict';
  let state, drag, pending, timer, installed = false;
  const handles = new Map();
  const clamp = (value, min, max) => Math.max(min, Math.min(max, value));
  const contextKey = context => JSON.stringify(context);
  const overlay = () => document.getElementById('boundary-controls');
  const fraction = (value, panel) => panel.left + (value - panel.xmin) / (panel.xmax - panel.xmin) * (panel.right - panel.left);
  const boundary = side => state.boundaries.find(item => item.side === side);

  function alphaFor(value, side) {
    const z = (value - state.context.mu0) / state.se * (side === 'upper' ? 1 : -1);
    // R supplies descending quantiles at the midpoints between slider settings.
    let lo = 0, hi = state.alpha_breaks.length;
    while (lo < hi) {
      const mid = (lo + hi) >>> 1;
      if (state.alpha_breaks[mid] > z) lo = mid + 1;
      else hi = mid;
    }
    return Math.round((.001 + lo * .0001) * 10000) / 10000;
  }

  function flush() {
    clearTimeout(timer); timer = null;
    if (pending && window.Shiny) {
      const alpha = alphaFor(pending.value, pending.side);
      // Update the real input directly, avoiding delayed server-to-slider echoes.
      window.jQuery('#alpha').data('ionRangeSlider').update({from: alpha});
      const number = document.getElementById('alpha-number');
      if (number) number.value = Math.round(alpha * 10000) / 100;
      Shiny.setInputValue('alpha', alpha, {priority: 'event'});
    }
    pending = null;
  }
  function queue(value, side, immediate = false) {
    pending = {value, side, context: state.context};
    if (immediate) flush();
    else if (!timer) timer = setTimeout(flush, 70);
  }
  function place(value, side) {
    // The second boundary in a two-sided test mirrors the first about the null.
    for (const handle of handles.values()) {
      const ownValue = handle.dataset.side === side ? value : 2 * state.context.mu0 - value;
      const panel = state.panels[Number(handle.dataset.panel)];
      handle.style.left = `${100 * fraction(ownValue, panel)}%`;
    }
  }
  function finish(event) {
    if (!drag || (event && event.pointerId !== drag.pointerId)) return;
    const handle = drag.handle, pointerId = drag.pointerId;
    drag = null;
    handle.classList.remove('dragging');
    if (handle.hasPointerCapture(pointerId)) handle.releasePointerCapture(pointerId);
    flush();
  }
  function makeHandle(key, panelIndex, side) {
    const handle = document.createElement('div');
    handle.className = 'boundary-handle';
    handle.dataset.panel = panelIndex; handle.dataset.side = side;
    handle.tabIndex = 0;
    handle.setAttribute('role', 'slider');
    handle.setAttribute('aria-orientation', 'horizontal');
    handle.setAttribute('aria-label', `${side === 'upper' ? 'Upper' : 'Lower'} rejection boundary, ${panelIndex === 0 ? 'null' : 'alternative'} distribution`);
    handle.setAttribute('aria-describedby', 'boundary-instructions boundary-keyboard-help');
    const grip = document.createElement('span');
    grip.className = 'boundary-grip'; grip.textContent = '↔'; grip.setAttribute('aria-hidden', 'true');
    handle.append(grip); overlay().append(handle); handles.set(key, handle);
    handle.addEventListener('pointerdown', event => {
      if (event.button !== 0 || drag) return;
      event.preventDefault(); handle.focus({preventScroll: true});
      const rect = overlay().getBoundingClientRect();
      const current = boundary(side);
      drag = {handle, side, panelIndex, pointerId: event.pointerId,
        offset: event.clientX - rect.left - fraction(current.value, state.panels[panelIndex]) * rect.width};
      handle.setPointerCapture(event.pointerId); handle.classList.add('dragging');
    });
    handle.addEventListener('pointermove', event => {
      if (!drag || drag.handle !== handle || drag.pointerId !== event.pointerId) return;
      event.preventDefault();
      const rect = overlay().getBoundingClientRect(), panel = state.panels[panelIndex], current = boundary(side);
      const position = (event.clientX - rect.left - drag.offset) / rect.width;
      const value = clamp(panel.xmin + (position - panel.left) / (panel.right - panel.left) * (panel.xmax - panel.xmin), current.min, current.max);
      place(value, side); queue(value, side);
    });
    handle.addEventListener('pointerup', finish);
    handle.addEventListener('pointercancel', finish);
    handle.addEventListener('lostpointercapture', finish);
    handle.addEventListener('keydown', event => {
      const current = boundary(side), step = state.se * (event.shiftKey ? .25 : .05);
      const value = event.key === 'Home' ? current.min : event.key === 'End' ? current.max
        : event.key === 'ArrowLeft' ? current.value - step : event.key === 'ArrowRight' ? current.value + step : null;
      if (value === null) return;
      event.preventDefault();
      const next = clamp(value, current.min, current.max);
      place(next, side); queue(next, side, true);
    });
    return handle;
  }
  function receive(next) {
    if (!overlay()) return;
    // An external reset or changed study assumption cancels any old gesture.
    if (state && contextKey(state.context) !== contextKey(next.context)) {
      pending = null; clearTimeout(timer); timer = null; finish();
    }
    state = next;
    const active = new Set();
    state.panels.forEach((panel, panelIndex) => state.boundaries.forEach(item => {
      const key = `${panelIndex}-${item.side}`; active.add(key);
      const handle = handles.get(key) || makeHandle(key, panelIndex, item.side);
      handle.style.top = `${100 * panel.top}%`;
      handle.style.height = `${100 * (panel.bottom - panel.top)}%`;
      if (!drag) handle.style.left = `${100 * fraction(item.value, panel)}%`;
      handle.setAttribute('aria-valuemin', item.min);
      handle.setAttribute('aria-valuemax', item.max);
      handle.setAttribute('aria-valuenow', item.value);
      handle.setAttribute('aria-valuetext', `${item.value.toFixed(2)} mmHg; Type I error probability ${(100 * state.alpha).toFixed(2)}%`);
    }));
    for (const [key, handle] of handles) if (!active.has(key)) { handle.remove(); handles.delete(key); }
    overlay().dataset.alpha = state.alpha;
    overlay().dataset.power = state.power;
  }
  function install() {
    if (installed || !window.Shiny) return;
    installed = true;
    Shiny.addCustomMessageHandler('sampling-boundaries', receive);
  }
  install();
  document.addEventListener('DOMContentLoaded', install);
  if (window.jQuery) jQuery(document).on('shiny:connected', install);
})();

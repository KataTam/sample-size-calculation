/* Shared, presentation-only enhancements. Original software: MIT. */
(() => {
  const narrow = matchMedia('(max-width: 899px)');
  const rounded = value => Math.round(Number(value) * 1e8) / 1e8;
  function enhanceSliders() {
    if (!window.jQuery) return;
    document.querySelectorAll('input.js-range-slider').forEach(input => {
      const slider = jQuery(input).data('ionRangeSlider');
      if (!slider || slider.options.type === 'double') return;
      const group = input.closest('.shiny-input-container');
      if (!group) return;
      const percentage = input.closest('.percentage-slider');
      const factor = percentage ? 100 : 1;
      const unit = percentage?.dataset.suffix === ' percentage points' ? 'points' : percentage ? '%' : '';
      let number = document.getElementById(`${input.id}-number`);
      if (!number) {
        const row = document.createElement('div'); row.className = 'app-slider-value';
        number = document.createElement('input'); number.type = 'number'; number.id = `${input.id}-number`;
        number.className = 'app-slider-number'; number.inputMode = 'decimal';
        const label = group.querySelector('label');
        if (label) { label.id ||= `${input.id}-label`; number.setAttribute('aria-labelledby', label.id); }
        else number.setAttribute('aria-label', input.id);
        const units = document.createElement('span'); units.textContent = unit;
        row.append(number, units); group.insertBefore(row, group.querySelector('.irs'));
        group.classList.add('app-numeric-slider');
        number.addEventListener('change', () => {
          if (!number.checkValidity() || number.value === '') { number.reportValidity(); return; }
          slider.update({from: rounded(Number(number.value) / factor)});
          jQuery(input).trigger('change');
        });
        number.addEventListener('keydown', event => {
          if (event.key === 'Enter') { event.preventDefault(); number.dispatchEvent(new Event('change')); }
        });
        jQuery(input).on('change.appNumber', () => {
          number.value = rounded(slider.result.from * factor);
        });
        slider.update({grid: false, hide_min_max: true, hide_from_to: true});
      }
      number.min = rounded(slider.options.min * factor);
      number.max = rounded(slider.options.max * factor);
      number.step = rounded(slider.options.step * factor);
      if (document.activeElement !== number) number.value = rounded(slider.result.from * factor);
      const sourceHelp = input.getAttribute('aria-describedby');
      if (sourceHelp) number.setAttribute('aria-describedby', sourceHelp);
    });
  }
  function settings() {
    document.querySelectorAll('.well').forEach(well => {
      if (well.querySelector(':scope > .app-settings')) return;
      const disclosure = document.createElement('details'); disclosure.className = 'app-settings';
      disclosure.open = !narrow.matches;
      const summary = document.createElement('summary'); summary.textContent = 'Study settings';
      const content = document.createElement('div'); content.className = 'app-settings-content';
      content.append(...well.childNodes); disclosure.append(summary, content); well.append(disclosure);
    });
  }
  function grow(field) {
    if (!field.getClientRects().length) return;
    field.style.height = 'auto'; field.style.height = `${Math.max(88, field.scrollHeight + 3)}px`;
  }
  function update() {
    settings(); enhanceSliders(); document.querySelectorAll('textarea').forEach(grow);
  }
  let pending;
  function schedule() { clearTimeout(pending); pending = setTimeout(update, 70); }
  new MutationObserver(schedule).observe(document.documentElement, {childList: true, subtree: true});
  document.addEventListener('DOMContentLoaded', update);
  document.addEventListener('input', e => { if (e.target.matches('textarea')) grow(e.target); });
  document.addEventListener('toggle', schedule, true);
  window.addEventListener('resize', schedule);
  narrow.addEventListener('change', () => {
    document.querySelectorAll('.app-settings').forEach(d => { d.open = !narrow.matches; });
  });
  if (window.jQuery) jQuery(document).on('shiny:connected shiny:message shown.bs.tab', schedule);
  schedule();
})();

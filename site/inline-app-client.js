/* Compact presentation and intrinsic height for the tutorial's Shiny apps. MIT. */
(() => {
  let shell = window, host = null, origin = null, embedded = false, engine = '';
  try {
    while (shell) {
      const url = new URL(shell.location.href);
      const match = url.pathname.match(/\/(two_proportions|two_means|power_explorer|dropout_adjustment|prevalence_precision|sampling_distributions)\/(?:index\.html)?$/);
      if (url.searchParams.get('embedded') === '1' && match) {
        engine = match[1];
        embedded = true; origin = url.origin;
        if (shell !== shell.parent && shell.frameElement?.hasAttribute('data-inline-frame')) host = shell.parent;
        break;
      }
      if (shell === shell.parent) break;
      shell = shell.parent;
    }
  } catch (_) { /* The normal standalone app remains available. */ }
  if (!embedded) return;
  document.documentElement.classList.add('tutorial-embedded');
  document.documentElement.dataset.inlineEngine = engine;
  const send = payload => { if (host) host.postMessage({type: 'sample-size:inline', ...payload}, origin); };
  let pending, previous = 0, ready = false;
  function measure() {
    clearTimeout(pending); pending = setTimeout(() => {
      const content = document.querySelector('body > .container-fluid');
      if (!content) return;
      // Measure actual content rather than the viewport-sized body: this also
      // lets the outer window shrink after a disclosure or tab is closed.
      const box = content.getBoundingClientRect();
      const height = Math.ceil(box.bottom + scrollY + 16);
      if (Math.abs(height - previous) > 1) { previous = height; send({height, ready}); }
    }, 100);
  }
  function init() {
    compactControls();
    const content = document.querySelector('body > .container-fluid');
    if (content) new ResizeObserver(measure).observe(content);
    measure();
  }
  function compactControls() {
    // Move existing controls, preserving their Shiny bindings and help. The
    // numerical procedures and the dedicated-page layouts are unchanged.
    const well = document.querySelector('.well');
    if (!well || well.dataset.inlineOrganized) return;
    well.dataset.inlineOrganized = 'true';
    const field = id => {
      const input = document.getElementById(id);
      // The wrapper carries percentage units for the slider and number field.
      return input?.closest('.percentage-slider') || input?.closest('.shiny-input-container');
    };
    if (engine === 'prevalence_precision') {
      const more = document.createElement('details'); more.className = 'inline-secondary';
      const heading = document.createElement('summary'); heading.textContent = 'Example and planning goal';
      more.append(heading);
      for (const node of [field('case_id'), document.getElementById('load_case'), field('goal')]) if (node) more.append(node);
      well.append(more);
    }
    if (engine === 'sampling_distributions') {
      const assumptions = well.querySelector('section.app-input-group');
      const settings = well.querySelector('details.app-input-group');
      if (settings && assumptions) {
        for (const node of [document.getElementById('load_case'), field('mu0')]) if (node) settings.append(node);
        const alpha = field('alpha'); if (alpha) assumptions.append(alpha);
      }
    }
    if (engine === 'dropout_adjustment') {
      const overview = document.querySelector('.tab-pane[data-value="Overview"]');
      const steps = document.getElementById('recruitment_steps');
      const plot = document.getElementById('dropout_plot');
      const caption = document.getElementById('plot_caption');
      if (overview && steps && plot) {
        const figure = document.createElement('div'); figure.className = 'inline-recruitment-figure';
        figure.append(plot); if (caption) figure.append(caption); steps.after(figure);
      }
    }
    if (engine === 'power_explorer') {
      for (const [figureId, textId] of [['planning_plot','overview_text'],['distribution','many_text']]) {
        const figure = document.getElementById(figureId), text = document.getElementById(textId);
        if (figure && text) figure.after(text);
      }
    }
    for (const id of ['interpretation','precision_text','explanation','overview_text','recruitment_interpretation','precision-interpretation']) {
      const result = document.getElementById(id);
      if (result && !result.matches('input,textarea')) result.classList.add('inline-result-text');
    }
  }
  document.addEventListener('DOMContentLoaded', init);
  document.addEventListener('toggle', measure, true);
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape') send({escape: true});
    if (event.key === 'Tab' && !event.shiftKey) {
      const focusable = [...document.querySelectorAll('a[href],button,input,select,textarea,summary,[tabindex]')]
        .filter(el => el.tabIndex >= 0 && !el.disabled && el.getClientRects().length && !el.closest('[inert]'));
      if (document.activeElement === focusable.at(-1)) {
        try {
          if (shell.frameElement?.closest('.inline-app-expanded')) { event.preventDefault(); send({focusToolbar: true}); }
        } catch (_) { /* Normal keyboard navigation remains available. */ }
      }
    }
  });
  window.addEventListener('resize', measure);
  if (window.jQuery) jQuery(document).on('shiny:idle shiny:message shown.bs.tab', () => {
    ready = true; send({ready: true}); measure();
  });
})();

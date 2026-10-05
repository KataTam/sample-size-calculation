# Browser activity links and portable study plans. Statistical methods live in
# sample_size_functions.R; these helpers validate UI state before applying it.
lab_input_defaults <- function() list(
  outcome = "means", goal = "testing", expected_m = 4, expected_p = .4, plan_delta = 3, plan_sd = 5,
  plan_p0 = .3, plan_p1 = .6, threshold_m = 2, threshold_p = .2,
  width_m = 4, width_p = .2, alpha = .05, target_power = .8,
  fixed_n = 60, dropout = .1, recruit_cap = 200, reality = "same",
  true_delta = 1, true_sd = 7, true_p0 = .3, true_p1 = .4,
  seed = 20260914, B = 1000, stage = "Explore assumptions")

study_input_defaults <- function() list(
  study_question = "", study_design = "two_groups", clinical_relevance = "",
  participant_burden = "", evidence_sources = "", eligible_monthly = 20,
  consent_fraction = .7, recruitment_months = 12, cost_base = 0,
  cost_per_patient = 0, justification = "")

validate_lab_inputs <- function(values, complete = TRUE) {
  if (!is.list(values) || is.null(names(values)) || anyDuplicated(names(values)))
    stop("Study inputs must be a named object.", call. = FALSE)
  defaults <- lab_input_defaults()
  if (any(!names(values) %in% names(defaults)))
    stop("This plan contains unsupported lab inputs.", call. = FALSE)
  enums <- list(outcome = c("means", "proportions"),
    goal = c("testing", "precision", "fixed"), reality = c("same", "null", "custom"),
    stage = c("Explore assumptions", "One study", "Many studies", "My study", "Justify and communicate"))
  ranges <- list(expected_m = c(-1e6, 1e6), expected_p = c(-1, 1),
    plan_delta = c(-1e6, 1e6), plan_sd = c(.1, 1e6),
    plan_p0 = c(.01, .99), plan_p1 = c(.01, .99), threshold_m = c(.1, 1e6),
    threshold_p = c(.001, 1), width_m = c(.1, 1e6), width_p = c(.001, 2),
    alpha = c(.001, .1), target_power = c(.5, .99), fixed_n = c(2, 100000),
    dropout = c(0, .5), recruit_cap = c(4, 200000), true_delta = c(-1e6, 1e6),
    true_sd = c(.1, 1e6), true_p0 = c(.01, .99), true_p1 = c(.01, .99),
    seed = c(0, 2147483647), B = c(100, 10000))
  for (name in names(values)) {
    value <- values[[name]]
    if (name %in% names(enums)) {
      if (!is.character(value) || length(value) != 1 || is.na(value) || !value %in% enums[[name]])
        stop(paste("Invalid", name, "selection."), call. = FALSE)
    } else {
      limits <- ranges[[name]]
      if (!is.numeric(value) || length(value) != 1 || !is.finite(value) ||
          value < limits[1] || value > limits[2])
        stop(paste("Invalid", name, "value."), call. = FALSE)
      if (name %in% c("fixed_n", "recruit_cap", "seed", "B") && value != floor(value))
        stop(paste(name, "must be an integer."), call. = FALSE)
    }
  }
  if (complete) utils::modifyList(defaults, values) else values
}

validate_study_inputs <- function(values, complete = TRUE) {
  if (!is.list(values) || is.null(names(values)) || anyDuplicated(names(values)))
    stop("Study details must be a named object.", call. = FALSE)
  defaults <- study_input_defaults()
  if (any(!names(values) %in% names(defaults))) stop("Unsupported study detail.", call. = FALSE)
  designs <- c("two_groups", "paired", "single_proportion", "observational", "diagnostic", "prediction", "other")
  limits <- list(eligible_monthly = c(0, 1e6), consent_fraction = c(0, 1),
    recruitment_months = c(0, 1200), cost_base = c(0, 1e12), cost_per_patient = c(0, 1e9))
  for (name in names(values)) {
    value <- values[[name]]
    if (name %in% names(limits)) {
      if (!is.numeric(value) || length(value) != 1 || !is.finite(value) ||
          value < limits[[name]][1] || value > limits[[name]][2])
        stop(paste("Invalid", name, "value."), call. = FALSE)
    } else {
      if (!is.character(value) || length(value) != 1 || is.na(value) || nchar(value) > 10000)
        stop(paste("Invalid", name, "text."), call. = FALSE)
      if (name == "study_design" && !value %in% designs) stop("Unsupported study design.", call. = FALSE)
    }
  }
  if (complete) utils::modifyList(defaults, values) else values
}

apply_lab_inputs <- function(session, values) {
  values <- validate_lab_inputs(values)
  sliders <- c("plan_p0", "plan_p1", "alpha", "target_power", "dropout", "true_p0", "true_p1", "expected_p", "threshold_p", "width_p")
  selectors <- c("outcome", "goal", "reality")
  for (name in names(values)) {
    if (name == "stage") shiny::updateTabsetPanel(session, "stage", selected = values[[name]])
    else if (name %in% sliders) shiny::updateSliderInput(session, name, value = values[[name]])
    else if (name %in% selectors) shiny::updateSelectInput(session, name, selected = values[[name]])
    else shiny::updateNumericInput(session, name, value = values[[name]])
  }
  invisible(values)
}

apply_study_inputs <- function(session, values) {
  values <- validate_study_inputs(values)
  for (name in names(values)) {
    if (name == "study_design") shiny::updateSelectInput(session, name, selected = values[[name]])
    else if (name == "consent_fraction") shiny::updateSliderInput(session, name, value = values[[name]])
    else if (is.numeric(values[[name]])) shiny::updateNumericInput(session, name, value = values[[name]])
    else shiny::updateTextAreaInput(session, name, value = values[[name]])
  }
  invisible(values)
}

read_study_plan <- function(text) {
  if (length(text) != 1 || !is.character(text) || nchar(text, type = "bytes") > 100000)
    stop("Choose a study-plan JSON file smaller than 100 KB.", call. = FALSE)
  x <- jsonlite::fromJSON(text, simplifyVector = FALSE)
  if (!is.list(x) || !identical(x$schema, "sample-size-study-plan") ||
      !is.numeric(x$version) || length(x$version) != 1 || x$version != 1)
    stop("This file is not a supported sample size study plan.", call. = FALSE)
  list(inputs = validate_lab_inputs(x$inputs), study = validate_study_inputs(x$study),
       activity = if (is.character(x$activity) && length(x$activity) == 1) x$activity else "")
}

lab_state_url <- function(values) {
  values <- validate_lab_inputs(values)
  paste0("../power_explorer/?state=", utils::URLencode(
    jsonlite::toJSON(values, auto_unbox = TRUE, digits = 16), reserved = TRUE))
}

activity_download_button <- function(...) {
  button <- shiny::downloadButton(...)
  button$attribs$download <- NULL
  button$attribs$target <- "_self"
  button
}

activity_download_script <- function() r"---(document.addEventListener('click', async function(event) {
  const link = event.target.closest('a.shiny-download-link');
  if (!link) return;
  event.preventDefault(); event.stopImmediatePropagation();
  const status = document.getElementById('download-status');
  const report = text => { if (status) status.textContent = text; };
  if (!link.href || !link.href.includes('/download/')) { report('Run the activity before downloading.'); return; }
  if (link.getAttribute('aria-busy') === 'true') return;
  link.setAttribute('aria-busy', 'true'); report('Preparing download...');
  try {
    const response = await fetch(link.href);
    if (!response.ok) throw new Error('The file could not be generated.');
    const match = (response.headers.get('Content-Disposition') || '').match(/filename="([^"]+)"/i);
    if (!match) throw new Error('The response did not contain a file.');
    const url = URL.createObjectURL(await response.blob());
    const save = document.createElement('a'); save.href = url; save.download = match[1];
    document.body.appendChild(save); save.click(); save.remove();
    setTimeout(function() { URL.revokeObjectURL(url); }, 60000);
    report('Download prepared: ' + match[1]);
  } catch (error) { report('Download failed. ' + error.message + ' Please try again.'); }
  finally { link.removeAttribute('aria-busy'); }
}, true);)---"

# Exported Shinylive apps have nested frames. Listen on accessible same-origin
# ancestors as well as the app frame, and read the nearest activity/state URL.
percent_slider <- function(inputId, label, min, max, value, step = .01, suffix = "%") {
  shiny::tags$div(class = "percentage-slider", `data-suffix` = suffix, shiny::sliderInput(inputId, label,
    min = min, max = max, value = value, step = step))
}

percentage_display_script <- function() r"---((function () {
  function format(value) { return (Math.round(Number(value) * 10000) / 100).toLocaleString('en', {maximumFractionDigits:2}); }
  function update() {
    if (!window.jQuery) return;
    document.querySelectorAll('.percentage-slider input').forEach(function (input) {
      var slider = jQuery(input).data('ionRangeSlider');
      if (!slider || slider.options.prettify === format) return;
      slider.update({prettify_enabled:true, prettify:format, postfix:input.closest('.percentage-slider').dataset.suffix});
    });
  }
  document.addEventListener('DOMContentLoaded', update);
  if (window.jQuery) jQuery(document).on('shiny:connected shiny:bound shiny:message', function () { setTimeout(update, 50); });
  var observer = new MutationObserver(function () { setTimeout(update, 0); });
  observer.observe(document.documentElement, {childList:true, subtree:true});
  setTimeout(update, 100);
})();)---"

activity_bridge_script <- function(app = "power_explorer") {
  code <- r"---((function() {
  const app = '__APP__';
  const frames = [];
  let current = window, context = null, origin = null, siteRoot = null;
  while (current) {
    try {
      const url = new URL(current.location.href);
      if (/^https?:$/.test(url.protocol)) {
        if (origin && url.origin !== origin) break;
        origin = url.origin;
        if (!context && (url.searchParams.has('activity') || url.searchParams.has('state') ||
          new URLSearchParams(url.hash.slice(1)).has('state'))) context = url;
        if (!siteRoot && new RegExp('/' + app + '/(?:index\\.html)?$').test(url.pathname)) siteRoot = new URL('../', url).href;
      }
      frames.push(current);
      if (current === current.parent) break;
      current = current.parent;
    } catch (_) { break; }
  }
  let connected = false, startupApplied = false;
  // Relative lesson/app links must use the public shell, not an inner webR URL.
  const resolveLinks = () => {
    document.querySelectorAll('a[href]').forEach(link => {
      const href = (link.getAttribute('href') || '').trim();
      if (!href || href === '#' || /^(?:javascript:|mailto:|tel:|data:|blob:)/i.test(href)) return;
      if (link.hasAttribute('download') || link.getAttribute('role') === 'button' ||
          link.matches('.shiny-download-link, .shiny-tab-input, .action-button, [data-toggle], [data-bs-toggle]')) return;
      if (siteRoot && href.startsWith('../')) link.href = new URL(href.slice(3), siteRoot).href;
      link.setAttribute('target', '_blank');
      const rel = new Set((link.getAttribute('rel') || '').split(/\s+/).filter(Boolean));
      rel.add('noopener'); link.setAttribute('rel', [...rel].join(' '));
    });
  };
  new MutationObserver(resolveLinks).observe(document.documentElement, {childList: true, subtree: true});
  resolveLinks();
  const send = (payload) => { if (origin) window.top.postMessage(Object.assign({app}, payload), origin); };
  const apply = (payload) => {
    if (!connected || !window.Shiny) return;
    if (payload.type === 'sample-size:activity' && typeof payload.activity === 'string') {
      Shiny.setInputValue('activity_request', {activity: payload.activity, nonce: Date.now()}, {priority: 'event'});
    } else if (payload.type === 'sample-size:state' && payload.state && typeof payload.state === 'object') {
      Shiny.setInputValue('state_request', {state: payload.state, nonce: Date.now()}, {priority: 'event'});
    }
  };
  const receive = (event) => {
    if (!origin || event.origin !== origin || event.source !== window.top) return;
    const payload = event.data;
    if (!payload || (payload.app && payload.app !== app)) return;
    apply(payload);
  };
  frames.forEach(frame => frame.addEventListener('message', receive));
  $(document).on('shiny:connected', function() {
    connected = true;
    if (!startupApplied && context) {
      startupApplied = true;
      const state = new URLSearchParams(context.hash.slice(1)).get('state') || context.searchParams.get('state');
      if (state) {
        try { apply({type: 'sample-size:state', state: JSON.parse(state)}); }
        catch (_) { Shiny.setInputValue('bridge_error', 'The linked study inputs could not be read.', {priority: 'event'}); }
      } else apply({type: 'sample-size:activity', activity: context.searchParams.get('activity')});
    }
    send({type: 'sample-size:ready'});
  });
  $(document).on('shiny:disconnected', function() { connected = false; });
  Shiny.addCustomMessageHandler('sample-size-state', function(state) { send({type: 'sample-size:state', state}); });
})();)---"
  paste(percentage_display_script(), sub("__APP__", app, code, fixed = TRUE))
}

library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/tutorial_helpers.R")
source("../../R/teaching_cases.R")
source("../../R/activity_bridge.R")

# Let the download response supply the filename. Chromium's download attribute
# can bypass the service worker serving a Shinylive download (issue 468227).
downloadButton <- function(...) {
  button <- shiny::downloadButton(...)
  button$attribs$download <- NULL
  button$attribs$target <- "_self"
  button
}

download_script <- r"---(// Fetch through the page's service worker before asking Chromium to save.
document.addEventListener('click', async function(event) {
  const link = event.target.closest('a.shiny-download-link');
  if (!link) return;
  event.preventDefault();
  event.stopImmediatePropagation();
  const status = document.getElementById('download-status');
  if (!link.href || !link.href.includes('/download/')) {
    status.textContent = 'Run the study before downloading its results.';
    return;
  }
  if (link.getAttribute('aria-busy') === 'true') return;
  link.setAttribute('aria-busy', 'true');
  status.textContent = 'Preparing download...';
  try {
    const response = await fetch(link.href);
    if (!response.ok) throw new Error('The file could not be generated.');
    const disposition = response.headers.get('Content-Disposition') || '';
    const filenameMatch = disposition.match(/filename="([^"]+)"/i);
    if (!filenameMatch) throw new Error('The download response did not contain a file.');
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    const save = document.createElement('a');
    save.href = url;
    save.download = filenameMatch[1];
    document.body.appendChild(save);
    save.click();
    save.remove();
    setTimeout(function() { URL.revokeObjectURL(url); }, 60000);
    status.textContent = 'Download prepared: ' + filenameMatch[1];
  } catch (error) {
    status.textContent = 'Download failed. ' + error.message + ' Please try again.';
  } finally {
    link.removeAttribute('aria-busy');
  }
}, true);)---"

ui <- fluidPage(
  tags$head(tags$script(src = "sampling-journey.js"), tags$link(rel = "stylesheet", href = "sampling-journey.css"), tags$script(HTML(download_script)), tags$script(HTML(activity_bridge_script()))),
  tags$p(id = "download-status", role = "status", `aria-live` = "polite"),
  tags$head(tags$style(HTML("body{font-size:17px;line-height:1.55}.well{background:#f4f7fa}table{font-size:15px}.shiny-html-output{overflow-x:auto}.shiny-output-error-validation{color:#8a3410}.caption{font-size:.9em;color:#505b64;margin:8px 0 20px}"))),
  titlePanel("Sample size reasoning lab", windowTitle = "Sample size reasoning lab"),
  p("Explore a study question and the assumptions behind its design. All prepared cases are hypothetical."),
  selectInput("activity_choice", "Prepared activity", c("Choose an activity or use your own inputs" = "",
    setNames(names(teaching_cases()), vapply(teaching_cases(), function(x) x$title, character(1)))), width = "100%"),
  uiOutput("activity_context"),
  textOutput("plan_import_status"),
  textOutput("missing_note"),
  sidebarLayout(sidebarPanel(width = 4,
    checkboxInput("show_advanced", "Explore further: advanced controls and explanations", FALSE),
    selectInput("outcome", "Outcome", c("Continuous (numerical) outcome" = "means", "Binary (yes/no) outcome" = "proportions")),
    selectInput("goal", "Planning goal", c("Test a difference from zero" = "testing", "Estimation with a target interval width" = "precision", "Assess a fixed number of available participants" = "fixed")),
    p("Two independent groups, equal allocation. Differences are treatment minus control; positive values mean benefit in these cases."),
    conditionalPanel("input.outcome == 'means'",
      numericInput("expected_m", "Expected difference: best current estimate (outcome units)", 4, step = .5),
      numericInput("plan_delta", "Target difference: used in the sample size calculation (outcome units)", 3, step = .5),
      numericInput("plan_sd", "Standard deviation: variation between patients (outcome units)", 5, min = .1),
      helpText("The expected difference records your best current expectation. Only the target difference enters the sample size calculation; SD describes variation between patients."),
      tagList(
      numericInput("threshold_m", "Clinically important difference (outcome units)", 2, min = .1),
      helpText("This clinical threshold is a separate judgment from the target difference.")),
      conditionalPanel("input.show_advanced || input.goal == 'precision'",
      numericInput("width_m", "Target full confidence interval width (outcome units)", 4, min = .1),
      helpText("Full width 4 means a symmetric interval extending approximately 2 units on each side."))),
    conditionalPanel("input.outcome == 'proportions'",
      percent_slider("expected_p", "Expected difference (percentage points)", value = .4, min = -1, max = 1, step = .01, suffix = " percentage points"),
      percent_slider("plan_p0", "Standard treatment: event probability used for planning (%)", .01, .99, .3, step = .01),
      percent_slider("plan_p1", "Novel treatment: event probability used for planning (%)", .01, .99, .6, step = .01),
      textOutput("probability_inputs"),
      helpText("Event probabilities are displayed as percentages. An increase from 30% to 60% is 30 percentage points. The calculation uses the target difference; the expected difference is recorded separately."),
      tagList(
      percent_slider("threshold_p", "Clinically important difference (percentage points)", value = .2, min = .001, max = 1, step = .01, suffix = " percentage points"),
      helpText("Clinical importance is separate from statistical significance.")),
      conditionalPanel("input.show_advanced || input.goal == 'precision'",
      percent_slider("width_p", "Target full confidence interval width (percentage points)", value = .2, min = .001, max = 2, step = .01, suffix = " percentage points"))),
    helpText("The expected difference, target difference and clinical threshold answer separate questions. Record sources and uncertainty in your case worksheet."),
    percent_slider("alpha", tags$span(tags$a(href = "../book/Sample_size_open_module.html#alpha", target = "_blank", rel = "noopener", "Type I error probability"),
      " (%)"), .001, .1, .05, step = .001),
    conditionalPanel("input.show_advanced", helpText("Type I error probability is the probability of falsely rejecting the null: a false positive when population outcomes are equal. The test is two-sided; a 5% error-probability setting is paired with a 95% confidence interval.")),
    percent_slider("target_power", tags$span("Target ", tags$a(href = "../book/Sample_size_open_module.html#statistical-power", target = "_blank", rel = "noopener", "power"),
      " (%)"), .5, .99, .8, step = .01),
    textOutput("error_target_inputs"),
    conditionalPanel("input.show_advanced", helpText("Power is 1 minus ", tags$a(href = "../book/Sample_size_open_module.html#beta", target = "_blank", rel = "noopener", "Type II error probability"),
      ": the probability of detecting a specified true difference (a true positive). The Type II error probability is the probability of missing that difference (a false negative).")),
    conditionalPanel("input.goal == 'fixed'", numericInput("fixed_n", "Available participants for analysis, per group", 60, min = 2, max = 100000, step = 1)),
    percent_slider("dropout", "Expected loss to follow-up in each group (%)", 0, .5, .1, step = .01),
    textOutput("dropout_input"),
    numericInput("recruit_cap", "Maximum recruitment, across both groups", 200, min = 4, max = 200000, step = 2),
    helpText("The curve marks the expected analyzable limit after losses. Actual retention varies."),
    conditionalPanel("input.show_advanced",
    h4("Advanced: what if the assumptions differ?"),
    selectInput("reality", "Assumptions for the simulated studies", c("Same as planning assumptions" = "same", "No true treatment effect" = "null", "Custom effect or variability" = "custom")),
    conditionalPanel("input.reality == 'custom' && input.outcome == 'means'",
      numericInput("true_delta", "True treatment effect assumed for simulation (outcome units; zero or negative allowed)", 1, step = .5),
      numericInput("true_sd", "Standard deviation assumed for simulation (outcome units)", 7, min = .1)),
    conditionalPanel("input.reality == 'custom' && input.outcome == 'proportions'",
      percent_slider("true_p0", "Control event probability assumed for simulation (%)", .01, .99, .3, step = .01),
      percent_slider("true_p1", "Treatment event probability assumed for simulation (%)", .01, .99, .4, step = .01),
      textOutput("generating_inputs")),
    conditionalPanel("input.outcome == 'proportions'",
      tags$details(id = "missing-controls", tags$summary("Explore missing outcomes"),
        p("The scenarios use a fixed recruited sample and analyze participants with observed outcomes. A larger significance percentage should be considered alongside bias and coverage."),
        selectInput("missing_mode", "Missing-outcome scenario", c(
          "Usual simulation: fixed analyzable counts" = "off",
          "Complete outcomes" = "complete", "Equal losses: 10% in each group" = "equal",
          "Unequal losses: 10% standard, 20% novel" = "differential",
          "Outcome-related losses: 10% standard, 20% novel" = "selective")),
        numericInput("missing_n", "Recruited participants per group for these scenarios", 60, min=2, max=100000, step=1),
        p("The first three scenarios have losses unrelated to relief. In the outcome-related scenario, novel-treatment patients without relief are three times as likely to have a missing outcome as those with relief. Probabilities are calibrated to keep the overall expected loss at 20%. Standard-treatment losses remain unrelated to relief."),
        p("One study and Many studies use this recruited count while the extension is active. Planning curves retain their complete-data assumptions."),
        p(tags$a(href="../book/simulation.html#explore-missing-outcomes", target="_blank", rel="noopener", "Explanation and model answer")))),
    tags$details(tags$summary("Reproducibility settings"), numericInput("seed", "Random seed", 20260914, min = 0, max = 2147483647, step = 1)),
    numericInput("B", "Number of simulated studies (B)", 1000, min = 100, max = 10000, step = 100),
    helpText("More participants change study performance. More replications improve simulation precision.")),
    p(tags$a(href = "../book/Sample_size_open_module.html#glossary", target = "_blank", rel = "noopener", "Key terms and assumptions"), " · ",
      tags$a(href = "../book/Sample_size_open_module.html#common-mistakes", target = "_blank", rel = "noopener", "Common mistakes and FAQ"))),
  mainPanel(width = 8, tabsetPanel(id = "stage",
    tabPanel("Explore assumptions", h3("Your planned design"), tableOutput("planning"),
      p(class = "caption", "Table 1. Expected difference, target difference, clinical threshold and sample requirements for the current design."),
      p("Predict a change before moving a control. Compare testing with a power target, estimation with an interval-width target, and fixed-resource planning. Both testing and estimation plans produce estimates and confidence intervals."),
      textOutput("axis_note"), actionButton("fit_axis", "Fit axis to results"),
    plotOutput("planning_plot", height = "430px"), textOutput("planning_text"),
      p(class = "caption", "Figure 1. Power and anticipated full confidence interval width across sample sizes. Dashed lines show the selected targets; points mark the current plan."),
      conditionalPanel("input.show_advanced", h4("Advanced: compare smaller effects"),
      p("Curves compare the target difference with two smaller differences. Predict which curve will reach the target first. Clinical importance is a separate judgment."),
      plotOutput("comparison_plot", height = "360px"),
      p(class = "caption", "Figure 2. Power curves at half, two-thirds and the full target difference, with the power target and expected analyzable recruitment limit."),
      tableOutput("comparison_table"),
      p(class = "caption", "Table 2. Power at the expected analyzable recruitment limit for each assumed benefit."),
      h4("Power across effects at the planned sample size"),
      plotOutput("effect_plot", height = "320px"),
      p(class = "caption", "Figure 3. Two-sided power across hypothetical true effects, holding the current planned sample size fixed."),
      p("Each point on the curve describes the probability of detecting a specified true difference. Smaller differences can produce significant results and larger differences can go undetected. This sensitivity analysis evaluates the fixed design across plausible population differences."),
      h4("Sensitivity analysis: what if the assumptions differ?"), tableOutput("sensitivity"),
      p(class = "caption", "Table 3. Power and anticipated full interval width under the plan, the reality assumed for simulation and a null effect at unchanged sample size."),
      p("Changing the reality assumed for simulation keeps the planned sample size fixed. Usual simulations use analyzable counts. The Explore missing outcomes extension instead starts with recruited participants and generates missing outcomes; its results appear in One study and Many studies."),
      h4("Analysis assumptions"), textOutput("method"),
      p("Normal outcomes use a pooled-variance t test and interval. Binary outcomes use a pooled score test without continuity correction and a Newcombe-Wilson difference interval. Binary analytical power and precision are approximations; check finite-sample behavior with simulations."))),
    tabPanel("One study", h3("One simulated study"), actionButton("run_one", "Simulate one study", class = "btn-primary"),
      p("A study with high planned power can still produce an inconclusive result."),
      textOutput("one_status"),
      conditionalPanel("input.outcome == 'proportions' && !output.one_has_missing",
        h4("From patients to a sampling distribution"),
        p("Filled circles represent patients with the event; open circles represent patients without it. In the chronic pain case, the event is pain relief. The pink dot starts at this trial’s estimated difference on the upper axis. It moves straight down to the same value on the lower axis, joining estimates from earlier trials. Each dot there summarizes one complete trial."),
        actionButton("run_journey", "Animate 20 trials"),
        tags$button(id = "journey-pause", type = "button", "Pause", disabled = NA),
        tags$button(id = "journey-replay", type = "button", "Replay", disabled = NA),
        tags$label(tags$input(id = "journey-motion", type = "checkbox"), " Reduced motion"),
        tags$div(id = "sampling-journey", `aria-describedby` = "journey-description"),
        tags$p(id = "journey-description"),
        tags$p(id = "journey-status", role = "status", `aria-live` = "polite", "A single study or 20-trial sequence will appear here after simulation."),
        p("The population probabilities stay fixed during a sequence. Patient outcomes and estimated differences vary across trials. Twenty trials illustrate this variation; Simulate many studies provides a larger batch for estimating power.")),
      tableOutput("one_retention"),
      conditionalPanel("output.one_has_missing", p(class="caption", "Recruited, retained, and missing participants in the saved single study.")),
      tableOutput("one_result"),
      p(class = "caption", "Table 4. Effect estimate, interval, p-value and decisions from the saved single-study simulation."),
      textOutput("one_interpretation"), plotOutput("one_plot", height = "300px"),
      p(class = "caption", "Figure 4. The saved study's estimate and interval compared with zero, the clinical threshold and the true effect assumed for simulation."),
      h4("Example participant records"), tableOutput("one_data"),
      textOutput("one_missing_data_note"),
      p(class = "caption", "Table 5. Up to six records per group, with missing records shown first when present. Binary outcomes use 0 for no relief and 1 for relief."),
      downloadButton("download_one", "Download study and assumptions"),
      tags$div(id = "journey-credit", tags$hr(), p("The animated connection between samples, estimates, and sampling distributions was inspired by Douwe Postmus’s ", tags$a(href = "https://postmus.github.io/sampling-simulator/", target = "_blank", rel = "noopener", "Statistical Concepts Lab"), "."))),
    tabPanel("Many studies", p("Compare estimated differences and the percentage of significant results across simulated studies. Explore further adds advanced performance summaries."), h3("Repeated independent studies"), actionButton("run_many", "Simulate many studies", class = "btn-primary"),
      textOutput("many_status"), tableOutput("many_summary"),
      p(class = "caption", "Table 6. Summary of the saved simulation batch. Explore further adds coverage, interval-width targets and simulation uncertainty."),
      textOutput("many_text"),
      conditionalPanel("input.show_advanced", p("Monte Carlo uncertainty comes from simulating a limited number of studies. Confidence interval coverage is the percentage of intervals containing the assumed true effect; the percentage of statistically significant results estimates the probability of rejecting the null.")),
      plotOutput("many_plot", height = "480px"),
      p(class = "caption", "Figure 5. The first 30 saved trial intervals. Filled dots show statistically significant results; open dots do not. Line styles distinguish zero, the clinical threshold and the true effect assumed for simulation."),
      plotOutput("distribution", height = "300px"),
      p(class = "caption", "Figure 6. Distribution of estimated treatment effects across the saved independent studies; the dashed line marks the true effect assumed for simulation."),
      h4("How often is the result statistically significant?"),
      plotOutput("p_values", height = "300px"),
      p(class = "caption", "Figure 7. Saved p-values across independent studies; the dashed line marks the Type I error probability used for that simulation batch."),
      p("The significance percentage describes this analysis under the simulated assumptions. With selective missingness, bias and coverage are essential to interpreting that percentage."),
      downloadButton("download_many", "Download replications and assumptions")),
    tabPanel("My study", h3("Apply this to your question"),
      textAreaInput("study_question", "Research question and primary outcome", rows = 2, width = "100%"),
      selectInput("study_design", "Study design", c("Two independent groups, equal allocation" = "two_groups",
        "Paired or repeated measurements" = "paired", "One population proportion" = "single_proportion",
        "Observational or retrospective study" = "observational", "Diagnostic or screening study" = "diagnostic",
        "Prediction or prognostic model" = "prediction", "Another design" = "other")),
      uiOutput("design_route"),
      textAreaInput("clinical_relevance", "Why would this difference or precision matter clinically?", rows = 3, width = "100%"),
      textAreaInput("participant_burden", "Participant burden, benefits and ethical considerations", rows = 3, width = "100%"),
      textAreaInput("evidence_sources", "Evidence sources and uncertainty in the planning inputs", rows = 3, width = "100%"),
      fluidRow(column(6, numericInput("eligible_monthly", "Eligible participants per month", 20, min = 0)),
        column(6, percent_slider("consent_fraction", "Expected percentage consenting (%)", 0, 1, .7, step = .01))),
      fluidRow(column(4, numericInput("recruitment_months", "Months available for recruitment", 12, min = 0)),
        column(4, numericInput("cost_base", "Fixed study costs (your currency)", 0, min = 0)),
        column(4, numericInput("cost_per_patient", "Cost per recruited participant", 0, min = 0))),
      tableOutput("feasibility_table"),
      p(class = "caption", "Table 7. Expected recruitment, analyzable counts and costs under the stated eligibility, consent and loss assumptions."),
      helpText("These scenarios describe expected recruitment and costs. Actual numbers can vary; your assessment should account for other exclusions and costs where relevant."),
      actionButton("use_feasible_cap", "Use expected recruitment as the lab limit"),
      p(tags$a(href = "../book/Sample_size_open_module.html#own-study", target = "_blank", rel = "noopener", "Read the study justification guidance"))),
    tabPanel("Justify and communicate", h3("Explain your decision"),
      textAreaInput("justification", "State the goal, sources, clinical threshold, sensitivity, feasibility and limits of the intended conclusion.", rows = 8, width = "100%"),
      p("The case template helps you record evidence and clinical reasoning for your assumptions."),
      downloadButton("download_plan", "Download plan and explanation"),
      h4("Save and return to your plan"),
      downloadButton("download_plan_json", "Save study plan (JSON)"),
      fileInput("upload_plan", "Reload a saved study plan", accept = c(".json", "application/json")),
      helpText("The file saves your inputs and written justification on your device. Reloading restores the plan; saved simulation results are kept separate and must be rerun for the new inputs."),
      tags$details(tags$summary("Optional reproducible R workflow"),
        p("Run this script from the repository root to reproduce the current scenario with the same shared functions."), downloadButton("download_code", "Download R script")),
      h3("References"), tags$ul(
        tags$li(tags$a(href = "https://aaroncaldwell.us/SuperpowerBook/", "Caldwell et al. (2022). Power Analysis with Superpower, chapters 1, 11 and 15: inspiration for the clinical activities.")),
        tags$li(tags$a(href = "https://doi.org/10.1016/j.jesp.2017.09.004", "Albers and Lakens (2018). Uncertainty and bias in pilot-based planning.")),
        tags$li(tags$a(href = "https://pubmed.ncbi.nlm.nih.gov/32814615/", "Althouse (2021). Post Hoc Power: Not Empowering, Just Misleading.")),
        tags$li(tags$a(href = "https://doi.org/10.1525/collabra.33267", "Lakens (2022). Sample Size Justification.")),
        tags$li(tags$a(href = "https://doi.org/10.1111/test.12403", "Sandoval et al. (2025). Beyond statistical power.")),
        tags$li(tags$a(href = "https://doi.org/10.2196/52679", "Thiesmeier and Orsini (2024). Rolling the DICE.")),
        tags$li(tags$a(href = "https://doi.org/10.1080/26939169.2024.2394536", "Orsini et al. (2024). Teaching interaction effects.")),
        tags$li(tags$a(href = "https://doi.org/10.1093/aje/kwaa232", "Rudolph et al. (2021). Simulation for teaching epidemiologic methods."))))))))

server <- function(input, output, session) {
  safe <- function(expr) tryCatch(expr, error = function(e) validate(need(FALSE, conditionMessage(e))))
  effect_text <- function(value, outcome, digits = 2) {
    if (outcome == "proportions") paste0(round(100 * value, digits), " percentage points")
    else paste0(signif(value, digits + 2), " units")
  }
  current_activity <- reactiveVal("")
  activity_selection <- reactiveVal("")
  routed_case <- reactiveVal(NULL)
  import_status <- reactiveVal("")
  one_saved <- reactiveVal(NULL)
  journey_payload <- function(trials) {
    x <- trials[[1]]
    list(n = x$spec$n, p0 = x$spec$p_control, p1 = x$spec$p_treatment,
      seed = x$spec$seed, trials = lapply(trials, function(t) list(
        control = as.list(head(t$data$outcome[t$data$group == "Control"], 80)),
        treatment = as.list(head(t$data$outcome[t$data$group == "Treatment"], 80)),
        counts = as.list(c(sum(t$data$outcome[t$data$group == "Control"]),
                          sum(t$data$outcome[t$data$group == "Treatment"]))),
        estimate = t$result$estimate[[1]])))
  }
  observeEvent(input$run_journey, {
    req(is.null(missing_settings()))
    spec <- generating()
    req(spec$outcome == "proportions")
    trials <- lapply(0:19, function(i) {
      next_spec <- spec; next_spec$seed <- (as.double(spec$seed) + i) %% 2147483647
      simulate_one_study(next_spec)
    })
    session$sendCustomMessage("sampling-journey", journey_payload(trials))
  }, ignoreInit = TRUE)
  observeEvent(one_saved(), {
    x <- one_saved()
    if (is.null(x) || !is.null(x$missing)) session$sendCustomMessage("sampling-journey", list(clear = TRUE))
    else if (x$spec$outcome == "proportions")
      session$sendCustomMessage("sampling-journey", journey_payload(list(x)))
  }, ignoreNULL = FALSE)
  many_saved <- reactiveVal(NULL)
  axis_limit <- reactiveVal(NULL)
  current_lab_inputs <- reactive({
    defaults <- lab_input_defaults()
    values <- lapply(names(defaults), function(name) if (is.null(input[[name]])) defaults[[name]] else input[[name]])
    names(values) <- names(defaults)
    safe(validate_lab_inputs(values))
  })
  expected_effect <- reactive({
    values <- current_lab_inputs()
    if (values$outcome == "means") values$expected_m else values$expected_p
  })
  output$probability_inputs <- renderText({
    values <- current_lab_inputs()
    paste0("Expected difference: ", effect_text(values$expected_p, "proportions"),
      "; event probabilities used for planning: control ", format_percent(values$plan_p0, 1),
      ", treatment ", format_percent(values$plan_p1, 1),
      "; target difference: ", effect_text(values$plan_p1 - values$plan_p0, "proportions"),
      "; clinical threshold: ", effect_text(values$threshold_p, "proportions"), ".")
  })
  output$error_target_inputs <- renderText({
    values <- current_lab_inputs()
    paste0("Type I error probability: ", format_percent(values$alpha, 1), "; target power: ",
      format_percent(values$target_power, 1), "; interval confidence: ",
      format_percent(1 - values$alpha, 1), ".")
  })
  output$dropout_input <- renderText(paste0("Expected dropout: ", format_percent(current_lab_inputs()$dropout, 1), "."))
  output$generating_inputs <- renderText({
    values <- current_lab_inputs()
    paste0("Event probabilities assumed for simulation: control ", format_percent(values$true_p0, 1),
      ", treatment ", format_percent(values$true_p1, 1), ".")
  })
  study_details <- reactive({
    defaults <- study_input_defaults()
    values <- lapply(names(defaults), function(name) if (is.null(input[[name]])) defaults[[name]] else input[[name]])
    names(values) <- names(defaults)
    safe(validate_study_inputs(values))
  })
  apply_case <- function(id, reset = FALSE) {
    x <- teaching_case(id)
    session$sendCustomMessage("combine-pain-panels", list(combine = identical(id, "pain_one_many")))
    current_activity(id)
    axis_limit(NULL)
    if (x$app != "power_explorer") {
      routed_case(x)
      import_status("This activity uses a different study design. Follow its activity link below.")
      return(invisible(NULL))
    }
    routed_case(NULL)
    apply_lab_inputs(session, x$inputs[names(x$inputs) %in% names(lab_input_defaults())])
    if (isTRUE(reset)) {
      one_saved(NULL); many_saved(NULL)
      session$sendCustomMessage("sampling-journey", list(clear = TRUE))
      apply_study_inputs(session, study_input_defaults())
    }
    activity_selection(id)
    updateSelectInput(session, "activity_choice", selected = id)
    updateSelectInput(session, "study_design", selected = "two_groups")
    updateCheckboxInput(session, "show_advanced", value =
      x$inputs$stage %in% c("One study", "Many studies") || identical(id, "pain_curves"))
    import_status(if (isTRUE(reset)) "Activity reset: example inputs restored and earlier simulation results cleared." else "Activity assumptions loaded. Any earlier simulation results remain labeled with their saved assumptions.")
    invisible(x)
  }
  handle <- function(expr) tryCatch(expr, error = function(e) import_status(conditionMessage(e)))
  observeEvent(input$activity_choice, {
    if (identical(input$activity_choice, activity_selection())) return()
    activity_selection(input$activity_choice)
    if (nzchar(input$activity_choice)) handle(apply_case(input$activity_choice))
    else { current_activity(""); routed_case(NULL) }
  }, ignoreInit = TRUE)
  observeEvent(input$activity_request, {
    handle(apply_case(input$activity_request$activity, isTRUE(input$activity_request$reset)))
  }, ignoreInit = FALSE)
  observeEvent(input$state_request, {
    handle({
      state <- input$state_request$state
      if (!is.list(state)) stop("Linked study inputs must be an object.")
      case_id <- state$case_id
      if (is.null(case_id)) case_id <- ""
      if (!is.character(case_id) || length(case_id) != 1 || is.na(case_id)) stop("Invalid activity context.")
      if (nzchar(case_id) && teaching_case(case_id)$app != "power_explorer") stop("This linked case uses another activity.")
      details <- if (is.null(state$study)) NULL else validate_study_inputs(state$study)
      state$case_id <- NULL; state$study <- NULL
      values <- validate_lab_inputs(state)
      apply_lab_inputs(session, values)
      if (is.null(details)) updateSelectInput(session, "study_design", selected = "two_groups")
      else apply_study_inputs(session, details)
      activity_selection(case_id)
      updateSelectInput(session, "activity_choice", selected = case_id)
      current_activity(case_id); routed_case(NULL)
      updateCheckboxInput(session, "show_advanced", value = TRUE)
      import_status("Linked inputs loaded. The transferred sample size is held fixed for the assessment.")
    })
  }, ignoreInit = FALSE)
  observeEvent(input$bridge_error, import_status(input$bridge_error), ignoreInit = FALSE)
  output$plan_import_status <- renderText(import_status())
  output$activity_context <- renderUI({
    req(nzchar(current_activity()))
    x <- teaching_case(current_activity())
    tagList(h3(x$title), p(x$prompt),
      if (!is.null(routed_case())) p(tags$a(href = paste0("../", x$app, "/?activity=", x$id),
        target = "_blank", rel = "noopener", "Open the matching activity")),
      p(tags$a(href = paste0("../", x$return_path), target = "_blank", rel = "noopener", "Return to this passage in the tutorial")))
  })
  output$design_route <- renderUI({
    design <- study_details()$study_design
    if (design == "two_groups") return(p("The lab calculations apply to two independent, equally sized groups. Check that the outcome and intended analysis match your study."))
    tagList(p("This design needs a method matched to its structure and planned analysis. The notes and feasibility calculation can be saved here."),
      if (design == "single_proportion") p(tags$a(href = "../prevalence_precision/?activity=prevalence", target = "_blank", rel = "noopener", "Open the proportion estimation activity")),
      p(tags$a(href = "../book/Sample_size_open_module.html#study-designs", target = "_blank", rel = "noopener", "Choose the appropriate planning approach")))
  })
  feasibility <- reactive({
    x <- study_details()
    recruits <- floor(x$eligible_monthly * x$consent_fraction * x$recruitment_months)
    list(recruits = recruits, balanced = 2 * floor(recruits / 2),
      expected_analysable = 2 * floor(floor(recruits / 2) * (1 - input$dropout)),
      budget = x$cost_base + recruits * x$cost_per_patient)
  })
  output$feasibility_table <- renderTable({
    x <- feasibility()
    if (study_details()$study_design != "two_groups") return(data.frame(
      Item = c("Expected recruitment: all participants", "Cost at expected recruitment"), Value = c(x$recruits, x$budget)))
    required <- 2 * adjust_for_dropout(planned()$n, input$dropout)
    details <- study_details()
    data.frame(Item = c("Expected recruitment: all participants", "Available under equal allocation", "Expected participants for analysis, both groups", "Cost at expected recruitment",
      "Recruitment required for the current plan", "Cost at required recruitment", "Expected recruitment covers the current plan"),
      Value = c(x$recruits, x$balanced, x$expected_analysable, x$budget, required,
        details$cost_base + required * details$cost_per_patient, if (x$balanced >= required) "Yes" else "No"))
  })
  observeEvent(input$use_feasible_cap, handle({
    x <- feasibility()
    if (study_details()$study_design != "two_groups") stop("Choose an appropriate design-specific calculator before applying this recruitment limit.")
    if (x$balanced < 4 || x$balanced > 200000) stop("The lab recruitment limit must be between 4 and 200,000 participants in total.")
    updateNumericInput(session, "recruit_cap", value = x$balanced)
    import_status("Expected recruitment applied as a limit, without changing the planned sample size.")
  }))
  observeEvent(input$upload_plan, handle({
    req(input$upload_plan$datapath)
    if (input$upload_plan$size > 100000) stop("Choose a study-plan file smaller than 100 KB.")
    saved <- read_study_plan(paste(readLines(input$upload_plan$datapath, warn = FALSE), collapse = "\n"))
    apply_lab_inputs(session, saved$inputs)
    apply_study_inputs(session, saved$study)
    activity <- if (saved$activity %in% names(teaching_cases()) && teaching_case(saved$activity)$app == "power_explorer") saved$activity else ""
    current_activity(activity); activity_selection(activity); routed_case(NULL)
    updateSelectInput(session, "activity_choice", selected = activity)
    updateCheckboxInput(session, "show_advanced", value = TRUE)
    import_status("Study plan restored. Previous simulation outputs have their original saved assumptions; run again to generate results for this plan.")
  }), ignoreInit = TRUE)
  # The wrapper can display current inputs; it never receives uploaded file paths.
  observe({
    values <- tryCatch(current_lab_inputs(), error = function(e) NULL)
    details <- tryCatch(study_details(), error = function(e) NULL)
    activity <- current_activity()
    if (!is.null(values) && !is.null(details)) {
      values$case_id <- activity; values$study <- details
      session$sendCustomMessage("sample-size-state", values)
    }
  })
  planned <- reactive({
    validate(need(is.null(routed_case()), "Open the matching activity for this study design."),
      need(study_details()$study_design == "two_groups", "This design needs another planning method. See My study for the appropriate route."))
    x <- safe(study_spec(outcome = input$outcome, n = if (input$goal == "fixed") input$fixed_n else 60,
      delta = input$plan_delta, sd = input$plan_sd, p_control = input$plan_p0, p_treatment = input$plan_p1,
      alpha = input$alpha, threshold = if (input$outcome == "means") input$threshold_m else input$threshold_p,
      width_target = if (input$outcome == "means") input$width_m else input$width_p, seed = input$seed, B = input$B))
    x$n <- safe(plan_n(x, input$goal, input$target_power)); x
  })
  generating <- reactive({
    x <- planned()
    if (input$reality == "null") { x$delta <- 0; x$p_treatment <- x$p_control }
    if (input$reality == "custom") {
      if (x$outcome == "means") { x$delta <- input$true_delta; x$sd <- input$true_sd }
      else { x$p_control <- input$true_p0; x$p_treatment <- input$true_p1 }
    }
    safe(do.call(study_spec, x))
  })
  missing_settings <- reactive({
    v <- current_lab_inputs()
    if (v$outcome != "proportions" || v$missing_mode == "off") return(NULL)
    safe(missing_scenario(v$missing_mode, v$missing_n))
  })
  output$missing_note <- renderText({
    m <- missing_settings(); if (is.null(m)) return("")
    paste("Missing-outcome simulation active:", missing_scenario_label(m),
      ". Recruited per group:", m$n, ". Planning curves describe the complete-data plan.")
  })
  output$one_has_missing <- reactive(!is.null(missing_settings()) || (!is.null(one_saved()) && !is.null(one_saved()$missing)))
  outputOptions(output, "one_has_missing", suspendWhenHidden=FALSE)
  snapshot <- reactive({
    missing <- missing_settings(); simulated <- generating()
    if (!is.null(missing)) simulated$n <- missing$n
    list(missing = missing, plan = planned(), generating = simulated, goal = input$goal,
      target_power = input$target_power, dropout = input$dropout,
      recruitment_cap = input$recruit_cap, expected_effect = expected_effect())
  })
  one <- reactive({ req(one_saved()); one_saved() })
  observeEvent(input$run_one, {
    meta <- snapshot(); x <- if (is.null(meta$missing)) simulate_one_study(meta$generating) else simulate_missing_one(meta$generating, meta$missing); x$meta <- meta; one_saved(x)
  }, ignoreInit = TRUE)
  many <- reactive({ req(many_saved()); many_saved() })
  observeEvent(input$run_many, {
    meta <- snapshot()
    withProgress(message = "Simulating independent studies", value = .2, {
      x <- if (is.null(meta$missing)) simulate_trials(meta$generating) else simulate_missing_trials(meta$generating, meta$missing); incProgress(.8); x$meta <- meta; many_saved(x)
    })
  }, ignoreInit = TRUE)
  status <- function(saved, label) paste0(label, ": n = ", saved$spec$n,
    if (is.null(saved$missing)) " analyzable per group; " else paste0(" recruited per group; ", missing_scenario_label(saved$missing), "; "),
    "true difference assumed for simulation = ", effect_text(true_difference(saved$spec), saved$spec$outcome),
    ". ", if (!identical(saved$meta, snapshot())) "Inputs changed. These are saved results; run again to update." else "Results match current inputs.")
  output$planning <- renderTable({
    x <- planned(); recruit <- adjust_for_dropout(x$n, input$dropout)
    data.frame(Item = c("Expected difference (recorded judgment)", "Target difference (used in calculation)", "Clinical threshold (meaningful benefit)",
      "Participants for analysis, per group", "Participants for analysis, total", "Recruit per group", "Recruitment total", "Power at the target difference", "Expected full interval width"),
      Value = c(effect_text(expected_effect(), x$outcome), effect_text(true_difference(x), x$outcome), effect_text(x$threshold, x$outcome),
        x$n, 2*x$n, recruit, 2*recruit, format_percent(spec_power(x), 1), effect_text(anticipated_width(x), x$outcome)))
  })
  output$method <- renderText(method_label(planned()$outcome))
  output$planning_text <- renderText(paste(if (planned()$outcome == "means")
    "The width curve is the expected full t-interval width under normal equal-variance sampling." else
    "The width curve uses the Newcombe-Wilson method with the assumed event probabilities (a plug-in approximation). The mean realized width is assessed across simulated studies.",
    "Realized interval widths vary. Many studies reports the fraction that meets the width target."))
  observeEvent(input$outcome, { axis_limit(NULL) }, ignoreInit = TRUE)
  plot_limit <- reactive({
    x <- planned()
    limit <- axis_limit()
    if (is.null(limit)) { limit <- min(100000, max(200, 2*x$n)); axis_limit(limit) }
    limit
  })
  observeEvent(input$fit_axis, { axis_limit(min(100000, max(200, 2*planned()$n, input$recruit_cap))) })
  output$axis_note <- renderText({
    limit <- plot_limit(); n <- planned()$n
    paste0("The horizontal range stays at 2 to ", limit, " patients per group while you compare inputs. ",
      if (n > limit) paste0("The required ", n, " per group is outside this range. ") else "",
      "Fit the axis to results if you need a different range.")
  })
  output$planning_plot <- renderPlot({
    x <- planned(); ns <- unique(round(seq(2, plot_limit(), length.out = 100)))
    scale <- if (x$outcome == "proportions") 100 else 1
    par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
    plot(ns, 100 * vapply(ns, function(n) spec_power(x, n), numeric(1)), type = "l", lwd = 2,
      ylim = c(0, 100), xlab = "Participants for analysis, per group", ylab = "Power (%)")
    abline(h = 100 * input$target_power, lty = 2); points(x$n, 100 * spec_power(x), pch = 19)
    plot(ns, scale * vapply(ns, function(n) anticipated_width(x, n), numeric(1)), type = "l", lwd = 2,
      xlab = "Participants for analysis, per group", ylab = if (x$outcome == "proportions") "Full CI width (percentage points)" else "Full CI width (outcome units)")
    abline(h = scale * x$width_target, lty = 2); points(x$n, scale * anticipated_width(x), pch = 19)
  }, alt = "Power and anticipated full confidence interval width versus participants per group. Current values are provided in the design table.")
  comparison <- reactive({
    x <- planned()
    cap <- input$recruit_cap
    if (is.null(cap)) cap <- 200
    safe(check_integer(cap, "Total recruitment limit", 4, 200000))
    cap_n <- floor(floor(cap / 2) * (1 - input$dropout))
    validate(need(cap_n >= 2, "The expected analyzable limit must be at least two per group."))
    effects <- true_difference(x) * c(.5, 2/3, 1)
    scenarios <- lapply(effects, function(effect) {
      y <- x
      if (y$outcome == "means") y$delta <- effect
      else y$p_treatment <- y$p_control + effect
      y
    })
    list(spec = x, cap_n = cap_n, scenarios = scenarios, effects = effects)
  })
  output$comparison_plot <- renderPlot({
    z <- comparison(); x <- z$spec
    ns <- unique(round(seq(2, plot_limit(), length.out = 100)))
    colors <- c("#176675", "#a04a24", "#635493")
    plot(range(ns), c(0, 100), type = "n", xlab = "Participants for analysis, per group", ylab = "Power (%)")
    for (i in seq_along(z$scenarios)) lines(ns,
      100 * vapply(ns, function(n) spec_power(z$scenarios[[i]], n), numeric(1)),
      lwd = 2, col = colors[i], lty = i)
    abline(h = 100 * input$target_power, lty = 2, col = "#555555")
    abline(v = z$cap_n, lty = 3, col = "#555555")
    legend("bottomright", legend = effect_text(z$effects, x$outcome, 1),
      col = colors, lty = 1:3, lwd = 2, bty = "n")
  }, alt = "Power curves compare half, two-thirds and the full target difference. The table gives power at the expected analyzable recruitment limit.")
  output$comparison_table <- renderTable({
    z <- comparison()
    data.frame(Difference = effect_text(z$effects, z$spec$outcome), `Participants for analysis per group` = z$cap_n,
      Power_at_limit = format_percent(vapply(z$scenarios, function(x) spec_power(x, z$cap_n), numeric(1)), 1))
  }, digits = 3)
  output$effect_plot <- renderPlot({
    x <- planned(); d <- true_difference(x)
    if (x$outcome == "means") effects <- seq(-max(abs(d)*1.5, x$sd), max(abs(d)*1.5, x$sd), length.out = 101)
    else effects <- seq(.001 - x$p_control, .999 - x$p_control, length.out = 101)
    powers <- vapply(effects, function(effect) {
      y <- x
      if (y$outcome == "means") y$delta <- effect else y$p_treatment <- y$p_control + effect
      spec_power(y)
    }, numeric(1))
    scale <- if (x$outcome == "proportions") 100 else 1
    plot(scale * effects, 100 * powers, type = "l", lwd = 2, col = "#176675", ylim = c(0,100),
      xlab = if (x$outcome == "means") "Treatment minus control (outcome units)" else "Treatment minus control (percentage points)",
      ylab = "Power (%)", main = paste(x$n, "analyzable patients per group"))
    abline(h = 100 * input$target_power, lty = 2); abline(v = 0, lty = 3)
    points(scale * d, 100 * spec_power(x), pch = 19)
  }, alt = "Two-sided power across hypothetical signed differences at fixed planned sample size. Negative differences mean harm; rejection in either direction is counted.")
  output$sensitivity <- renderTable({
    p <- planned(); g <- generating(); null <- p; null$delta <- 0; null$p_treatment <- null$p_control
    xs <- list(p, g, null)
    data.frame(Scenario = c("Plan", "Reality assumed for simulation", "Null effect"), Difference = effect_text(vapply(xs, true_difference, numeric(1)), p$outcome),
      Power = format_percent(vapply(xs, spec_power, numeric(1)), 1), Full_width = effect_text(vapply(xs, anticipated_width, numeric(1)), p$outcome))
  }, digits = 3)
  output$one_status <- renderText({ req(input$run_one > 0); status(one(), "Saved single study") })
  output$one_retention <- renderTable({
    x <- one(); req(!is.null(x$missing))
    n <- x$spec$n; retained <- c(x$result$retained_control, x$result$retained_treatment)
    data.frame(Group=c("Standard treatment", "Novel treatment"), Recruited=n, Retained=retained, Missing=n-retained)
  })
  output$one_result <- renderTable({
    saved <- one(); x <- saved$result
    if (!is.finite(x$estimate)) return(data.frame(Result="Comparison unavailable: no observed outcome in at least one group."))
    data.frame(Measure = c("Effect estimate", "CI lower limit", "CI upper limit", "Two-sided p-value",
      "Full interval width", "Reject zero", "Interval contains the true effect assumed for simulation", "Width target met"),
      Value = c(effect_text(unlist(x[1:3]), saved$spec$outcome), format(round(x$p_value, 4), nsmall = 4),
                effect_text(x$width, saved$spec$outcome),
                ifelse(unlist(x[6:8]), "Yes", "No")), row.names = NULL)
  })
  output$one_interpretation <- renderText({
    x <- one(); if (!is.finite(x$result$estimate)) return("This study cannot estimate the treatment difference from the retained records.")
    paste(interval_interpretation(x$result, x$spec), if (!is.null(x$missing)) "The available-case analysis uses observed outcomes. Selective missingness can bias its estimate of the full-population difference." else "")
  })
  output$one_plot <- renderPlot({ validate(need(is.finite(one()$result$estimate), "No estimable comparison in this study.")); plot_trial_intervals(one()$result, one()$spec) }, alt = "One study estimate and interval; values and interpretation are stated above.")
  output$one_data <- renderTable({
    d <- one()$data
    if ("missing" %in% names(d)) d <- d[order(!d$missing), ]
    do.call(rbind, lapply(split(d, d$group), head, 6))
  }, na="Missing")
  output$one_missing_data_note <- renderText({
    req(!is.null(one()$missing))
    "Simulated outcomes are shown for teaching. Outcomes marked missing are excluded from the analysis and would be unknown in a real study. All participant records are in the download."
  })
  output$many_status <- renderText({ req(input$run_many > 0); paste(status(many(), "Saved batch"), "B =", many()$spec$B) })
  output$many_summary <- renderTable({
    if (!is.null(many()$missing)) return(missing_outcome_summary(many()))
    if (isTRUE(input$show_advanced)) display_simulation_summary(simulation_summary(many()))
    else data.frame(Measure = "Statistically significant simulated results", Percentage = percent(mean(many()$results$reject)), check.names = FALSE)
  })
  output$many_text <- renderText({
    x <- many(); r <- x$results
    if (!is.null(x$missing)) return(paste0("Available-case analysis; reference truth is the full recruited population difference. Performance percentages, mean estimates and widths use the ", sum(is.finite(r$estimate)), " studies with observed outcomes in both groups; ", sum(!is.finite(r$estimate)), " comparisons were unavailable. A high significance percentage can accompany biased estimates and poor coverage. The simulated truth is known only because these are generated data."))
    paste0(if (abs(true_difference(x$spec)) < 1e-12) "No-difference scenario: the percentage of significant results estimates Type I error probability. " else "True-difference scenario: the percentage of significant results estimates power. ",
      "Mean full interval width = ", effect_text(mean(r$width), x$spec$outcome), "; mean estimate = ", effect_text(mean(r$estimate), x$spec$outcome),
      "; truth = ", effect_text(true_difference(x$spec), x$spec$outcome), ". The single-study draw and this batch are generated separately.")
  })
  valid_many <- reactive({
    x <- many(); x$results <- x$results[is.finite(x$results$estimate), , drop=FALSE]
    validate(need(nrow(x$results)>0, "No estimable comparisons in this batch.")); x
  })
  output$many_plot <- renderPlot(plot_trial_intervals(valid_many()$results, many()$spec), alt = "First 30 study intervals; summary percentages and downloadable data provide a text alternative.")
  output$distribution <- renderPlot({
    x <- valid_many(); scale <- if (x$spec$outcome == "proportions") 100 else 1
    hist(scale * x$results$estimate, breaks = 25, col = "#dbeafe", border = "white", main = "Sampling distribution of effects",
      xlab = if (x$spec$outcome == "proportions") "Treatment minus control (percentage points)" else "Treatment minus control (outcome units)")
    abline(v = scale * true_difference(x$spec), lty = 3, lwd = 2)
  }, alt = "Effect estimate histogram; mean estimate and the true effect assumed for simulation are provided above.")
  output$p_values <- renderPlot({
    x <- valid_many()
    hist(x$results$p_value, breaks = seq(0,1,.025), col = "#d2e6e9", border = "white",
      xlab = "p-value", ylab = "Number of studies", main = "Saved repeated-study p-values")
    abline(v = x$spec$alpha, lty = 2, lwd = 2, col = "#923d20")
  }, alt = "Histogram of saved simulation p-values. The significance percentage is reported in the summary table.")
  export_rows <- function(rows, meta) {
    for (k in names(meta$plan)) rows[[paste0("plan_", k)]] <- meta$plan[[k]]
    for (k in names(meta$generating)) rows[[paste0("generating_", k)]] <- meta$generating[[k]]
    rows$planning_goal <- meta$goal; rows$target_power <- meta$target_power
    rows$expected_difference <- meta$expected_effect
    rows$target_difference <- true_difference(meta$plan)
    rows$dropout_fraction <- meta$dropout
    if (!is.null(meta$recruitment_cap)) rows$recruitment_cap <- meta$recruitment_cap
    if (!is.null(meta$missing)) for (k in names(meta$missing)) rows[[paste0("missing_", k)]] <- meta$missing[[k]]
    rows$method <- paste(method_label(meta$plan$outcome), if (!is.null(meta$missing)) "with actual retained group sizes; available cases only" else "")
    rows
  }
  output$download_one <- downloadHandler(filename = function() "single_study.csv", content = function(file) {
    x <- one(); write.csv(export_rows(x$data, x$meta), file, row.names = FALSE)
  })
  output$download_many <- downloadHandler(filename = function() "study_replications.csv", content = function(file) {
    x <- many(); write.csv(export_rows(x$results, x$meta), file, row.names = FALSE)
  })
  outputOptions(output, "download_one", suspendWhenHidden=FALSE)
  outputOptions(output, "download_many", suspendWhenHidden=FALSE)
  output$download_plan <- downloadHandler(filename = function() "sample_size_justification.txt", content = function(file) {
    details <- study_details()
    design <- if (details$study_design == "two_groups" && is.null(routed_case()))
      c(capture.output(str(snapshot())), method_label(planned()$outcome)) else "No sample size calculation: this design requires another planning method."
    writeLines(c("Current sample size justification", design, "Study question and feasibility:",
      capture.output(str(details[names(details) != "justification"])), capture.output(str(feasibility())),
      "Learner explanation:", details$justification), file)
  })
  output$download_plan_json <- downloadHandler(filename = function() "sample_size_study_plan.json", content = function(file) {
    plan <- list(schema = "sample-size-study-plan", version = 1, activity = current_activity(),
      inputs = current_lab_inputs(), study = study_details(),
      snapshot = if (study_details()$study_design == "two_groups" && is.null(routed_case())) snapshot() else NULL)
    writeLines(jsonlite::toJSON(plan, auto_unbox = TRUE, pretty = TRUE, digits = 16, null = "null"), file)
  })
  output$download_code <- downloadHandler(filename = function() "reproduce_studies.R", content = function(file) {
    x <- snapshot()
    calls <- if (is.null(x$missing)) c('one <- simulate_one_study(generating)', 'many <- simulate_trials(generating)', 'simulation_summary(many)') else
      c('settings <-', capture.output(dput(x$missing)), 'one <- simulate_missing_one(generating, settings)', 'many <- simulate_missing_trials(generating, settings)', 'missing_outcome_summary(many)')
    writeLines(c('# Current inputs. Run from the repository root.', 'source("R/sample_size_functions.R")',
      'plan <-', capture.output(dput(x$plan)), 'generating <-', capture.output(dput(x$generating)), calls, 'one$result',
      'valid <- many$results[is.finite(many$results$estimate), , drop=FALSE]',
      'if (nrow(valid)) plot_trial_intervals(valid, many$spec)'), file)
  })
}
shinyApp(ui, server)

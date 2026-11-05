library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/teaching_cases.R")
source("../../R/activity_bridge.R")
source("../../R/model_answers.R")
source("../../R/app_presentation.R")

precision_defaults <- function() list(goal = "precision", anticipated_p = .20,
  full_width = .10, confidence = .95, unknown_p = FALSE, fixed_n = 246,
  dropout = 0, seed = 20260942)
validate_precision_inputs <- function(values, complete = TRUE) {
  defaults <- precision_defaults()
  if (!is.list(values) || is.null(names(values)) || anyDuplicated(names(values)) ||
      any(!names(values) %in% names(defaults))) stop("Unsupported precision inputs.", call. = FALSE)
  x <- if (complete) utils::modifyList(defaults, values) else values
  for (name in names(x)) {
    value <- x[[name]]
    if (name == "goal") {
      if (!is.character(value) || length(value) != 1 || is.na(value) || !value %in% c("precision", "fixed"))
        stop("Choose estimation with a target width or assessment of an available sample.", call. = FALSE)
    } else if (name == "unknown_p") {
      if (!is.logical(value) || length(value) != 1 || is.na(value)) stop("Invalid unknown-proportion choice.", call. = FALSE)
    } else {
      check_scalar(value, name)
      limits <- switch(name, anticipated_p = c(.001, .999), full_width = c(.01, .50),
        confidence = c(.80, .99), fixed_n = c(1, 1e7), dropout = c(0, .80),
        seed = c(0, .Machine$integer.max))
      if (value < limits[1] || value > limits[2]) stop("Invalid ", name, " value.", call. = FALSE)
      if (name %in% c("fixed_n", "seed") && value != floor(value)) stop(name, " must be an integer.", call. = FALSE)
    }
  }
  x
}
apply_precision_inputs <- function(session, values) {
  x <- validate_precision_inputs(values)
  for (name in names(x)) {
    if (name == "goal") updateSelectInput(session, name, selected = x[[name]])
    else if (name == "unknown_p") updateCheckboxInput(session, name, value = x[[name]])
    else if (name %in% c("anticipated_p", "confidence", "dropout", "full_width")) updateSliderInput(session, name, value = x[[name]])
    else updateNumericInput(session, name, value = x[[name]])
  }
  invisible(x)
}

ui <- fluidPage(
  tags$head(tags$script(HTML(activity_bridge_script("prevalence_precision"))), tags$script(HTML(activity_download_script()))),
  titlePanel("Estimate one proportion", windowTitle = "Estimate one proportion"),
  p(class = "app-intro", "This app calculates sample size for a chosen confidence interval width around a population percentage. It also shows the anticipated width for an available sample."),
  sidebarLayout(sidebarPanel(width = 4,
    app_input_group("Study assumptions",
      selectInput("case_id", "Teaching case", c("Prevalence survey" = "prevalence", "Pilot retention" = "pilot_feasibility")),
      actionButton("load_case", "Load case assumptions"),
      selectInput("goal", "Planning goal", c("Estimation with a target interval width" = "precision", "Assess an available sample" = "fixed")),
      percent_slider("anticipated_p", "Anticipated percentage (%)", .001, .999, .20, step = .001),
      activity_help("Use an estimate from a comparable population and time point. For pilot retention, this is the percentage expected to remain in follow-up.", for_input = "anticipated_p"),
      conditionalPanel("input.goal == 'fixed'", numericInput("fixed_n", "Available participants for analysis", 246, min = 1, max = 1e7, step = 1),
        activity_help("Count participants whose event status can be assessed. For retention, the denominator includes everyone enrolled, including those who leave follow-up.", for_input = "fixed_n"))),
    app_input_group("Precision target",
      percent_slider("full_width", "Target full interval width (percentage points)", .01, .50, .10, step = .01, suffix = " percentage points"),
      activity_help("Use the distance between the lower and upper limits. A width of 10 percentage points gives a margin of about 5 points on either side.", for_input = "full_width"),
      percent_slider("confidence", "Confidence level (%)", .80, .99, .95, step = .01),
      activity_help("A 95% interval procedure captures the population percentage in about 95% of repeated studies. Higher confidence requires a larger sample for the same target width.", for_input = "confidence")),
    app_input_group("Planning options", advanced = TRUE, collapsed = TRUE,
      checkboxInput("unknown_p", "Use 50% for conservative planning", FALSE),
      activity_details("Why use 50%?", p("In this approximation, 50% gives the largest sample requirement for a fixed width and confidence level. Simulations still use your anticipated percentage.")),
      percent_slider("dropout", "Expected loss or nonresponse (%)", 0, .80, 0, step = .01),
      activity_help("Allow for unavailable outcome status. When estimating retention, a known departure is an observed outcome; an additional allowance applies when retention status itself is unknown.", for_input = "dropout"),
      tags$details(tags$summary("Reproducibility settings"), numericInput("seed", "Random seed", 20260942, min = 0, max = 2147483647, step = 1)))),
  mainPanel(width = 8, textOutput("case_title"), textOutput("bridge_status"), tabsetPanel(id = "precision_view",
    tabPanel("Overview", uiOutput("overview_metrics"),
      app_overview(tagList(plotOutput("sample_plot", height = "360px"), p(class = "caption", "Figure. Sample size across anticipated percentages. Reference curves use 95% confidence and margins of 5 and 2.5 points; the separate curve uses your settings. The dot marks the required sample for the target width.")),
        textOutput("precision_text")),
      activity_details("Current assumptions and counts", tableOutput("plan_table"), textOutput("approximation_note"))),
    tabPanel("Explore assumptions", h3("One simulated confidence interval"),
      p("Each draw produces a new estimate and confidence interval. The population percentage stays fixed; the observed estimate and interval width can change."),
      actionButton("simulate", "Draw one illustrative sample", class = "btn-primary"), textOutput("saved_status"),
      conditionalPanel("output.study_ready", plotOutput("interval_plot", height = "260px"),
        p(class = "caption", "Figure. The saved sample's Wilson interval and assumed population percentage."),
        tableOutput("study_table"), p(class = "caption", "Table. Observed events, estimate, interval limits and whether the saved width meets its target.")),
      activity_details("Planning and simulation assumptions", p("The saved interval retains the assumptions used to generate it. New settings take effect when you draw another sample."))),
    tabPanel("Report",
      activity_text_input("justification", "Why is your chosen interval width useful for this question?",
        "The example updates with the selected case and current calculation inputs.",
        "Your answer should explain which values the interval needs to distinguish for a useful decision, and whether the required sample is feasible.", rows = 5),
      uiOutput("report_preview"), activity_report_downloads("download_plan"),
      conditionalPanel("output.study_ready", activity_download_button("download_study", "Download saved interval (CSV)")),
      p(id = "download-status", role = "status", `aria-live` = "polite")),
    tabPanel("Methods and references", h3("Calculation with your current values"), uiOutput("worked_method"),
      p("The normal approximation assumes independent sampling at a fixed absolute margin. Wilson intervals stay between 0% and 100%; their realized width depends on the observed count. Clustering and finite-population sampling need additional methods."),
      p(tags$a(href = "https://www.who.int/docs/default-source/ncds/ncd-surveillance/steps/steps-manual.pdf", target = "_blank", rel = "noopener", "WHO STEPS manual"), " · ",
        tags$a(href = "https://doi.org/10.1080/01621459.1927.10502953", target = "_blank", rel = "noopener", "Wilson (1927)"), " · ",
        tags$a(href = "https://njl-admin.nihr.ac.uk/document/download/2023130", target = "_blank", rel = "noopener", "NIHR pilot and feasibility guidance")),
      app_citation("Estimate one proportion", "prevalence_precision")))))
)

server <- function(input, output, session) {
  safe <- function(expr) tryCatch(expr, error = function(e) validate(need(FALSE, conditionMessage(e))))
  active_case <- reactiveVal("prevalence")
  bridge_status <- reactiveVal("")
  snapshot <- reactive(safe(validate_precision_inputs(list(goal = input$goal,
    anticipated_p = input$anticipated_p, full_width = input$full_width,
    confidence = input$confidence, unknown_p = input$unknown_p, fixed_n = input$fixed_n,
    dropout = input$dropout, seed = input$seed))))
  load_case <- function(id) {
    x <- teaching_case(id)
    if (x$app != "prevalence_precision") stop("This case uses a different activity.", call. = FALSE)
    values <- x$inputs[names(precision_defaults())]
    apply_precision_inputs(session, values)
    active_case(id); updateSelectInput(session, "case_id", selected = id)
    bridge_status(paste("Loaded shared case:", x$title))
  }
  observeEvent(input$load_case, tryCatch(load_case(input$case_id), error = function(e) bridge_status(conditionMessage(e))))
  observeEvent(input$activity_request, tryCatch(load_case(input$activity_request$activity), error = function(e) bridge_status(conditionMessage(e))))
  observeEvent(input$state_request, {
    tryCatch({
      state <- input$state_request$state
      saved_case <- NULL
      if (!is.null(state$case_id)) {
        saved_case <- teaching_case(state$case_id)
        if (saved_case$app != "prevalence_precision") stop("This saved case uses a different activity.", call. = FALSE)
        state$case_id <- NULL
      }
      state <- validate_precision_inputs(state)
      apply_precision_inputs(session, state)
      if (!is.null(saved_case)) {
        active_case(saved_case$id); updateSelectInput(session, "case_id", selected = saved_case$id)
      }
      bridge_status("Restored your previous precision assumptions.") },
      error = function(e) bridge_status(conditionMessage(e)))
  })
  observeEvent(input$bridge_error, bridge_status(input$bridge_error))
  observe({ session$sendCustomMessage("sample-size-state", c(snapshot(), list(case_id = active_case()))) })
  plan <- reactive({
    x <- snapshot()
    safe(proportion_precision_plan(x$anticipated_p, x$full_width, x$confidence,
      x$unknown_p, x$dropout))
  })
  analysable_n <- reactive(if (snapshot()$goal == "fixed") snapshot()$fixed_n else plan()$n)
  output$case_title <- renderText(teaching_case(active_case())$title)
  output$case_prompt <- renderText(teaching_case(active_case())$prompt)
  output$bridge_status <- renderText(bridge_status())
  output$plan_table <- renderTable({
    p <- plan(); n <- analysable_n(); x <- snapshot()
    anticipated_width <- 2 * qnorm((1+x$confidence)/2) * sqrt(p$planning_p * (1-p$planning_p) / n)
    data.frame(Item = c("Anticipated percentage used for planning", "Target full interval width", "Target margin of error (half width)",
      "Approximate participants needed for analysis", "Current participants for analysis", "Recruitment target", "Approximate full interval width at the current sample size"),
      Value = c(format_percent(p$planning_p, 1), paste0(100*p$full_width, " percentage points"),
        paste0("±", 100*p$half_width, " percentage points"), p$n, n,
        adjust_for_dropout(n, x$dropout), paste0(round(100*anticipated_width, 1), " percentage points")))
  })
  output$precision_text <- renderText({
    p <- plan(); x <- snapshot()
    paste0("This is one sample, so n is a total count. The requested full width is ",
      100*p$full_width, " percentage points (margin ±", 100*p$half_width, "). ",
      if (x$goal == "fixed") "The available sample is fixed. Its approximate width is shown in the summary for comparison with the target."
      else "Halving the margin multiplies the unrounded normal-approximation requirement by four.")
  })
  output$approximation_note <- renderText({
    p <- plan(); n <- analysable_n()
    sparse <- min(n*p$planning_p, n*(1-p$planning_p)) < 10
    paste("The planned n is an approximation for independent sampling at a fixed absolute margin.",
      if (sparse) "Few expected events or non-events make this approximation less reliable. Rare outcomes require particular care and a justified binomial precision analysis."
      else "Expected counts and sampling assumptions should reflect the intended study.",
      "Clustering, finite-population sampling and diagnostic-test error require additional methods.")
  })
  output$sample_plot <- renderPlot({
    x <- snapshot(); ps <- seq(.001, .999, length.out = 201)
    par(cex.axis = 1.1, cex.lab = 1.1)
    ns <- function(width, confidence) ceiling(qnorm((1+confidence)/2)^2 * ps*(1-ps)/(width/2)^2)
    y1 <- ns(.10, .95); y2 <- ns(.05, .95); current <- ns(x$full_width, x$confidence)
    plot(ps*100, y2, type = "l", lwd = 2, col = "#a34724", ylim = c(0,max(y1,y2,current)),
      xlab = "Assumed prevalence (%)", ylab = "Approximate analyzable participants")
    lines(ps*100, y1, col = "#176675", lwd = 2, lty = 2)
    lines(ps*100, current, col = "#635493", lwd = 2, lty = 3)
    points(plan()$planning_p*100, plan()$n, pch = 19, col = "#635493")
    legend("topright", c("95% confidence; ±2.5 points", "95% confidence; ±5 points", "Your confidence and margin"),
      col = c("#a34724", "#176675", "#635493"), lty = 1:3, lwd = 2, cex = .9, bg = "white")
  }, alt = "Required analyzable sample size versus assumed proportion. The largest requirement is near 50%; halving the margin approximately quadruples the requirement. Current values are in the table.")
  study <- eventReactive(input$simulate, {
    x <- snapshot(); y <- simulate_proportion_study(analysable_n(), x$anticipated_p, x$confidence, x$seed)
    y$inputs <- x; y$case_id <- active_case(); y
  }, ignoreInit = TRUE)
  model_answers <- reactive(list(justification = precision_model_answer(snapshot(), plan(), analysable_n(),
    active_case(), if (isTRUE(input$simulate > 0)) study() else NULL)))
  activity_model_answers(session, model_answers, "justification")
  output$study_ready <- reactive(isTRUE(input$simulate > 0))
  outputOptions(output, "study_ready", suspendWhenHidden = FALSE)
  output$saved_status <- renderText({
    y <- study()
    paste("Saved sample: n =", y$n,
      if (!identical(y$inputs, snapshot())) "Inputs changed. Draw again to update the saved interval."
      else "Interval matches the current assumptions.")
  })
  output$study_table <- renderTable({
    y <- study(); r <- y$result
    data.frame(Events = r$events, Participants = r$n, Estimate = format_percent(r$estimate, 1),
      Lower = format_percent(r$lower, 1), Upper = format_percent(r$upper, 1),
      Full_width = paste0(round(100 * r$full_width, 1), " percentage points"),
      Target_met = r$full_width <= y$inputs$full_width)
  }, digits = 4)
  output$interval_plot <- renderPlot({
    y <- study(); r <- y$result
    plot(r$estimate*100, 1, xlim = c(0,100), ylim = c(.5,1.5), yaxt = "n", pch = 19,
      xlab = "Percentage (%)", ylab = "", main = paste(round(100*y$confidence), "% Wilson interval"))
    segments(r$lower*100, 1, r$upper*100, 1, lwd = 3, col = "#176675")
    abline(v = y$p*100, lty = 2, col = "#a34724")
    legend("topright", "Population percentage assumed for simulation", lty = 2, col = "#a34724", bty = "n", cex = .8)
  }, alt = "Saved one-sample Wilson interval; observed events, estimate and limits are supplied in the table.")
  overview_values <- reactive({
    x <- snapshot(); n <- analysable_n(); p <- plan()
    width <- 2*qnorm((1+x$confidence)/2)*sqrt(p$planning_p*(1-p$planning_p)/n)
    c("Current analyzable total" = n, "Approximate full width" = paste0(round(100*width, 1), " points"), "Recruitment total" = adjust_for_dropout(n, x$dropout))
  })
  output$overview_metrics <- renderUI(app_metrics(overview_values()))
  method_text <- reactive({
    x <- snapshot(); p <- plan(); z <- qnorm((1+x$confidence)/2)
    paste0("n = z² × p × (1 - p) / margin² = ", round(z, 4), "² × ", p$planning_p,
      " × ", 1-p$planning_p, " / ", p$half_width, "². Rounding upward gives ", p$n,
      " participants for the target width. The current analyzable count is ", analysable_n(),
      "; recruitment = ceiling(", analysable_n(), " / ", 1-x$dropout, ") = ", adjust_for_dropout(analysable_n(), x$dropout), ".")
  })
  output$worked_method <- renderUI(tags$div(class = "app-method", p(method_text())))
  report_paragraphs <- reactive({
    x <- snapshot()
    c(paste0(teaching_case(active_case())$title, ". Planning goal: ", if (x$goal == "fixed") "assess the available sample." else "estimate with a target interval width."),
      paste0("Anticipated percentage: ", format_percent(x$anticipated_p), "; percentage used for planning: ", format_percent(plan()$planning_p),
        ". Confidence: ", format_percent(x$confidence), "; target full width: ", 100*x$full_width, " percentage points."),
      method_text(),
      paste0("Approximate full width at the current sample: ", overview_values()[["Approximate full width"]], ". Realized confidence interval widths vary between samples."),
      if (isTRUE(input$simulate > 0)) {
        y <- study(); r <- y$result
        if (!identical(y$inputs, x) || !identical(y$case_id, active_case()))
          "The saved sample uses earlier settings or a different example and is omitted. Drawing a new sample will include its interval."
        else paste0("Simulated sample: ", r$events, " events among ", r$n, "; estimated percentage ", format_percent(r$estimate, 1),
          ", interval ", format_percent(r$lower, 1), " to ", format_percent(r$upper, 1), " at ", format_percent(y$confidence),
          " confidence. Assumed population percentage: ", format_percent(y$p, 1), "; random seed: ", y$inputs$seed, ".")
      },
      paste("Your explanation:", app_answer(input$justification)),
      "Your explanation is reproduced as entered and should be reviewed after changing the example or settings.",
      "Procedure: proportion_precision_plan(); simulated intervals: single_proportion_interval(), Wilson method. Independent binary outcomes; clustering and selection or missing-data bias require attention to the design and analysis.")
  })
  output$report_preview <- renderUI(app_report_body(report_paragraphs()))
  output$download_plan <- downloadHandler(filename = function() "proportion-precision-report.html", content = function(file) {
    writeLines(app_report_document("Estimate one proportion", "prevalence_precision", report_paragraphs()), file, useBytes = TRUE)
  })
  output$download_study <- downloadHandler(filename = function() "proportion_realised_interval.csv", content = function(file) {
    y <- study(); r <- y$result
    for (name in names(y$inputs)) r[[paste0("assumed_", name)]] <- y$inputs[[name]]
    r$generating_p <- y$p; r$method <- y$method; write.csv(r, file, row.names = FALSE)
  })
}
shinyApp(ui, server)

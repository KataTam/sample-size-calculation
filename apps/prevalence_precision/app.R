library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/teaching_cases.R")
source("../../R/activity_bridge.R")

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
        stop("Choose a precision or fixed-sample goal.", call. = FALSE)
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
    else if (name %in% c("anticipated_p", "confidence", "dropout")) updateSliderInput(session, name, value = x[[name]])
    else updateNumericInput(session, name, value = x[[name]])
  }
  invisible(x)
}

ui <- fluidPage(
  tags$head(tags$script(HTML(activity_bridge_script("prevalence_precision"))),
    tags$script(HTML(activity_download_script())),
    tags$style(HTML("body{font-size:17px;line-height:1.55}.well{background:#f4f7fa}.shiny-output-error-validation{color:#8a3410}"))),
  titlePanel("Estimate one proportion with useful precision", windowTitle = "Estimate one proportion"),
  p("Plan a prevalence survey or estimate a feasibility process such as retention. These are hypothetical independently sampled binary outcomes."),
  sidebarLayout(sidebarPanel(width = 4,
    selectInput("case_id", "Teaching case", c("Prevalence survey" = "prevalence", "Pilot retention" = "pilot_feasibility")),
    actionButton("load_case", "Load case assumptions"),
    selectInput("goal", "Planning goal", c("Plan for a target width" = "precision", "Assess an available sample" = "fixed")),
    sliderInput("anticipated_p", "Expected event rate (0.20 = 20%)", .001, .999, .20, step = .001),
    checkboxInput("unknown_p", "No previous estimate: use 50% for conservative planning", FALSE),
    helpText("This choice maximises the usual single-proportion sample requirement at fixed absolute margin of error. It does not supply an assumed treatment effect."),
    numericInput("full_width", "Target full confidence interval width (0.10 = 10 percentage points)", .10, min = .01, max = .50, step = .01),
    sliderInput("confidence", "Confidence level (0.95 = 95%)", .80, .99, .95, step = .01),
    conditionalPanel("input.goal == 'fixed'", numericInput("fixed_n", "Available analysable participants (one sample)", 246, min = 1, max = 1e7, step = 1)),
    sliderInput("dropout", "Expected loss or nonresponse rate (0.10 = 10%)", 0, .80, 0, step = .01),
    helpText("When retention is the outcome, retained and non-retained participants belong in its denominator. Apply extra loss adjustment only when the outcome status itself will be unavailable."),
    numericInput("seed", "Seed for the illustrative study", 20260942, min = 0, max = 2147483647, step = 1)),
  mainPanel(width = 8,
    h3(textOutput("case_title")), textOutput("case_prompt"), textOutput("bridge_status"),
    h3("Predict, explore and interpret"),
    p("Predict the recruitment change when the margin of error is halved. Explain why required precision should follow the intended clinical or planning decision."),
    tableOutput("plan_table"), textOutput("precision_text"), textOutput("approximation_note"),
    p(class = "caption", "Table. Planning prevalence, requested margin of error, approximate analysable counts and recruitment target."),
    plotOutput("sample_plot", height = "360px"),
    p(class = "caption", "Figure. Approximate prevalence sample size across assumed percentages and confidence-interval margins. The dot marks the current plan."),
    p("Both reference curves use 95% confidence and fixed absolute margins: ±5 versus ±2.5 percentage points. The dot and separate curve show your chosen confidence and width."),
    h3("One realised interval"),
    actionButton("simulate", "Draw one illustrative sample", class = "btn-primary"),
    p("The sample uses the expected event rate as the assumed true population rate. Choosing 50% for conservative planning changes the sample size calculation; it does not make the population rate known."),
    textOutput("saved_status"), tableOutput("study_table"),
    p(class = "caption", "Table. Event count, observed percentage and Wilson confidence limits from one illustrative sample, with the realised width and target assessment."),
    plotOutput("interval_plot", height = "220px"),
    p(class = "caption", "Figure. One illustrative Wilson confidence interval compared with the assumed population percentage and requested width."),
    p("Wilson intervals stay between 0% and 100%. Their realised width depends on the observed count; the planning approximation cannot guarantee that this interval meets the target. Recruitment inflation addresses expected numbers and does not correct selection or missing-data bias."),
    textAreaInput("justification", "Justify the margin, assumptions, sample availability and limits.", rows = 5, width = "100%"),
    activity_download_button("download_plan", "Download assumptions and explanation"),
    activity_download_button("download_study", "Download realised interval and assumptions"),
    tags$p(id = "download-status", role = "status", "aria-live" = "polite"),
    tags$details(tags$summary("Calculation and sources"),
      p("Approximate n = z² × p × (1 − p) / d², where d is the margin of error (half the interval width). Required n is rounded upward; recruitment is ceiling(n / (1 − loss)). All calculation functions and app code are included in the open source download."),
      tags$ul(tags$li(tags$a(href = "https://www.who.int/docs/default-source/ncds/ncd-surveillance/steps/steps-manual.pdf", "WHO STEPS manual: sample planning and the conservative p = 0.50 choice.")),
        tags$li(tags$a(href = "https://www.nihr.ac.uk/funding-programmes/research-for-patient-benefit/scope-eligibility/feasibility-studies", "NIHR: match feasibility work to the uncertainty needing resolution.")),
        tags$li(tags$a(href = "https://doi.org/10.1080/01621459.1927.10502953", "Wilson (1927): score confidence intervals.")))))))

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
    data.frame(Item = c("Event rate used for planning", "Target full interval width", "Target margin of error (half width)",
      "Approximate required analysable n", "Current analysable n", "Recruitment target", "Approximate full width at current n"),
      Value = c(format_percent(p$planning_p, 1), paste0(100*p$full_width, " percentage points"),
        paste0("±", 100*p$half_width, " percentage points"), p$n, n,
        adjust_for_dropout(n, x$dropout), paste0(round(100*anticipated_width, 1), " percentage points")))
  })
  output$precision_text <- renderText({
    p <- plan(); x <- snapshot()
    paste0("This is one sample, so n is a total count. The requested full width is ",
      100*p$full_width, " percentage points (margin ±", 100*p$half_width, "). ",
      if (x$goal == "fixed") "Available n is fixed; compare its precision with the target before justifying the plan."
      else "Halving the margin multiplies the unrounded normal-approximation requirement by four.")
  })
  output$approximation_note <- renderText({
    p <- plan(); n <- analysable_n()
    sparse <- min(n*p$planning_p, n*(1-p$planning_p)) < 10
    paste("The planned n is an approximation for independent sampling at a fixed absolute margin.",
      if (sparse) "Few expected events or non-events make this approximation less reliable. Rare outcomes require particular care and a justified binomial precision analysis."
      else "Check expected counts, sampling design and the assumptions for your actual study.",
      "Clustering, finite-population sampling and diagnostic-test error require additional methods.")
  })
  output$sample_plot <- renderPlot({
    x <- snapshot(); ps <- seq(.001, .999, length.out = 201)
    ns <- function(width, confidence) ceiling(qnorm((1+confidence)/2)^2 * ps*(1-ps)/(width/2)^2)
    y1 <- ns(.10, .95); y2 <- ns(.05, .95); current <- ns(x$full_width, x$confidence)
    plot(ps*100, y2, type = "l", lwd = 2, col = "#a34724", ylim = c(0,max(y1,y2,current)),
      xlab = "Assumed prevalence (%)", ylab = "Approximate analysable participants")
    lines(ps*100, y1, col = "#176675", lwd = 2, lty = 2)
    lines(ps*100, current, col = "#635493", lwd = 2, lty = 3)
    points(plan()$planning_p*100, plan()$n, pch = 19, col = "#635493")
    legend("topright", c("95% confidence; ±2.5 points", "95% confidence; ±5 points", "Your confidence and margin"),
      col = c("#a34724", "#176675", "#635493"), lty = 1:3, lwd = 2, cex = .78, bg = "white")
  }, alt = "Required analysable sample size versus assumed proportion. The largest requirement is near 50%; halving the margin approximately quadruples the requirement. Current values are in the table.")
  study <- eventReactive(input$simulate, {
    x <- snapshot(); y <- simulate_proportion_study(analysable_n(), x$anticipated_p, x$confidence, x$seed)
    y$inputs <- x; y
  }, ignoreInit = TRUE)
  output$saved_status <- renderText({
    y <- study()
    paste("Saved sample: n =", y$n, "and seed =", y$seed,
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
      xlab = "Event rate (%)", ylab = "", main = paste(round(100*y$confidence), "% Wilson interval"))
    segments(r$lower*100, 1, r$upper*100, 1, lwd = 3, col = "#176675")
    abline(v = y$p*100, lty = 2, col = "#a34724")
    legend("topright", "True rate assumed for simulation", lty = 2, col = "#a34724", bty = "n", cex = .8)
  }, alt = "Saved one-sample Wilson interval; observed events, estimate and limits are supplied in the table.")
  output$download_plan <- downloadHandler(filename = function() "proportion_precision_plan.txt", content = function(file) {
    writeLines(c("Single proportion: planning assumptions", capture.output(dput(snapshot())),
      "Approximate precision plan", capture.output(dput(plan())),
      paste("Current analysable n:", analysable_n()), "Learner explanation:", input$justification,
      "Planning approximation is not a guarantee for realised interval width or protection against sampling bias."), file)
  })
  output$download_study <- downloadHandler(filename = function() "proportion_realised_interval.csv", content = function(file) {
    y <- study(); r <- y$result
    for (name in names(y$inputs)) r[[paste0("assumed_", name)]] <- y$inputs[[name]]
    r$generating_p <- y$p; r$method <- y$method; write.csv(r, file, row.names = FALSE)
  })
}
shinyApp(ui, server)

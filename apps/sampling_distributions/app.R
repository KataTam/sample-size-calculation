library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/teaching_cases.R")
source("../../R/activity_bridge.R")
source("../../R/model_answers.R")
source("../../R/app_presentation.R")

sampling_defaults <- function() list(mu0 = 120, mu1 = 125, sigma = 15, n = 25,
  alpha = .05, sidedness = "greater")
validate_sampling_inputs <- function(values, complete = TRUE) {
  defaults <- sampling_defaults()
  if (!is.list(values) || is.null(names(values)) || anyDuplicated(names(values)) ||
      any(!names(values) %in% names(defaults))) stop("Unsupported sampling-distribution inputs.", call. = FALSE)
  x <- if (complete) utils::modifyList(defaults, values) else values
  for (name in names(x)) {
    value <- x[[name]]
    if (name == "sidedness") {
      if (!is.character(value) || length(value) != 1 || is.na(value) || !value %in% c("greater", "less", "two.sided"))
        stop("Invalid direction choice.", call. = FALSE)
    } else {
      check_scalar(value, name)
      limits <- switch(name, mu0 = c(-1e6, 1e6), mu1 = c(-1e6, 1e6),
        sigma = c(.1, 100), n = c(1, 1000), alpha = c(.001, .20))
      if (value < limits[1] || value > limits[2]) stop("Invalid ", name, " value.", call. = FALSE)
      if (name == "n" && value != floor(value)) stop("Sample size must be an integer.", call. = FALSE)
    }
  }
  if (complete && abs(x$mu1-x$mu0) > 30)
    stop("The alternative-minus-null difference must be from -30 to 30 for this activity.", call. = FALSE)
  x
}
apply_sampling_inputs <- function(session, values) {
  x <- validate_sampling_inputs(values)
  for (name in names(x)) {
    if (name == "sidedness") updateSelectInput(session, name, selected = x[[name]])
    else if (name %in% c("n", "sigma", "alpha")) updateSliderInput(session, name, value = x[[name]])
    else if (name == "mu0") updateNumericInput(session, name, value = x[[name]])
  }
  updateSliderInput(session, "effect", value = x$mu1-x$mu0)
  invisible(x)
}

ui <- fluidPage(
  tags$head(tags$script(HTML(activity_bridge_script("sampling_distributions"))), tags$script(HTML(activity_download_script()))),
  titlePanel("Error probabilities and power", windowTitle = "Error probabilities and power"),
  p("How does the same test behave under the null and a specified alternative? This reference model uses independent normal observations with a known population SD."),
  sidebarLayout(sidebarPanel(width = 4,
    app_input_group("Study assumptions", actionButton("load_case", "Restore the blood pressure example"),
      numericInput("mu0", "Mean under the null hypothesis (mmHg)", 120),
      sliderInput("effect", "True mean difference assumed for power (mmHg)", -30, 30, 5, step = .5),
      sliderInput("n", "Independent observations in the sample", 1, 1000, 25, step = 1),
      sliderInput("sigma", "Known population SD (mmHg)", .1, 100, 15, step = .1)),
    app_input_group("Statistical settings", percent_slider("alpha", "Type I error probability (%)", .001, .20, .05, step = .001),
      selectInput("sidedness", "Direction chosen before analysis", c("Greater than the null (one-sided)" = "greater", "Less than the null (one-sided)" = "less", "Either direction (two-sided)" = "two.sided")))),
  mainPanel(width = 8, textOutput("bridge_status"), tabsetPanel(id = "sampling_view",
    tabPanel("Overview", uiOutput("overview_metrics"),
      app_overview(tagList(plotOutput("distributions", height = "520px"), p(class = "caption", "Figure. Sample-mean distributions under the null and specified alternative. Shaded regions represent false positives, false negatives and detected differences.")), textOutput("explanation")),
      activity_details("Current numerical results", tableOutput("operating_table")),
      activity_details("Help with the shaded areas", p("Type I error probability describes false positives under the null. Type II error probability describes false negatives at the specified alternative. Power is the corresponding true-positive probability. The two panels refer to different population assumptions."))),
    tabPanel("Explore assumptions", h3("Power across sample sizes"),
      p("The curve varies sample size while keeping population means, SD, test direction and Type I error probability fixed."),
      plotOutput("power_curve", height = "350px"), p(class = "caption", "Figure. Power at the specified alternative; the point marks your current sample size."),
      p("A one-sided alternative in the opposite direction can have power below the Type I error probability. The direction should follow the prespecified scientific question.")),
    tabPanel("Report", activity_text_input("interpretation", "How did power change, and why?",
      "The model answer updates with the selected example and current calculation inputs.",
      "Your explanation should identify what changed, what stayed fixed and how the shaded areas changed.", rows = 5),
      uiOutput("report_preview"), activity_download_button("download_assumptions", "Save report (HTML)"),
      p(id = "download-status", role = "status", `aria-live` = "polite")),
    tabPanel("Methods and references", h3("Calculation with your current values"), uiOutput("worked_method"),
      p("The normal model gives exact error probabilities for independent normal observations with known population SD. The reasoning lab uses an estimated SD and a two-sample t test for continuous outcomes."),
      p(tags$a(href = "https://stat.ethz.ch/R-manual/R-devel/library/stats/html/Normal.html", target = "_blank", rel = "noopener", "R: normal distributions, quantiles and probabilities"), " · ",
        tags$a(href = "../book/power.html", target = "_blank", rel = "noopener", "Tutorial: power and error probabilities")),
      app_citation("Error probabilities and power", "sampling_distributions"))))))

server <- function(input, output, session) {
  safe <- function(expr) tryCatch(expr, error = function(e) validate(need(FALSE, conditionMessage(e))))
  bridge_status <- reactiveVal("")
  snapshot <- reactive(safe(validate_sampling_inputs(list(mu0 = input$mu0, mu1 = input$mu0+input$effect,
    sigma = input$sigma, n = input$n, alpha = input$alpha, sidedness = input$sidedness))))
  load_case <- function(id = "alpha_beta") {
    x <- teaching_case(id)
    if (x$app != "sampling_distributions") stop("This case uses a different activity.", call. = FALSE)
    apply_sampling_inputs(session, x$inputs[names(sampling_defaults())])
    bridge_status(paste("Loaded shared case:", x$title))
  }
  observeEvent(input$load_case, load_case())
  observeEvent(input$activity_request, tryCatch(load_case(input$activity_request$activity), error = function(e) bridge_status(conditionMessage(e))))
  observeEvent(input$state_request, tryCatch({
    state <- input$state_request$state
    if (!is.null(state$case_id)) {
      saved_case <- teaching_case(state$case_id)
      if (saved_case$app != "sampling_distributions") stop("This saved case uses a different activity.", call. = FALSE)
      state$case_id <- NULL
    }
    apply_sampling_inputs(session, state)
    bridge_status("Restored your previous sampling assumptions.") }, error = function(e) bridge_status(conditionMessage(e))))
  observeEvent(input$bridge_error, bridge_status(input$bridge_error))
  observe({ session$sendCustomMessage("sample-size-state", c(snapshot(), list(case_id = "alpha_beta"))) })
  operating <- reactive(safe(do.call(normal_sampling_operating_characteristics, snapshot())))
  model_answers <- reactive(list(interpretation = sampling_model_answer(operating())))
  activity_model_answers(session, model_answers, "interpretation")
  output$bridge_status <- renderText(bridge_status())
  output$distributions <- renderPlot(plot_sample_mean_distributions(operating()),
    alt = "Distributions of the sample mean under the null and specified alternative. Rejection tails under the null show Type I error probability; the non-rejection region under the alternative shows Type II error probability. Values and boundaries are listed below.")
  output$operating_table <- renderTable({
    x <- operating()
    data.frame(Quantity = c("Standard error of the mean", "Rejection boundary or boundaries", "Type I error probability under null", "Type II error probability at the specified alternative", "Power at the specified alternative"),
      Value = c(round(x$se, 4), paste(round(x$critical, 4), collapse = " and "),
        format_percent(x$type1, 2), format_percent(x$beta, 2), format_percent(x$power, 2)))
  })
  output$explanation <- renderText({
    x <- operating()
    reject <- switch(x$sidedness,
      greater = paste("above", round(x$upper, 3)), less = paste("below", round(x$lower, 3)),
      two.sided = paste("below", round(x$lower, 3), "or above", round(x$upper, 3)))
    paste0("The test rejects when the sample mean is ", reject, ". Under the specified alternative mean of ",
      x$mu1, ", ", format_percent(x$power, 1), " of repeated samples would reject. This power belongs to that assumed alternative.")
  })
  output$power_curve <- renderPlot({
    x <- snapshot(); ns <- unique(round(seq(1, max(100, min(1000, 2*x$n)), length.out = 100)))
    powers <- vapply(ns, function(n) { y <- x; y$n <- n
      do.call(normal_sampling_operating_characteristics, y)$power }, numeric(1))
    plot(ns, powers, type = "l", lwd = 2, col = "#176675", ylim = c(0,1), yaxt = "n",
      xlab = "Independent observations per sample", ylab = "Power at specified alternative (%)")
    axis(2, at = seq(0, 1, .2), labels = paste0(seq(0, 100, 20), "%"))
    abline(h = x$alpha, lty = 3, col = "#a34724")
    points(x$n, operating()$power, pch = 19)
  }, alt = "Power at the specified alternative across independent sample sizes, with current power given in the table and a line at Type I error probability.")
  output$overview_metrics <- renderUI({
    x <- operating()
    app_metrics(c("Type I error probability" = format_percent(x$type1, 2), "Type II error probability" = format_percent(x$beta, 2), "Power" = format_percent(x$power, 2)))
  })
  method_text <- reactive({
    x <- operating()
    paste0("SE = population SD / sqrt(n) = ", x$sigma, " / sqrt(", x$n, ") = ", round(x$se, 4),
      ". The ", switch(x$sidedness, greater = "one-sided (increase)", less = "one-sided (decrease)", two.sided = "two-sided"), " test uses rejection ", if (length(x$critical) == 1) "boundary " else "boundaries ",
      paste(round(x$critical, 4), collapse = " and "), ". The normal probability beyond the rejection boundary or boundaries at population mean ",
      x$mu1, " is ", format_percent(x$power, 2), ". Type II error probability = 1 - rejection probability = ", format_percent(x$beta, 2), ".")
  })
  output$worked_method <- renderUI(tags$div(class = "app-method", p(method_text())))
  report_paragraphs <- reactive({
    x <- operating()
    c(paste0("Known-SD one-sample normal model: null mean ", x$mu0, " mmHg; specified population mean ", x$mu1,
        " mmHg; population SD ", x$sigma, " mmHg; n = ", x$n, "."),
      paste0("Type I error probability: ", format_percent(x$type1, 2), "; rejection probability at the specified population mean: ", format_percent(x$power, 2), "."),
      method_text(), paste("Your explanation:", app_answer(input$interpretation)),
      "Procedure: normal_sampling_operating_characteristics(), using normal quantiles and tail probabilities. Assumptions: independent normal observations, known population SD and a prespecified test direction.")
  })
  output$report_preview <- renderUI(app_report_body(report_paragraphs()))
  output$download_assumptions <- downloadHandler(filename = function() "error-probabilities-report.html", content = function(file) {
    writeLines(app_report_document("Error probabilities and power", "sampling_distributions", report_paragraphs()), file, useBytes = TRUE)
  })

}
shinyApp(ui, server)

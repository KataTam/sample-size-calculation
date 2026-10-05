library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/teaching_cases.R")
source("../../R/activity_bridge.R")

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
  tags$head(tags$script(HTML(activity_bridge_script("sampling_distributions"))),
    tags$script(HTML(activity_download_script())),
    tags$style(HTML("body{font-size:17px;line-height:1.55}.well{background:#f4f7fa}.shiny-output-error-validation{color:#8a3410}"))),
  titlePanel("Type I error rate, Type II error rate and power on a sampling distribution", windowTitle = "Type I error rate, Type II error rate and power"),
  p("Definitions: ", tags$a(href = "../book/Sample_size_open_module.html#alpha", target = "_blank", rel = "noopener", "alpha"), ", ",
    tags$a(href = "../book/Sample_size_open_module.html#beta", target = "_blank", rel = "noopener", "beta"), " and ",
    tags$a(href = "../book/Sample_size_open_module.html#statistical-power", target = "_blank", rel = "noopener", "power"), "."),
  p("Explore a one-sample mean with independent normal observations and a known population standard deviation. This simplified reference model makes the error regions visible."),
  sidebarLayout(sidebarPanel(width = 4,
    actionButton("load_case", "Restore the blood pressure example"),
    numericInput("mu0", "Mean under the null hypothesis (mmHg)", 120),
    sliderInput("effect", "True mean difference assumed for power (mmHg)", -30, 30, 5, step = .5),
    sliderInput("n", "Independent observations in the sample", 1, 1000, 25, step = 1),
    sliderInput("sigma", "Known population standard deviation (mmHg)", .1, 100, 15, step = .1),
    sliderInput("alpha", "Type I error rate (0.05 = 5%)", .001, .20, .05, step = .001),
    selectInput("sidedness", "Rejection direction, chosen before analysis",
      c("Mean greater than the null (one-sided)" = "greater", "Mean less than the null (one-sided)" = "less", "Either direction (two-sided)" = "two.sided"))),
  mainPanel(width = 8,
    h3("Blood pressure: sample means under two assumptions"),
    textOutput("bridge_status"),
    p("Predict what happens when n doubles, the alternative moves towards the null, or the SD increases. Keep one control fixed while exploring another."),
    plotOutput("distributions", height = "470px"),
    p(class = "caption", "Figure. Sampling distributions under the null and specified alternative, with Type I error rate and Type II error rate shaded."),
    tableOutput("operating_table"),
    p(class = "caption", "Table. Standard error, rejection boundaries and error probabilities under the selected design."),
    textOutput("explanation"),
    p("Type I error rate is the rejection probability under the null. Type II error rate is the non-rejection probability under the specified alternative; power is 1 − Type II error rate. The shaded areas refer to different assumed populations, so their overlap on the page is not an extra probability."),
    p("The vertical boundaries are fixed by the null distribution and chosen Type I error rate. Greater sample size narrows the distribution of the mean; it does not shrink the population SD shown in the controls."),
    h3("Power across sample sizes"), plotOutput("power_curve", height = "280px"),
    p(class = "caption", "Figure. Power at the specified alternative across independent sample sizes. The point marks the current sample; the reference line marks Type I error rate."),
    p("A one-sided alternative in the wrong direction can have power below Type I error rate. Direction should follow the prespecified scientific question. A realised non-significant result does not establish that the null is true."),
    textAreaInput("interpretation", "Explain the two shaded regions and one design choice.", rows = 4, width = "100%"),
    activity_download_button("download_assumptions", "Download assumptions and explanation"),
    tags$p(id = "download-status", role = "status", "aria-live" = "polite"),
    tags$details(tags$summary("Reference calculation and scope"),
      p("SE = sigma / sqrt(n). For a greater-than test, c = mu0 + qnorm(1 − Type I error rate) × SE, and power = P(mean > c | mu1). Two-sided power counts both rejection tails. The shared open R functions calculate these probabilities directly; no lookup table is needed."),
      p("These curves are exact under independent normal sampling with known SD. The main reasoning lab estimates SD and uses a two-sample t test; its power calculation and intervals use that different model."),
      tags$a(href = "https://stat.ethz.ch/R-manual/R-devel/library/stats/html/Normal.html", "R documentation: the normal distribution, quantiles and probabilities.")))))

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
  output$bridge_status <- renderText(bridge_status())
  output$distributions <- renderPlot(plot_sample_mean_distributions(operating()),
    alt = "Distributions of the sample mean under the null and specified alternative. Rejection tails under the null show Type I error rate; the non-rejection region under the alternative shows Type II error rate. Values and boundaries are listed below.")
  output$operating_table <- renderTable({
    x <- operating()
    data.frame(Quantity = c("Standard error of the mean", "Rejection boundary or boundaries", "Type I error rate under null", "Type II error rate at the specified alternative", "Power at the specified alternative"),
      Value = c(round(x$se, 4), paste(round(x$critical, 4), collapse = " and "),
        format_percent(x$type1, 2), format_percent(x$beta, 2), format_percent(x$power, 2)))
  })
  output$explanation <- renderText({
    x <- operating()
    reject <- switch(x$sidedness,
      greater = paste("above", round(x$upper, 3)), less = paste("below", round(x$lower, 3)),
      two.sided = paste("below", round(x$lower, 3), "or above", round(x$upper, 3)))
    paste0("The test rejects when the sample mean is ", reject, ". Under the specified alternative mean of ",
      x$mu1, ", ", format_percent(x$power, 1), " of repeated samples would reject. This power belongs to that assumed alternative and is not the probability that a hypothesis is true.")
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
  }, alt = "Power at the specified alternative across independent sample sizes, with current power given in the table and a line at Type I error rate.")
  output$download_assumptions <- downloadHandler(filename = function() "sampling_distribution_assumptions.txt", content = function(file) {
    writeLines(c("Known-SD one-sample normal reference model", capture.output(dput(snapshot())),
      "Operating characteristics", capture.output(dput(operating())), "Learner explanation:", input$interpretation,
      "Assumptions: independent normal observations; population SD known; prespecified rejection direction."), file)
  })
}
shinyApp(ui, server)

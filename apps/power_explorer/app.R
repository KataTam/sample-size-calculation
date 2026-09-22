library(shiny)
source("../../R/sample_size_functions.R")

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
  tags$head(tags$script(HTML(download_script))),
  tags$p(id = "download-status", role = "status", `aria-live` = "polite"),
  tags$head(tags$style(HTML("body{font-size:17px;line-height:1.55}.well{background:#f4f7fa}table{font-size:15px}.shiny-html-output{overflow-x:auto}.shiny-output-error-validation{color:#8a3410}"))),
  titlePanel("Sample size reasoning lab"),
  p("Choose a goal, predict a consequence, explore one study and many studies, then justify your design. All cases are hypothetical. No coding is required."),
  sidebarLayout(sidebarPanel(width = 4,
    selectInput("outcome", "Outcome", c("Continuous improvement score" = "means", "Binary pain relief" = "proportions")),
    selectInput("goal", "Planning goal", c("Test a difference from zero" = "testing", "Estimate with a target interval width" = "precision", "Assess a fixed sample size" = "fixed")),
    p("Two independent groups, equal allocation. Differences are treatment minus control; positive values mean benefit in these cases."),
    conditionalPanel("input.outcome == 'means'",
      numericInput("plan_delta", "Difference assumed for planning (score units)", 3, step = .5),
      numericInput("plan_sd", "Planning standard deviation", 5, min = .1),
      numericInput("threshold_m", "Clinically important benefit (score units)", 2, min = .1),
      numericInput("width_m", "Target FULL interval width (score units)", 4, min = .1)),
    conditionalPanel("input.outcome == 'proportions'",
      sliderInput("plan_p0", "Planning relief probability: control", .01, .99, .3, step = .01),
      sliderInput("plan_p1", "Planning relief probability: treatment", .01, .99, .6, step = .01),
      numericInput("threshold_p", "Clinically important absolute benefit (proportion units)", .3, min = .001, max = 1, step = .01),
      numericInput("width_p", "Target FULL interval width (proportion units)", .2, min = .001, max = 2, step = .01)),
    helpText("Expected, planning and clinically important effects are separate judgements. Record sources and uncertainty in your case worksheet."),
    sliderInput("alpha", "Two-sided alpha (CI confidence = 1 - alpha)", .001, .1, .05, step = .001),
    sliderInput("target_power", "Power target (reference line for fixed or precision goals)", .5, .99, .8, step = .01),
    conditionalPanel("input.goal == 'fixed'", numericInput("fixed_n", "Analysable participants PER GROUP", 60, min = 2, max = 100000, step = 1)),
    sliderInput("dropout", "Expected dropout fraction in EACH group", 0, .5, .1, step = .01),
    numericInput("recruit_cap", "Recruitment limit: TOTAL across both groups", 200, min = 4, max = 200000, step = 2),
    helpText("The curve marks the expected analysable limit after losses; this is not a guaranteed final count."),
    h4("Reality may differ from the plan"),
    selectInput("reality", "Data-generating scenario", c("Same as planning assumptions" = "same", "No true treatment effect" = "null", "Custom effect or variability" = "custom")),
    conditionalPanel("input.reality == 'custom' && input.outcome == 'means'",
      numericInput("true_delta", "Generating difference (zero or negative allowed)", 1, step = .5),
      numericInput("true_sd", "Generating standard deviation", 7, min = .1)),
    conditionalPanel("input.reality == 'custom' && input.outcome == 'proportions'",
      sliderInput("true_p0", "Generating probability: control", .01, .99, .3, step = .01),
      sliderInput("true_p1", "Generating probability: treatment", .01, .99, .4, step = .01)),
    numericInput("seed", "Random seed", 20260914, min = 0, max = 2147483647, step = 1),
    numericInput("B", "Independent study replications B", 1000, min = 100, max = 10000, step = 100),
    helpText("More participants change study performance. More replications improve simulation precision. Same inputs and seed reproduce results.")),
  mainPanel(width = 8, tabsetPanel(id = "stage",
    tabPanel("Explore assumptions", h3("Your planned design"), tableOutput("planning"),
      p("Predict a change before moving a control. Compare testing, precision and fixed-resource goals."),
      plotOutput("planning_plot", height = "430px"), textOutput("planning_text"),
      h4("Compare smaller effects"),
      p("Curves compare the planning difference with two smaller differences. Predict which curve will reach the target first. Clinical importance is a separate judgement."),
      plotOutput("comparison_plot", height = "360px"), tableOutput("comparison_table"),
      h4("Power across effects at the planned sample size"),
      plotOutput("effect_plot", height = "320px"),
      p("The target-power crossing is not a hard detection boundary. This explores hypothetical effects, not observed post hoc power."),
      h4("Sensitivity at this planned sample size"), tableOutput("sensitivity"),
      p("Changing the generating scenario keeps the planned sample size fixed. Simulations use analysable counts; dropout only changes recruitment targets and does not remove missing-data bias."),
      h4("Analysis assumptions"), textOutput("method"),
      p("Normal outcomes use a pooled-variance t test and interval. Binary outcomes use a pooled score test without continuity correction and a Newcombe-Wilson difference interval. Binary analytical power and precision are approximations; check finite-sample behaviour with simulations.")),
    tabPanel("One study", h3("One realised study"), actionButton("run_one", "Simulate one study", class = "btn-primary"),
      p("Change the seed for another realisation. High planned power does not guarantee a conclusive result."),
      textOutput("one_status"), tableOutput("one_result"), textOutput("one_interpretation"),
      plotOutput("one_plot", height = "300px"), h4("First 12 participant records"), tableOutput("one_data"),
      downloadButton("download_one", "Download study and assumptions")),
    tabPanel("Many studies", h3("Repeated independent studies"), actionButton("run_many", "Simulate many studies", class = "btn-primary"),
      textOutput("many_status"), tableOutput("many_summary"), textOutput("many_text"),
      p("Monte Carlo intervals describe finite-replication uncertainty, not uncertainty in clinical assumptions. Coverage evaluates the interval procedure; rejection evaluates the stated test."),
      plotOutput("many_plot", height = "480px"),
      p("First 30 intervals only. Filled dots: reject zero; open dots: do not reject. Line styles distinguish zero, the clinical threshold and generating truth."),
      plotOutput("distribution", height = "300px"),
      h4("How often is the p-value below alpha?"),
      plotOutput("p_values", height = "300px"),
      p("The dashed line uses the alpha saved with this run. Below it, the fraction estimates power under an alternative or Type I error under the null."),
      downloadButton("download_many", "Download replications and assumptions")),
    tabPanel("Justify and communicate", h3("Explain your decision"),
      textAreaInput("justification", "State the goal, sources, clinical threshold, sensitivity, feasibility and limits of the intended conclusion.", rows = 8, width = "100%"),
      p("Use the case template. Increasing the assumed effect simply to reduce recruitment is not a justification."),
      downloadButton("download_plan", "Download plan and explanation"),
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
  planned <- reactive({
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
  snapshot <- reactive(list(plan = planned(), generating = generating(), goal = input$goal,
                            target_power = input$target_power, dropout = input$dropout,
                            recruitment_cap = input$recruit_cap))
  one <- eventReactive(input$run_one, {
    meta <- snapshot(); x <- simulate_one_study(meta$generating); x$meta <- meta; x
  }, ignoreInit = TRUE)
  many <- eventReactive(input$run_many, {
    meta <- snapshot()
    withProgress(message = "Simulating independent studies", value = .2, {
      x <- simulate_trials(meta$generating); incProgress(.8); x$meta <- meta; x
    })
  }, ignoreInit = TRUE)
  status <- function(saved, label) paste0(label, ": n = ", saved$spec$n,
    " per group; generating difference = ", signif(true_difference(saved$spec), 4), "; seed = ", saved$spec$seed,
    ". ", if (!identical(saved$meta, snapshot())) "Inputs changed. These are saved results; run again to update." else "Results match current inputs.")
  output$planning <- renderTable({
    x <- planned(); recruit <- adjust_for_dropout(x$n, input$dropout)
    data.frame(Item = c("Analysable per group", "Analysable total", "Recruit per group", "Recruitment total", "Planning power", "Anticipated FULL interval width"),
      Value = c(x$n, 2*x$n, recruit, 2*recruit, format_percent(spec_power(x), 1), signif(anticipated_width(x), 4)))
  })
  output$method <- renderText(method_label(planned()$outcome))
  output$planning_text <- renderText(paste(if (planned()$outcome == "means")
    "The width curve is the expected full t-interval width under normal equal-variance sampling." else
    "The width curve is a plug-in Newcombe-Wilson width at planning probabilities, not an exact mean width.",
    "Reaching the target on this curve does not guarantee every interval meets it. Check the fraction meeting the width target under Many studies."))
  output$planning_plot <- renderPlot({
    x <- planned(); ns <- unique(round(seq(2, min(100000, max(40, 2*x$n)), length.out = 70)))
    par(mfrow = c(2, 1), mar = c(4, 4, 2, 1))
    plot(ns, vapply(ns, function(n) spec_power(x, n), numeric(1)), type = "l", lwd = 2,
      ylim = c(0, 1), xlab = "Analysable participants per group", ylab = "Power")
    abline(h = input$target_power, lty = 2); points(x$n, spec_power(x), pch = 19)
    plot(ns, vapply(ns, function(n) anticipated_width(x, n), numeric(1)), type = "l", lwd = 2,
      xlab = "Analysable participants per group", ylab = "Full CI width")
    abline(h = x$width_target, lty = 2); points(x$n, anticipated_width(x), pch = 19)
  }, alt = "Power and anticipated full confidence interval width versus participants per group. Current values are provided in the design table.")
  comparison <- reactive({
    x <- planned()
    cap <- input$recruit_cap
    if (is.null(cap)) cap <- 200
    safe(check_integer(cap, "Total recruitment limit", 4, 200000))
    cap_n <- floor(floor(cap / 2) * (1 - input$dropout))
    validate(need(cap_n >= 2, "The expected analysable limit must be at least two per group."))
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
    ns <- unique(round(seq(2, min(100000, max(40, 2*x$n, z$cap_n)), length.out = 80)))
    colours <- c("#176675", "#a04a24", "#635493")
    plot(range(ns), c(0, 1), type = "n", xlab = "Analysable patients per group", ylab = "Power")
    for (i in seq_along(z$scenarios)) lines(ns,
      vapply(ns, function(n) spec_power(z$scenarios[[i]], n), numeric(1)),
      lwd = 2, col = colours[i], lty = i)
    abline(h = input$target_power, lty = 2, col = "#555555")
    abline(v = z$cap_n, lty = 3, col = "#555555")
    legend("bottomright", legend = paste("Difference", signif(z$effects, 3)),
      col = colours, lty = 1:3, lwd = 2, bty = "n")
  }, alt = "Power curves compare half, two-thirds and the full planning difference. The table gives power at the expected analysable recruitment limit.")
  output$comparison_table <- renderTable({
    z <- comparison()
    data.frame(Difference = z$effects, Expected_analysable_per_group = z$cap_n,
      Power_at_limit = vapply(z$scenarios, function(x) spec_power(x, z$cap_n), numeric(1)))
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
    plot(effects, powers, type = "l", lwd = 2, col = "#176675", ylim = c(0,1),
      xlab = if (x$outcome == "means") "Treatment minus control (score units)" else "Treatment minus control (proportion units)",
      ylab = "Power", main = paste(x$n, "analysable patients per group"))
    abline(h = input$target_power, lty = 2); abline(v = 0, lty = 3)
    points(d, spec_power(x), pch = 19)
  }, alt = "Two-sided power across hypothetical signed differences at fixed planned sample size. Negative differences mean harm; rejection in either direction is counted.")
  output$sensitivity <- renderTable({
    p <- planned(); g <- generating(); null <- p; null$delta <- 0; null$p_treatment <- null$p_control
    xs <- list(p, g, null)
    data.frame(Scenario = c("Plan", "Current generating scenario", "Null effect"), Difference = vapply(xs, true_difference, numeric(1)),
      Power = vapply(xs, spec_power, numeric(1)), Full_width = vapply(xs, anticipated_width, numeric(1)))
  }, digits = 3)
  output$one_status <- renderText({ req(input$run_one > 0); status(one(), "Saved single study") })
  output$one_result <- renderTable({
    x <- one()$result
    data.frame(Measure = c("Effect estimate", "CI lower limit", "CI upper limit", "Two-sided p-value",
      "FULL interval width", "Reject zero", "Interval contains generating truth", "Width target met"),
      Value = c(format(round(unlist(x[1:5]), 4), nsmall = 4),
                ifelse(unlist(x[6:8]), "Yes", "No")), row.names = NULL)
  })
  output$one_interpretation <- renderText(interval_interpretation(one()$result, one()$spec))
  output$one_plot <- renderPlot(plot_trial_intervals(one()$result, one()$spec), alt = "One study estimate and interval; values and interpretation are stated above.")
  output$one_data <- renderTable(head(one()$data, 12))
  output$many_status <- renderText({ req(input$run_many > 0); paste(status(many(), "Saved batch"), "B =", many()$spec$B) })
  output$many_summary <- renderTable(simulation_summary(many()), digits = 4)
  output$many_text <- renderText({
    x <- many(); r <- x$results
    paste0(if (abs(true_difference(x$spec)) < 1e-12) "Null scenario: rejection rate estimates Type I error. " else "Effect scenario: rejection rate estimates power. ",
      "Mean full interval width = ", signif(mean(r$width), 4), "; mean estimate = ", signif(mean(r$estimate), 4),
      "; truth = ", signif(true_difference(x$spec), 4), ". The separate single-study draw is not the first row of this batch.")
  })
  output$many_plot <- renderPlot(plot_trial_intervals(many()$results, many()$spec), alt = "First 30 study intervals; summary rates and downloadable data provide a text alternative.")
  output$distribution <- renderPlot({
    x <- many(); hist(x$results$estimate, breaks = 25, col = "#dbeafe", border = "white", main = "Sampling distribution of effects", xlab = "Treatment minus control")
    abline(v = true_difference(x$spec), lty = 3, lwd = 2)
  }, alt = "Effect estimate histogram; mean estimate and generating truth are provided above.")
  output$p_values <- renderPlot({
    x <- many()
    hist(x$results$p_value, breaks = seq(0,1,.025), col = "#d2e6e9", border = "white",
      xlab = "p-value", ylab = "Number of studies", main = "Saved repeated-study p-values")
    abline(v = x$spec$alpha, lty = 2, lwd = 2, col = "#923d20")
  }, alt = "Histogram of saved simulation p-values. The rejection rate and Monte Carlo interval are reported in the summary table.")
  export_rows <- function(rows, meta) {
    for (k in names(meta$plan)) rows[[paste0("plan_", k)]] <- meta$plan[[k]]
    for (k in names(meta$generating)) rows[[paste0("generating_", k)]] <- meta$generating[[k]]
    rows$planning_goal <- meta$goal; rows$target_power <- meta$target_power
    rows$dropout_fraction <- meta$dropout
    if (!is.null(meta$recruitment_cap)) rows$recruitment_cap <- meta$recruitment_cap
    rows$method <- method_label(meta$plan$outcome); rows
  }
  output$download_one <- downloadHandler(filename = function() "single_study.csv", content = function(file) {
    x <- one(); write.csv(export_rows(x$data, x$meta), file, row.names = FALSE)
  })
  output$download_many <- downloadHandler(filename = function() "study_replications.csv", content = function(file) {
    x <- many(); write.csv(export_rows(x$results, x$meta), file, row.names = FALSE)
  })
  output$download_plan <- downloadHandler(filename = function() "sample_size_justification.txt", content = function(file) {
    x <- snapshot(); writeLines(c("Current sample size justification", capture.output(str(x)), method_label(x$plan$outcome), "Learner explanation:", input$justification), file)
  })
  output$download_code <- downloadHandler(filename = function() "reproduce_studies.R", content = function(file) {
    x <- snapshot(); writeLines(c('# Run from the repository root.', 'source("R/sample_size_functions.R")',
      'plan <-', capture.output(dput(x$plan)), 'generating <-', capture.output(dput(x$generating)),
      'one <- simulate_one_study(generating)', 'many <- simulate_trials(generating)', 'one$result',
      'simulation_summary(many)', 'plot_trial_intervals(many$results, generating)'), file)
  })
}
shinyApp(ui, server)

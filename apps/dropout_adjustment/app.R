library(shiny)
source("../../R/sample_size_functions.R")
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
    status.textContent = 'The calculation must be valid before its report can be downloaded.';
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
  tags$head(tags$script(HTML(download_script)), tags$script(HTML(activity_bridge_script("dropout_adjustment"))),
    tags$style(HTML(".advanced-options>summary{background:#e9def5;padding:10px;border-radius:5px}details{margin:1em 0}summary{cursor:pointer;font-weight:600}table{width:100%}caption{color:#444}.recruitment-result{background:#dcecfb;padding:14px;border-radius:6px}.recruitment-result p{margin:0}.shiny-download-link{margin:12px 0}"))),
  titlePanel("Recruitment adjustment", windowTitle = "Recruitment adjustment"),
  sidebarLayout(
    sidebarPanel(
      numericInput("n", "Starting participants needed for analysis, per group", 100, min = 1, step = 1),
      percent_slider("dropout", "Expected loss to follow-up (%)", 0, .50, .10, step = .01),
      checkboxInput("different_losses", "Use different expected losses for the two groups", FALSE),
      conditionalPanel("input.different_losses",
        helpText("The first loss percentage applies to the novel-treatment group."),
        percent_slider("loss_standard", "Expected loss: standard-treatment group (%)", 0, .50, .10, step = .01)),
      tags$details(class = "advanced-options", tags$summary("Allowing for treatment switching"),
        p("Approximation for complete switching between two treatments with little change in outcome variance."),
        checkboxInput("switching", "Explore treatment switching", FALSE),
        conditionalPanel("input.switching",
          radioButtons("starting_assumption", "What does the starting sample size assume?",
            c("Full adherence to assigned treatment" = "full", "Expected switching is already included" = "included")),
          conditionalPanel("input.starting_assumption == 'full'",
            percent_slider("switch_novel", "Novel to standard treatment (%)", 0, .50, .10, step = .01),
            percent_slider("switch_standard", "Standard to novel treatment (%)", 0, .50, .05, step = .01)),
          helpText("An additional switching adjustment applies only to a starting calculation that assumes full adherence.")),
        p("For a binary outcome, the ", tags$a(href = "../two_proportions/", "two-proportion app"),
          " can recalculate sample size using revised event percentages. In the tutorial example these become 57% and 31.5%."),
        p(tags$a(href = "../book/feasibility.html#treatment-switching", "Explanation and assumptions")))
    ),
    mainPanel(
      p("You can explore how expected losses and treatment switching affect recruitment. The app keeps recruitment equal in the two randomized groups. With different expected losses, it uses the larger requirement for both groups so each can meet the analyzable requirement in expectation."),
      p("Actual retention varies. Prevention, appropriate analysis and sensitivity analyses remain important when outcomes are missing."),
      h3("Recruitment target"), uiOutput("result"), uiOutput("stages"), uiOutput("group_counts"),
      h3("Expected losses and recruitment"), plotOutput("dropout_plot", height = "320px"),
      textOutput("plot_caption", container = function(...) p(class = "caption", ...)),
      tags$details(tags$summary("Activity: Treatment changes and missing outcomes"),
        p("Suppose some participants switch treatments, while others miss their final assessment. How does each change affect your recruitment requirement? Which assumptions would you need to justify?"),
        textAreaInput("reasoning", "Your prediction and justification", rows = 4, width = "100%"),
        tags$details(tags$summary("Model answer"),
          p("Switching can reduce the difference between randomized groups and increase the sample needed for the planned power. Missing assessments reduce available outcomes. Evidence is needed for switching in each direction, its effect on outcomes, and follow-up completeness in each group. The switching adjustment should be applied once. Equal recruitment with unequal losses uses the larger group requirement.")),
        helpText("Your answer is included in the downloadable report. It is kept only in this open session.")),
      tags$details(tags$summary("Methods and report"),
        p("Starting n is multiplied by 1/(1 - a - b)^2 when the switching option applies. Here a and b are the fractions switching in the two directions. The result is divided by each group's expected retained fraction. The larger requirement is rounded upward once per group and doubled for equal recruitment."),
        p("The approximation assumes complete switching, comparable outcome distributions among recipients of the same treatment, and little change in variance. Partial, delayed, or outcome-related switching needs a more detailed model. This app calculates expected counts without generating patient outcomes."),
        p("References: ", tags$a(href = "https://doi.org/10.1093/epirev/24.1.39", "Wittes (2002)"), "; ",
          tags$a(href = "https://doi.org/10.1111/j.1541-0420.2008.01114.x", "Shardell and El-Kamary (2009)"), "; ",
          tags$a(href = "https://www.fda.gov/media/148473/download", "ICH E9(R1)"), "."),
        downloadButton("report", "Download calculation report"),
        p(id = "download-status", role = "status", `aria-live` = "polite")),
      tags$details(tags$summary("Explore a complete-outcome scenario in the reasoning lab"),
        uiOutput("lab_scope"),
        selectInput("lab_outcome", "Outcome for the two-group design", c("Continuous" = "means", "Binary" = "proportions")),
        conditionalPanel("input.lab_outcome == 'means'",
          numericInput("lab_delta", "Target difference (outcome units)", 3), numericInput("lab_sd", "Standard deviation used for planning", 5, min = .1)),
        conditionalPanel("input.lab_outcome == 'proportions'",
          percent_slider("lab_p0", "Standard treatment: event probability used for planning (%)", .01, .99, .3, step = .01),
          percent_slider("lab_p1", "Novel treatment: event probability used for planning (%)", .01, .99, .6, step = .01)),
        uiOutput("lab_link"))
    )
  )
)

server <- function(input, output, session) {
  valid_n <- reactive({
    validate(need(length(input$n) == 1 && is.finite(input$n) && input$n == floor(input$n) && input$n >= 1 && input$n <= 1e7,
      "Use a whole number from 1 to 10,000,000 per group.")); input$n
  })
  switching_applied <- reactive(isTRUE(input$switching) && identical(input$starting_assumption, "full"))
  plan <- reactive({
    req(input$dropout)
    a <- if (switching_applied()) input$switch_novel else 0
    b <- if (switching_applied()) input$switch_standard else 0
    loss0 <- if (isTRUE(input$different_losses)) input$loss_standard else input$dropout
    tryCatch(recruitment_plan(valid_n(), input$dropout, loss0, a, b),
      error = function(e) validate(need(FALSE, conditionMessage(e))))
  })
  make_table <- function(caption, headings, rows) {
    tags$table(class = "table table-striped", tags$caption(caption),
      tags$thead(tags$tr(lapply(headings, function(x) tags$th(scope = "col", x)))),
      tags$tbody(lapply(rows, function(row) tags$tr(lapply(row, tags$td)))))
  }
  output$result <- renderUI({
    x <- plan()
    tagList(div(class = "recruitment-result", p(paste0(x$per_group, " participants per group; ", x$total, " in total."))),
      if (switching_applied()) p(paste0("Approximate switching multiplier: ", round(x$multiplier, 3), ". The result depends on the simplified switching assumptions.")),
      if (isTRUE(input$switching) && identical(input$starting_assumption, "included"))
        p("The starting sample already accounts for switching. No additional switching multiplier is applied."))
  })
  output$stages <- renderUI({
    x <- plan()
    make_table("Table. Calculation stages; intermediate counts remain unrounded.", c("Stage", "Participants per group"),
      list(c("Starting requirement", x$starting), c("After switching allowance", sprintf("%.2f", x$after_switching)),
        c("After loss allowance: larger group requirement", sprintf("%.2f", max(x$unrounded_recruitment))),
        c("Recruitment after upward rounding", x$per_group)))
  })
  output$group_counts <- renderUI({
    x <- plan()
    make_table("Table. Expected outcomes retained with equal recruitment.",
      c("Randomized group", "Expected loss", "Recruitment", "Expected outcomes available"),
      lapply(seq_along(x$losses), function(i) c(names(x$losses)[i], format_percent(x$losses[i]), x$per_group, round(x$expected_retained[i], 1))))
  })
  output$dropout_plot <- renderPlot({
    x <- plan(); losses <- seq(0, .50, by = .01); unequal <- isTRUE(input$different_losses)
    target <- function(r) ceiling(x$after_switching / (1-r))
    targets <- target(losses)
    if (unequal) targets <- pmax(targets, target(x$losses[2]))
    par(mar = c(4.5, 4.5, 1, 1), cex.axis = 1.1, cex.lab = 1.1)
    plot(100*losses, targets, type = "l", lwd = 2, col = "#245e90",
      xlab = if (unequal) "Expected loss in novel group (%)" else "Expected loss in each group (%)", ylab = "Equal recruitment per group")
    if (unequal) abline(h = target(x$losses[2]), lty = 2, col = "#704a93")
    points(100*input$dropout, x$per_group, pch = 19, cex = 1.3, col = "#245e90")
  }, alt = "Recruitment increases with expected losses. The current target is also given in the calculation tables.")
  output$plot_caption <- renderText({
    plan()
    if (isTRUE(input$different_losses)) paste0("Figure. Equal recruitment per group as loss in the novel group varies; standard-group loss remains ",
      format_percent(input$loss_standard), ". The dashed line shows its minimum requirement. The dot marks the current plan.")
    else "Figure. Equal recruitment per group across shared loss percentages, holding the starting sample and switching assumptions fixed. The dot marks the current plan."
  })
  report_text <- reactive({
    x <- plan()
    paste(c("RECRUITMENT ADJUSTMENT REPORT", paste("Generated:", Sys.Date()),
      paste("Starting requirement per group:", x$starting), paste("Switching option enabled:", isTRUE(input$switching)),
      paste("Starting assumption:", if (isTRUE(input$switching)) input$starting_assumption else "unchanged; switching option off"),
      paste("Applied switching, novel to standard:", if (switching_applied()) format_percent(input$switch_novel) else "0%"),
      paste("Applied switching, standard to novel:", if (switching_applied()) format_percent(input$switch_standard) else "0%"),
      paste("Switching multiplier:", format(x$multiplier, digits = 15)),
      paste("After switching (unrounded):", format(x$after_switching, digits = 15)),
      paste("Expected losses, novel / standard:", paste(format_percent(x$losses), collapse = " / ")),
      paste("Recruitment before rounding, novel / standard:", paste(format(x$unrounded_recruitment, digits = 15), collapse = " / ")),
      paste("Equal recruitment per group:", x$per_group), paste("Recruitment total:", x$total),
      paste("Expected outcomes available, novel / standard:", paste(round(x$expected_retained, 2), collapse = " / ")),
      "Method: n / (1-a-b)^2 when applicable, then divide by each retained fraction; round up the larger requirement once and recruit that count in each group.",
      "Assumptions: complete switching; comparable outcome distributions among recipients of the same treatment; little change in variance. Actual retention varies. Missing-data bias requires prevention and appropriate analysis.",
      "Binary outcomes: recalculate with revised event probabilities in the two-proportion app. The switching multiplier is an approximation.",
      "Procedure: recruitment_plan() in R/sample_size_functions.R; apps/dropout_adjustment/app.R.",
      paste("Software:", R.version.string, "; Shiny", as.character(packageVersion("shiny"))),
      "Source and version history: https://github.com/KataTam/sample-size-calculation/commits/main/apps/dropout_adjustment/app.R",
      "Teaching materials: CC BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/ ; software: MIT https://opensource.org/license/mit",
      "References: https://doi.org/10.1093/epirev/24.1.39 ; https://doi.org/10.1111/j.1541-0420.2008.01114.x ; https://www.fda.gov/media/148473/download",
      "", "PREDICTION AND JUSTIFICATION", if (is.null(input$reasoning)) "" else input$reasoning), collapse = "\n")
  })
  output$report <- downloadHandler(filename = function() "recruitment-adjustment-report.txt",
    content = function(file) writeLines(report_text(), file, useBytes = TRUE))
  output$lab_scope <- renderUI({
    if (switching_applied() || isTRUE(input$different_losses))
      p("The lab link carries the starting analyzable count and outcome assumptions into a complete-outcome scenario. Treatment switching and unequal losses remain specific to this recruitment calculation.")
    else p("The lab link carries the starting analyzable count, outcome assumptions and shared loss allowance. The simulated trials condition on the analyzable count.")
  })
  output$lab_link <- renderUI({
    n <- valid_n(); plan()
    validate(need(n >= 2 && n <= 100000, "The lab supports 2 to 100,000 analyzable participants per group."))
    values <- list(outcome = input$lab_outcome, goal = "fixed", fixed_n = n,
      dropout = if (switching_applied() || isTRUE(input$different_losses)) 0 else input$dropout)
    if (input$lab_outcome == "means") { values$plan_delta <- input$lab_delta; values$plan_sd <- input$lab_sd }
    else { values$plan_p0 <- input$lab_p0; values$plan_p1 <- input$lab_p1 }
    url <- tryCatch(lab_state_url(values), error = function(e) validate(need(FALSE, conditionMessage(e))))
    tags$a(href = url, target = "_blank", rel = "noopener", class = "btn btn-primary", "Explore the starting sample in the lab")
  })
}
shinyApp(ui, server)

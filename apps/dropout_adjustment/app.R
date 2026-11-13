library(shiny)
source("../../R/sample_size_functions.R")
source("../../R/activity_bridge.R")
source("../../R/model_answers.R")
source("../../R/app_presentation.R")

# Let the download response supply the filename. Chromium's download attribute
# can bypass the service worker serving a Shinylive download (issue 468227).
downloadButton <- function(...) {
  button <- shiny::downloadButton(...)
  button$attribs$download <- NULL
  button$attribs$target <- "_self"
  button
}

download_script <- activity_download_script()

ui <- fluidPage(
  tags$head(tags$script(HTML("$(document).on('shiny:connected',function(){Shiny.addCustomMessageHandler('recruitment-extension',function(open){document.getElementById('recruitment-advanced').open=open;});});")), tags$script(HTML(download_script)), tags$script(HTML(activity_bridge_script("dropout_adjustment"))),
    tags$style(HTML(".advanced-options>summary{background:#e9def5;padding:10px;border-radius:5px}details{margin:1em 0}summary{cursor:pointer;font-weight:600}table{width:100%}caption{color:#444}.recruitment-result{background:#dcecfb;padding:14px;border-radius:6px}.recruitment-result p{margin:0}.shiny-download-link{margin:12px 0}"))),
  titlePanel("Recruitment adjustment", windowTitle = "Recruitment adjustment"),
  activity_description(p(class = "app-intro", "This app calculates how many participants to recruit per group to allow for expected loss to follow-up. The core activity uses your preceding analyzable count and one shared loss percentage. Advanced settings cover unequal losses and treatment switching.")),
  sidebarLayout(
    sidebarPanel(
      numericInput("n", "Starting participants needed for analysis, per group", 56, min = 1, step = 1),
      activity_help("Use the analyzable count from your sample-size calculation, before allowing for missing outcomes. Any treatment-switching allowance already included should be recorded below.", for_input = "n"),
      percent_slider("dropout", "Expected loss to follow-up (%)", 0, .50, .05, step = .01),
      activity_help("Use the percentage expected to lack the primary outcome at follow-up. This applies to both groups unless different losses are selected; then it applies to the novel-treatment group.", for_input = "dropout"),
      tags$details(id = "recruitment-advanced", class = "advanced-options", tags$summary("Advanced: unequal losses and treatment switching"),
      checkboxInput("different_losses", "Use different expected losses for the two groups", FALSE),
      conditionalPanel("input.different_losses",
        percent_slider("loss_standard", "Expected loss: standard-treatment group (%)", 0, .50, .10, step = .01),
        activity_help("Use evidence specific to the standard-treatment group. Equal recruitment uses the larger group requirement so both can meet the analyzable target in expectation.", for_input = "loss_standard")),
      tags$details(class = "advanced-options", tags$summary("Allowing for treatment switching"),
        p("Treatment switching means receiving the other treatment after assignment. Follow-up should continue after a switch."),
        p("Approximation for complete switching between two treatments with little change in outcome variance."),
        checkboxInput("switching", "Explore treatment switching", FALSE),
        conditionalPanel("input.switching",
          radioButtons("starting_assumption", "What does the starting sample size assume?",
            c("Full adherence to assigned treatment" = "full", "Expected switching is already included" = "included")),
          conditionalPanel("input.starting_assumption == 'full'",
            percent_slider("switch_novel", "Novel to standard treatment (%)", 0, .50, .10, step = .01),
            percent_slider("switch_standard", "Standard to novel treatment (%)", 0, .50, .05, step = .01),
            activity_help("Use the percentage assigned to novel treatment expected to switch completely to standard treatment. The approximation assumes little change in outcome variance.", for_input = "switch_novel"),
            activity_help("Use the percentage assigned to standard treatment expected to switch completely to novel treatment. The two switching percentages reduce the assumed between-group difference.", for_input = "switch_standard")),
          activity_help("The extra allowance applies only to a calculation assuming full adherence. Selecting an existing switching allowance prevents counting its effect twice.", for_input = "starting_assumption")),
        p("For a binary outcome, the ", tags$a(href = "../two_proportions/", "two-proportion app"),
          " can recalculate sample size using revised event percentages. In the tutorial example these become 57% and 31.5%."),
        p(tags$a(href = "../book/study-designs.html#treatment-switching", "Explanation and assumptions"))))
    ),
    mainPanel(tabsetPanel(id = "recruitment_view",
      tabPanel("Overview", uiOutput("result"), uiOutput("recruitment_steps"), textOutput("recruitment_interpretation"),
        activity_details("Calculation steps and group counts", uiOutput("stages"), uiOutput("group_counts"))),
      tabPanel("Explore assumptions", plotOutput("dropout_plot", height = "340px"),
        textOutput("plot_caption", container = function(...) p(class = "caption", ...)),
        tags$details(tags$summary("Explore a complete-outcome scenario in the reasoning lab"),
        uiOutput("lab_scope"),
        selectInput("lab_outcome", "Outcome for the two-group design", c("Continuous" = "means", "Binary" = "proportions")),
        conditionalPanel("input.lab_outcome == 'means'",
          numericInput("lab_delta", "Target difference (outcome units)", 3), numericInput("lab_sd", "Standard deviation used for planning", 5, min = .1)),
        conditionalPanel("input.lab_outcome == 'proportions'",
          percent_slider("lab_p0", "Standard treatment: event probability used for planning (%)", .01, .99, .3, step = .01),
          percent_slider("lab_p1", "Novel treatment: event probability used for planning (%)", .01, .99, .6, step = .01)),
        uiOutput("lab_link"))),
      tabPanel("Report", uiOutput("plan_transfer"),
      tags$details(tags$summary("Your recruitment explanation"),
        p("Your explanation should connect the starting analyzable count, expected losses and final recruitment count."),
        activity_text_input("reasoning", "How would switching and missing assessments affect your recruitment plan?",
          "The example updates with the selected case and current calculation inputs.",
          "Your explanation should compare the starting and final counts, justify the loss and switching percentages, and identify how missing outcomes will be handled.", rows = 6)),
        uiOutput("report_preview"), activity_report_downloads("report"),
        p(id = "download-status", role = "status", `aria-live` = "polite")),
      tabPanel("Methods and references", h3("Calculation with your current values"), uiOutput("worked_method"),
        p(tags$a(href = "../book/study-designs.html#recruitment-error-activity", "Activity: Review the recruitment plan")),
        tags$details(tags$summary("Advanced calculation assumptions"), p("Starting n is multiplied by 1/(1 - a - b)^2 when the switching option applies. Here a and b are the fractions switching in the two directions. The result is divided by each group's expected retained fraction. The larger requirement is rounded upward once per group and doubled for equal recruitment."),
        p("The approximation assumes complete switching, comparable outcome distributions among recipients of the same treatment, and little change in variance. Partial, delayed, or outcome-related switching needs a more detailed model. This app calculates expected counts without generating patient outcomes.")),
        p("References: ", tags$a(href = "https://doi.org/10.1093/epirev/24.1.39", "Wittes (2002)"), "; ",
          tags$a(href = "https://doi.org/10.1111/j.1541-0420.2008.01114.x", "Shardell and El-Kamary (2009)"), "; ",
          tags$a(href = "https://www.fda.gov/media/148473/download", "ICH E9(R1)"), "."),
        app_citation("Recruitment adjustment", "dropout_adjustment"))
    ))
  )
)

server <- function(input, output, session) {
  observeEvent(input$activity_request, {
    if (isTRUE(input$activity_request$reset)) {
      updateNumericInput(session, "n", value = 56); updateSliderInput(session, "dropout", value = .05)
      updateCheckboxInput(session, "different_losses", value = FALSE); updateCheckboxInput(session, "switching", value = FALSE)
    }
  })
  observe({
    # Keep active advanced adjustments visible when changing activity routes.
    session$sendCustomMessage("recruitment-extension",
      identical(input$activity_request$activity, "recruitment_advanced") ||
        isTRUE(input$different_losses) || isTRUE(input$switching))
  })
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
  model_answers <- reactive(list(reasoning = recruitment_model_answer(plan(), switching_applied(),
    isTRUE(input$switching) && identical(input$starting_assumption, "included"))))
  activity_model_answers(session, model_answers, "reasoning")
  observe({session$sendCustomMessage("activity-question-help", list(reasoning = list(
    question = if (isTRUE(input$switching)) "How would switching and missing assessments affect your recruitment plan?" else "How would missing assessments affect your recruitment plan?",
    help = paste0("Your explanation should compare the starting and final counts, justify the loss",
      if (isTRUE(input$switching)) " and switching" else "",
      " assumptions using comparable evidence, and identify how missing outcomes will be handled."))))})
  make_table <- function(caption, headings, rows) {
    tags$table(class = "table table-striped", tags$caption(caption),
      tags$thead(tags$tr(lapply(headings, function(x) tags$th(scope = "col", x)))),
      tags$tbody(lapply(rows, function(row) tags$tr(lapply(row, tags$td)))))
  }
  output$result <- renderUI({
    x <- plan()
    tagList(app_primary_result(x$per_group, "to recruit per group", paste0(x$total, " participants in total")),
      if (switching_applied()) p(paste0("Approximate switching multiplier: ", round(x$multiplier, 3), ". The result depends on the simplified switching assumptions.")),
      if (isTRUE(input$switching) && identical(input$starting_assumption, "included"))
        p("The starting sample already accounts for switching. No additional switching multiplier is applied."))
  })
  output$recruitment_interpretation <- renderText({
    x <- plan()
    paste0("Starting with ", x$starting, " analyzable participants per group, ",
      if(switching_applied()) paste0("the switching allowance gives ", round(x$after_switching,2), " before losses. With ") else "with ",
      if(isTRUE(input$different_losses)) paste0(format_percent(x$losses[1]), " expected loss in the novel group and ",
        format_percent(x$losses[2]), " in the standard group") else paste0(format_percent(input$dropout), " expected loss in each group"),
      ", the equal-allocation recruitment target is ", x$per_group, " per group (", x$total, " in total), rounded upward.")
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
    app_plot_style()
    plot(100*losses, targets, type = "n",
      xlab = if (unequal) "Expected loss in novel group (%)" else "Expected loss in each group (%)", ylab = "Equal recruitment per group")
    app_plot_grid(); lines(100*losses, targets, lwd = 2.5, col = "#245e90")
    if (unequal) abline(h = target(x$losses[2]), lty = 2, col = "#704a93")
    app_current_point(100*input$dropout, x$per_group)
    app_point_label(100*input$dropout, x$per_group, paste0("Current: ", x$per_group))
  }, res = 96, alt = "Recruitment increases with expected losses. The current target is also given in the calculation tables.")
  output$plot_caption <- renderText({
    plan()
    if (isTRUE(input$different_losses)) paste0("Figure. Equal recruitment per group as loss in the novel group varies; standard-group loss remains ",
      format_percent(input$loss_standard), ". The dashed line shows its minimum requirement. The dot marks the current plan.")
    else "Figure. Equal recruitment per group across shared loss percentages, holding the starting sample and switching assumptions fixed. The dot marks the current plan."
  })
  output$recruitment_steps <- renderUI({
    x <- plan()
    labels <- c("Analyzable per group", if (switching_applied()) "After switching allowance", "Recruit per group")
    values <- c(x$starting, if (switching_applied()) round(x$after_switching, 2), x$per_group)
    tags$ol(class = "app-steps", `aria-label` = "Recruitment calculation",
      lapply(seq_along(values), function(i) tags$li(tags$span(class = "app-label", labels[i]), tags$span(class = "app-value", values[i]))))
  })

  method_text <- reactive({
    x <- plan()
    c(if (switching_applied()) paste0("Switching: ", x$starting, " / (1 - ", input$switch_novel, " - ", input$switch_standard,
      ")² = ", round(x$after_switching, 3), " per group before rounding.") else paste0("Starting count: ", x$starting, " per group. ",
        if (isTRUE(input$switching) && identical(input$starting_assumption, "included")) "This count already accounts for switching. " else "",
        "No additional switching adjustment is applied."),
      paste0("Loss allowance: ", round(x$after_switching, 3), " divided by each retained fraction (novel: ", 1-x$losses[1],
        "; standard: ", 1-x$losses[2], "). The larger requirement is ", round(max(x$unrounded_recruitment), 3),
        "; rounded upward to ", x$per_group, " in each group, ", x$total, " in total."))
  })
  output$worked_method <- renderUI(tags$div(class = "app-method", lapply(method_text(), tags$p)))
  report_paragraphs <- reactive(c(method_text(),
    paste0("Expected losses, novel / standard: ", paste(format_percent(plan()$losses), collapse = " / "),
      ". Expected outcomes available, novel / standard: ", paste(round(plan()$expected_retained, 2), collapse = " / "), "."),
    if (switching_applied()) "The switching approximation assumes complete switching, comparable outcome distributions among recipients of the same treatment, and little change in variance.",
    "The study plan should describe follow-up and the analysis of missing outcomes.",
    paste("Your explanation:", app_answer(input$reasoning)),
    "Your explanation is reproduced as entered and should be reviewed after changing the settings.",
    "Procedure: recruitment_plan() in R/sample_size_functions.R. References: Wittes (2002), doi:10.1093/epirev/24.1.39; Shardell and El-Kamary (2009), doi:10.1111/j.1541-0420.2008.01114.x; ICH E9(R1)."))
  output$plan_transfer <- renderUI(app_plan_transfer("Recruitment adjustment", "dropout_adjustment", "recruitment", list(starting_n = valid_n(), recruitment = plan()$per_group, dropout = input$dropout, standard_loss = if (isTRUE(input$different_losses)) input$loss_standard else input$dropout), report_paragraphs()))
  output$report_preview <- renderUI(app_report_body(report_paragraphs()))
  output$report <- downloadHandler(filename = function() "recruitment-adjustment-report.html",
    content = function(file) writeLines(app_report_document("Recruitment adjustment", "dropout_adjustment", report_paragraphs()), file, useBytes = TRUE))
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

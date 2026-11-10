# Shared two-group calculator presentation; statistical routines remain in sample_size_functions.R.
basic_calculator_ui <- function(outcome) {
  means <- outcome == "means"; slug <- if (means) "two_means" else "two_proportions"
  title <- if (means) "Two means sample size" else "Two proportions sample size"
  fluidPage(
    tags$head(tags$script(HTML(activity_bridge_script(slug))), tags$script(HTML(activity_download_script()))),
    titlePanel(title, windowTitle = title),
    p(class = "app-intro", if (means)
      "This app calculates the participants needed per group to detect a target difference between two population means at your chosen power. It assumes equal group sizes, independent participant outcomes, and a two-sided test."
      else "This app calculates the participants needed per group to detect a target difference between two population event percentages at your chosen power. It assumes equal group sizes, independent participant outcomes, and a two-sided test."),
    sidebarLayout(sidebarPanel(width = 4,
      app_input_group("Study assumptions",
        if (means) tagList(
          numericInput("delta", "Target between-group difference (outcome units)", 3, min = .01),
          activity_help("Use a clinically worthwhile, plausible difference in the outcome's units. Power is evaluated at this value. It can equal the expected difference or clinical threshold; the three roles have no fixed order.", for_input = "delta"),
          numericInput("sd", "Common standard deviation (outcome units)", 5, min = .01),
          activity_help("Use an SD from comparable participants, on the same outcome scale. This describes variation between individuals; the calculation assumes equal SDs in both groups.", for_input = "sd"))
        else tagList(
          percent_slider("pi2", "Standard treatment: assumed event probability (%)", .01, .99, .30, step = .01),
          percent_slider("pi1", "Novel treatment: assumed event probability (%)", .01, .99, .60, step = .01),
          activity_help("Use evidence for the same event definition, population, and follow-up time. Both groups should use the same definition and assessment time.", for_input = "pi2"),
          activity_help("Its difference from the standard-treatment percentage sets the target difference. This can equal the expected difference or clinical threshold; the three roles have no fixed order. Higher values favor recovery events and worsen adverse events.", for_input = "pi1"))),
      app_input_group("Statistical settings", collapsed = TRUE,
        percent_slider("alpha", "Type I error probability (%)", .001, .10, .05, step = .001),
        percent_slider("power", "Target power (%)", .50, .99, .90, step = .01),
        activity_help("A 5% setting allows a 5% false-positive probability when the population outcomes are equal. A smaller setting generally requires more participants.", for_input = "alpha"),
        activity_help("A 90% setting aims to detect the target difference in 90% of repeated studies when that difference is true. Higher targets require more participants.", for_input = "power")),
      app_input_group("Recruitment", collapsed = TRUE,
        percent_slider("dropout", "Expected loss to follow-up (%)", 0, .50, 0, step = .01),
        activity_help("Use the percentage expected to lack the primary outcome at follow-up, supported by comparable studies. For 10% loss, recruitment is the analyzable count divided by 0.90, rounded up.", for_input = "dropout"))),
    mainPanel(width = 8, tabsetPanel(id = "calculator_view",
      tabPanel("Overview",
        uiOutput("result"),
        app_overview(tagList(plotOutput("allocation_plot", height = "310px"), p(class = "caption", "Figure. Required analyzable participants per group across target differences. The labeled dot marks your current plan; other assumptions stay fixed.")),
          tagList(textOutput("interpretation"), activity_details("Advanced simulation", uiOutput("lab_link")))),
        activity_details("Current assumptions", tableOutput("assumptions"))),
      tabPanel("Explore assumptions",
        p("The curve varies the target difference while keeping the other assumptions fixed. The point marks your current plan."),
        plotOutput("sample_size_plot", height = "350px"),
        p(class = "caption", "Figure. Required analyzable participants per group across target differences, with other planning assumptions fixed."),
        tags$details(class = "app-comparison", tags$summary("Compare two scenarios"),
          p("The first column preserves your current plan while the second shows a revised assumption."),
          if (means) numericInput("compare_delta", "Revised target difference (outcome units)", 2, min = .01)
          else percent_slider("compare_pi1", "Revised novel-treatment event probability (%)", .01, .99, .50, step = .01),
          if (means) activity_help("A plausible smaller difference shows how much the sample requirement depends on your target. The original plan stays in the first column.", for_input = "compare_delta")
          else activity_help("A value closer to the standard-treatment percentage gives a smaller target difference. The original plan stays in the first column.", for_input = "compare_pi1"),
          p("Both columns use the same power, error probability, expected losses, and remaining assumptions."),
          tableOutput("comparison_table"))),
      tabPanel("Report", uiOutput("plan_transfer"), uiOutput("report_preview"), activity_report_downloads("download_report"),
        p(id = "download-status", role = "status", `aria-live` = "polite")),
      tabPanel("Methods and references", h3("Calculation with your current values"), uiOutput("worked_method"),
        p(if (means) "This introductory normal approximation uses a common population SD. The reasoning lab uses t-test power with an estimated SD and can require a different sample size."
          else "This normal approximation uses R's two-sided power.prop.test calculation, with both rejection tails included. The reasoning lab uses the same binary planning approximation and can explore its finite-sample performance by simulation."),
        p("Required analyzable counts are rounded upward. Recruitment is then adjusted and rounded separately within each group."),
        p(tags$a(href = "../book/calculations.html", target = "_blank", rel = "noopener", "Tutorial: basic calculations"), " · ",
          tags$a(href = "../book/appendix.html#tutorial-methods", target = "_blank", rel = "noopener", "Methods and reproducibility")),
        app_citation(title, slug))))))
}

basic_calculator_server <- function(outcome) function(input, output, session) {
  means <- outcome == "means"; slug <- if (means) "two_means" else "two_proportions"
  title <- if (means) "Two means sample size" else "Two proportions sample size"
  observeEvent(input$activity_request, {
    id <- input$activity_request$activity
    if (identical(id, "probiotics_calculation") && !means) {
      updateSliderInput(session, "pi1", value = .90); updateSliderInput(session, "pi2", value = .80)
      updateSliderInput(session, "compare_pi1", value = .85); updateSliderInput(session, "dropout", value = .15)
      updateSliderInput(session, "power", value = .90); updateSliderInput(session, "alpha", value = .05)
    } else if (identical(id, "rehabilitation_calculation") && means) {
      updateNumericInput(session, "delta", value = 3); updateNumericInput(session, "sd", value = 5)
      updateNumericInput(session, "compare_delta", value = 1.5); updateSliderInput(session, "dropout", value = .10)
      updateSliderInput(session, "power", value = .90); updateSliderInput(session, "alpha", value = .05)
    }
  })
  calculate <- function(difference = input$delta, probability = input$pi1) {
    tryCatch(if (means) sample_size_two_means_details(difference, input$sd, input$alpha, input$power, input$dropout)
      else sample_size_two_proportions_details(probability, input$pi2, input$alpha, input$power, input$dropout),
      error = function(e) validate(need(FALSE, conditionMessage(e))))
  }
  result <- reactive(calculate())
  assumptions <- reactive({
    x <- result()
    data.frame(Assumption = c(if (means) c("Target difference (units)", "Common SD (units)") else c("Standard event probability", "Novel event probability", "Absolute target difference"),
        "Type I error probability", "Target power", "Expected losses"),
      Value = c(if (means) c(x$delta, x$sd) else c(format_percent(x$pi2), format_percent(x$pi1), paste0(round(100*x$difference, 2), " percentage points")),
        format_percent(x$alpha), format_percent(x$power), format_percent(x$dropout_rate)))
  })
  output$result <- renderUI({
    x <- result()
    app_primary_result(if (x$dropout_rate > 0) x$total_with_dropout/2 else x$n_per_group,
      if (x$dropout_rate > 0) "to recruit per group" else "analyzable per group",
      if (x$dropout_rate > 0) paste0(x$total_with_dropout, " to recruit in total, allowing for ",
        format_percent(x$dropout_rate), " expected loss. Analysis requires ", x$n_per_group, " per group (", x$total_n, " total).")
      else paste0(x$total_n, " in total · ", format_percent(x$power), " target power · ",
        format_percent(x$alpha), " Type I error probability"))
  })
  output$interpretation <- renderText({
    x <- result()
    paste0("Power is evaluated at ", if (means) paste0("a target difference of ", x$delta, " units with common SD ", x$sd)
      else paste0("a target difference of ", round(100*x$difference, 2), " percentage points (", format_percent(x$pi1), " versus ", format_percent(x$pi2), ")"),
      ". Smaller target differences generally require more participants.")
  })
  output$assumptions <- renderTable(assumptions(), striped = TRUE)
  draw_curve <- function() {
    x <- result(); app_plot_style()
    if (means) {
      ds <- seq(max(.01, x$delta/2), x$delta*1.75, length.out = 100)
      ns <- vapply(ds, sample_size_two_means, numeric(1), sd = x$sd, alpha = x$alpha, power = x$power)
      axis_x <- ds; selected <- x$delta; label <- "Target difference (units)"
    } else {
      direction <- sign(x$pi1-x$pi2)
      limit <- if (direction > 0) .99-x$pi2 else x$pi2-.01
      ds <- seq(max(.001, x$difference/2), min(limit, x$difference*1.75), length.out = 100)
      ns <- vapply(x$pi2+direction*ds, sample_size_two_proportions, numeric(1), pi2=x$pi2, alpha=x$alpha, power=x$power)
      axis_x <- 100*ds; selected <- 100*x$difference; label <- "Absolute target difference (points)"
    }
    plot(axis_x, ns, type = "n", ylim = c(0,max(ns)*1.05), xlab = label, ylab = "Analyzable per group")
    app_plot_grid(); lines(axis_x, ns, lwd = 2.5, col = "#245e90")
    app_current_point(selected, x$n_per_group)
    app_point_label(selected, x$n_per_group, paste0("Current: ", x$n_per_group))
  }
  output$allocation_plot <- renderPlot(draw_curve(), res = 96,
    alt = "Required analyzable participants per group across target differences. A labeled dot marks the current plan, also given in the numerical result.")
  output$lab_link <- renderUI({
    x <- result(); validate(need(x$n_per_group >= 2 && x$n_per_group <= 100000, "The reasoning lab supports 2 to 100,000 analyzable participants per group."))
    v <- list(outcome = if (means) "means" else "proportions", goal = "fixed", fixed_n = x$n_per_group,
      alpha = input$alpha, target_power = input$power, dropout = input$dropout)
    v <- c(v, if (means) list(plan_delta = input$delta, plan_sd = input$sd) else list(plan_p0 = input$pi2, plan_p1 = input$pi1))
    tags$a(href = lab_state_url(v), target = "_blank", rel = "noopener", class = "btn btn-primary", "Advanced: simulate this design")
  })
  output$sample_size_plot <- renderPlot(draw_curve(), res = 96,
    alt = "Required analyzable participants per group across target differences, holding other assumptions fixed. The current plan is marked.")
  output$comparison_table <- renderTable({
    original <- result(); updated <- if (means) calculate(difference = input$compare_delta) else calculate(probability = input$compare_pi1)
    data.frame(Quantity = c(if (means) "Target difference (units)" else "Novel event probability", "Analyzable per group", "Analyzable total", "Recruitment total"),
      Current = c(if (means) original$delta else format_percent(original$pi1), original$n_per_group, original$total_n, original$total_with_dropout),
      Revised = c(if (means) updated$delta else format_percent(updated$pi1), updated$n_per_group, updated$total_n, updated$total_with_dropout))
  }, striped = TRUE)
  method_text <- reactive({
    x <- result()
    c(if (means) paste0("M = [z(1 - Type I error probability / 2) + z(target power)]² = ", round(x$multiplier, 4),
      ". n per group = 2 × M × SD² / target difference² = 2 × ", round(x$multiplier, 4), " × ", x$sd, "² / ", x$delta, "² = ", round(x$raw_n_per_group, 3), "; rounded upward to ", x$n_per_group, ".")
      else paste0("R stats::power.prop.test(p1 = ", x$pi1, ", p2 = ", x$pi2, ", sig.level = ", x$alpha,
        ", power = ", x$power, ", alternative = 'two.sided', strict = TRUE) gives ", round(x$raw_n_per_group, 3), " per group, rounded upward to ", x$n_per_group, "."),
      paste0("Recruitment per group = ceiling(", x$n_per_group, " / ", 1-x$dropout_rate, ") = ", x$total_with_dropout/2, "; total = ", x$total_with_dropout, "."))
  })
  output$worked_method <- renderUI(tags$div(class = "app-method", lapply(method_text(), tags$p)))
  report_paragraphs <- reactive(c(sample_size_interpretation(result()),
    "Two independent groups, equal allocation, two-sided test. Each participant contributes one outcome, and outcomes from different participants are assumed independent. The target difference and variation assumptions require evidence appropriate to the intended population and outcome.", method_text(),
    {
      revised <- tryCatch(if (means) calculate(difference = input$compare_delta) else calculate(probability = input$compare_pi1), error = function(e) NULL)
      if (is.null(revised)) "The revised scenario has invalid inputs and is omitted."
      else if ((means && input$compare_delta != input$delta) || (!means && input$compare_pi1 != input$pi1))
        paste0("Revised scenario, with all other assumptions unchanged: ", if (means) paste0("target difference ", revised$delta, " units")
          else paste0("novel-treatment event probability ", format_percent(revised$pi1), "; absolute target difference ", round(100*revised$difference, 2), " percentage points"),
          ". Analyzable sample: ", revised$n_per_group, " per group (", revised$total_n, " total); recruitment: ", revised$total_with_dropout/2,
          " per group (", revised$total_with_dropout, " total).")
    },
    "Expected losses affect recruitment counts. Missing outcomes and treatment changes also require prevention and an appropriate analysis plan."))
  output$plan_transfer <- renderUI({
    x <- result()
    app_plan_transfer(title, slug, "calculation",
      c(list(outcome = if (means) "continuous" else "binary", study_type = "comparison", goal = "testing", analyzable = x$n_per_group,
        alpha = x$alpha, power = x$power, dropout = x$dropout_rate, recruitment = x$total_with_dropout/2,
        raw_n = x$raw_n_per_group),
        if (means) list(target_difference = x$delta, sd = x$sd)
        else list(p_treatment = x$pi1, p_control = x$pi2, target_difference = abs(x$pi1-x$pi2))),
      c(sample_size_interpretation(x), paste(assumptions()$Assumption, assumptions()$Value, sep = ": "), method_text()))
  })
  output$report_preview <- renderUI(app_report_body(report_paragraphs(), assumptions()))
  output$download_report <- downloadHandler(filename = function() paste0(slug, "-report.html"),
    content = function(file) writeLines(app_report_document(title, slug, report_paragraphs(), assumptions()), file, useBytes = TRUE))
}

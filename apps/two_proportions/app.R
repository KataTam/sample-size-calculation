library(shiny)

source("../../R/sample_size_functions.R")
source("../../R/activity_bridge.R")

ui <- fluidPage(
  tags$head(tags$script(HTML(activity_bridge_script("two_proportions")))),
  titlePanel("Sample Size: Two Proportions", windowTitle = "Two proportions sample size"),
  sidebarLayout(
    sidebarPanel(
      percent_slider("pi1", "Novel treatment: expected event rate for the calculation (%)", min = 0.01, max = 0.99, value = 0.60, step = 0.01),
      percent_slider("pi2", "Standard treatment: expected event rate for the calculation (%)", min = 0.01, max = 0.99, value = 0.30, step = 0.01),
      helpText("These assumed event rates determine the planning difference. The pain example expects a 40-percentage-point benefit, plans for 30 points and uses a 20-point clinical threshold."),
      percent_slider("alpha", tags$a(href = "../book/Sample_size_open_module.html#alpha", target = "_blank", rel = "noopener", "Type I error rate (%)"), min = 0.001, max = 0.10, value = 0.05, step = 0.001),
      percent_slider("power", tags$a(href = "../book/Sample_size_open_module.html#statistical-power", target = "_blank", rel = "noopener", "Target power (%)"), min = 0.50, max = 0.99, value = 0.90, step = 0.01),
      percent_slider("dropout", "Expected loss to follow-up (%)", min = 0, max = 0.50, value = 0, step = 0.01)
    ),
    mainPanel(
      p("Introductory normal approximation; two independent groups with equal allocation. The reasoning lab uses explicitly specified test-based power and may give a different answer."),
      p("Dropout is inflated and rounded within each arm. It changes recruitment targets, not missing-data bias."),
      h3("Approximate sample size"),
      verbatimTextOutput("result"),
      h3("Interpretation"),
      textOutput("interpretation"),
      uiOutput("lab_link"),
      helpText("The lab receives this calculated analysable count as a fixed sample, together with your event rates, Type I error rate, power target and losses. Its test-based power may differ from this approximation."),
      h3("Effect size and sample size"),
      plotOutput("sample_size_plot", height = "320px"),
      p(class = "caption", "Figure. Approximate total analysable sample size across absolute planning differences, holding the control event rate, Type I error rate and target power fixed."),
      h3("Assumptions"),
      tableOutput("assumptions"),
      p(class = "caption", "Table. Current event percentages, absolute planning difference, error targets and expected losses.")
    )
  )
)

server <- function(input, output, session) {
  result <- reactive({
    validate(need(input$pi1 != input$pi2, "Choose different event rates for planning. Required sample size for detecting zero is undefined; the lab allows null scenarios."))
    sample_size_two_proportions_details(
      pi1 = input$pi1,
      pi2 = input$pi2,
      alpha = input$alpha,
      power = input$power,
      dropout_rate = input$dropout
    )
  })

  output$result <- renderPrint({
    x <- result()
    cat("Per group:", x$n_per_group, "\n")
    cat("Total before dropout adjustment:", x$total_n, "\n")
    if (x$dropout_rate > 0) {
      cat("Recruitment target after dropout adjustment:", x$total_with_dropout, "\n")
    }
  })

  output$interpretation <- renderText({
    sample_size_interpretation(result())
  })
  output$lab_link <- renderUI({
    x <- result()
    validate(need(x$n_per_group >= 2 && x$n_per_group <= 100000,
      "The reasoning lab supports 2 to 100,000 analysable participants per group."))
    tags$a(href = lab_state_url(list(outcome = "proportions", goal = "fixed", fixed_n = x$n_per_group,
      plan_p0 = input$pi2, plan_p1 = input$pi1, alpha = input$alpha,
      target_power = input$power, dropout = input$dropout)), target = "_blank", rel = "noopener",
      class = "btn btn-primary", "Explore this design in the lab")
  })

  output$sample_size_plot <- renderPlot({
    result()
    par(cex.axis = 1.1, cex.lab = 1.15, cex.main = 1.15)
    pi1_values <- seq(0.05, 0.95, by = 0.01)
    keep <- abs(pi1_values - input$pi2) > 0.001
    pi1_values <- pi1_values[keep]
    n_values <- vapply(
      pi1_values,
      sample_size_two_proportions,
      numeric(1),
      pi2 = input$pi2,
      alpha = input$alpha,
      power = input$power
    )

    plot(
      100 * abs(pi1_values - input$pi2),
      2 * n_values,
      type = "p",
      lwd = 2,
      xlab = "Absolute planning difference (percentage points)",
      ylab = "Required total sample size",
      main = "Smaller differences require larger studies"
    )
    points(100 * abs(input$pi1 - input$pi2), result()$total_n, pch = 19, cex = 1.3)
    text(100 * abs(input$pi1 - input$pi2), result()$total_n, labels = " current", pos = 4)
  })

  output$assumptions <- renderTable({
    x <- result()
    data.frame(
      Assumption = c(
        "Novel treatment event rate",
        "Standard treatment event rate",
        "Absolute difference",
        "Type I error rate",
        "Power",
        "Dropout"
      ),
      Value = c(
        format_percent(x$pi1),
        format_percent(x$pi2),
        paste0(round(100 * x$difference, 1), " percentage points"),
        format_percent(input$alpha),
        format_percent(x$power),
        format_percent(x$dropout_rate)
      ),
      check.names = FALSE
    )
  })
}

shinyApp(ui, server)

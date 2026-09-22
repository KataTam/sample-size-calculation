library(shiny)

source("../../R/sample_size_functions.R")

ui <- fluidPage(
  titlePanel("Sample Size: Two Proportions"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("pi1", "Expected event rate in novel treatment group", min = 0.01, max = 0.99, value = 0.60, step = 0.01),
      sliderInput("pi2", "Expected event rate in standard treatment group", min = 0.01, max = 0.99, value = 0.30, step = 0.01),
      sliderInput("alpha", "Alpha", min = 0.001, max = 0.10, value = 0.05, step = 0.001),
      sliderInput("power", "Power", min = 0.50, max = 0.99, value = 0.90, step = 0.01),
      sliderInput("dropout", "Expected dropout rate", min = 0, max = 0.50, value = 0, step = 0.01)
    ),
    mainPanel(
      p("Introductory normal approximation; two independent groups with equal allocation. The reasoning lab uses explicitly specified test-based power and may give a different answer."),
      p("Dropout is inflated and rounded within each arm. It changes recruitment targets, not missing-data bias."),
      h3("Approximate sample size"),
      verbatimTextOutput("result"),
      h3("Interpretation"),
      textOutput("interpretation"),
      h3("Effect size and sample size"),
      plotOutput("sample_size_plot", height = "320px"),
      h3("Assumptions"),
      tableOutput("assumptions")
    )
  )
)

server <- function(input, output, session) {
  result <- reactive({
    validate(need(input$pi1 != input$pi2, "Choose different planning probabilities. Required sample size for detecting zero is undefined; the lab allows null scenarios."))
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
      abs(pi1_values - input$pi2),
      2 * n_values,
      type = "p",
      lwd = 2,
      xlab = "Absolute difference between event rates",
      ylab = "Required total sample size",
      main = "Smaller differences require larger studies"
    )
    points(abs(input$pi1 - input$pi2), result()$total_n, pch = 19, cex = 1.3)
    text(abs(input$pi1 - input$pi2), result()$total_n, labels = " current", pos = 4)
  })

  output$assumptions <- renderTable({
    x <- result()
    data.frame(
      Assumption = c(
        "Novel treatment event rate",
        "Standard treatment event rate",
        "Absolute difference",
        "Alpha",
        "Power",
        "Dropout"
      ),
      Value = c(
        format_percent(x$pi1),
        format_percent(x$pi2),
        format_percent(x$difference),
        input$alpha,
        format_percent(x$power),
        format_percent(x$dropout_rate)
      ),
      check.names = FALSE
    )
  })
}

shinyApp(ui, server)

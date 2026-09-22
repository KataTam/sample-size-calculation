library(shiny)

source("../../R/sample_size_functions.R")

ui <- fluidPage(
  titlePanel("Sample Size: Two Means"),
  sidebarLayout(
    sidebarPanel(
      numericInput("delta", "Difference assumed for planning", value = 3, min = 0.01),
      numericInput("sd", "Expected standard deviation", value = 5, min = 0.01),
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
      h3("Difference and sample size"),
      plotOutput("sample_size_plot", height = "320px"),
      h3("Assumptions"),
      tableOutput("assumptions")
    )
  )
)

server <- function(input, output, session) {
  result <- reactive({
    validate(need(is.finite(input$delta) && input$delta > 0 && is.finite(input$sd) && input$sd > 0, "Enter positive finite planning difference and SD."))
    sample_size_two_means_details(
      delta = input$delta,
      sd = input$sd,
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
    delta_values <- seq(max(0.1, input$delta / 4), input$delta * 2.5, length.out = 100)
    n_values <- vapply(
      delta_values,
      sample_size_two_means,
      numeric(1),
      sd = input$sd,
      alpha = input$alpha,
      power = input$power
    )

    plot(
      delta_values,
      2 * n_values,
      type = "l",
      lwd = 2,
      xlab = "Planning difference",
      ylab = "Required total sample size",
      main = "Smaller differences require larger studies"
    )
    points(input$delta, result()$total_n, pch = 19, cex = 1.3)
    text(input$delta, result()$total_n, labels = " current", pos = 4)
  })

  output$assumptions <- renderTable({
    x <- result()
    data.frame(
      Assumption = c(
        "Planning difference",
        "Expected standard deviation",
        "Alpha",
        "Power",
        "Dropout"
      ),
      Value = c(
        x$delta,
        x$sd,
        input$alpha,
        format_percent(x$power),
        format_percent(x$dropout_rate)
      ),
      check.names = FALSE
    )
  })
}

shinyApp(ui, server)

library(shiny)

source("../../R/sample_size_functions.R")

ui <- fluidPage(
  titlePanel("Dropout Adjustment"),
  sidebarLayout(
    sidebarPanel(
      numericInput("n", "Required analysable participants PER GROUP", value = 100, min = 1, step = 1),
      sliderInput("dropout", "Expected dropout rate", min = 0, max = 0.50, value = 0.10, step = 0.01)
    ),
    mainPanel(
      p("Equal allocation. Round recruitment up within each arm, then double. Inflation does not remove missing-data bias or guarantee the realised analysable count."),
      h3("Recruitment target"),
      verbatimTextOutput("result"),
      h3("Dropout and recruitment target"),
      plotOutput("dropout_plot", height = "320px")
    )
  )
)

server <- function(input, output, session) {
  valid_n <- reactive({ validate(need(is.finite(input$n) && input$n == floor(input$n) && input$n >= 1, "Use a positive integer per group.")); input$n })
  output$result <- renderPrint({
    valid_n()
    cat("Analysable per group:", input$n, "\n")
    cat("Expected dropout:", format_percent(input$dropout), "\n")
    cat("Recruitment per group:", adjust_for_dropout(input$n, input$dropout), "\n")
    cat("Recruitment total:", 2 * adjust_for_dropout(input$n, input$dropout), "\n")
  })

  output$dropout_plot <- renderPlot({
    valid_n()
    par(cex.axis = 1.1, cex.lab = 1.15, cex.main = 1.15)
    dropout_values <- seq(0, 0.5, by = 0.01)
    targets <- vapply(dropout_values, adjust_for_dropout, numeric(1), n = input$n)
    plot(
      dropout_values,
      targets,
      type = "l",
      lwd = 2,
      xlab = "Expected dropout rate",
      ylab = "Recruitment target per group",
      main = "More dropout means more recruitment"
    )
    points(input$dropout, adjust_for_dropout(input$n, input$dropout), pch = 19, cex = 1.3)
    text(input$dropout, adjust_for_dropout(input$n, input$dropout), labels = " current", pos = 4)
  })
}

shinyApp(ui, server)

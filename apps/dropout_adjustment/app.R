library(shiny)

source("../../R/sample_size_functions.R")
source("../../R/activity_bridge.R")

ui <- fluidPage(
  tags$head(tags$script(HTML(activity_bridge_script("dropout_adjustment")))),
  titlePanel("Dropout Adjustment", windowTitle = "Dropout adjustment"),
  sidebarLayout(
    sidebarPanel(
      numericInput("n", "Participants needed for analysis, per group", value = 100, min = 1, step = 1),
      percent_slider("dropout", "Expected loss to follow-up (%)", min = 0, max = 0.50, value = 0.10, step = 0.01)
    ),
    mainPanel(
      p("Equal allocation. Round recruitment up within each arm, then double. Inflation does not remove missing-data bias or guarantee the realized analyzable count."),
      h3("Recruitment target"),
      verbatimTextOutput("result"),
      h3("Dropout and recruitment target"),
      plotOutput("dropout_plot", height = "320px"),
      p(class = "caption", "Figure. Recruitment required per arm at different expected dropout percentages, for the chosen analyzable count."),
      tags$details(tags$summary("Continue with this sample size in the reasoning lab"),
        p("A count and dropout fraction do not specify an outcome or effect. Add those assumptions below. The initial values are illustrative."),
        selectInput("lab_outcome", "Outcome for the two-group design", c("Continuous" = "means", "Binary" = "proportions")),
        conditionalPanel("input.lab_outcome == 'means'",
          numericInput("lab_delta", "Difference used for planning", 3), numericInput("lab_sd", "Standard deviation used for planning", 5, min = .1)),
        conditionalPanel("input.lab_outcome == 'proportions'",
          percent_slider("lab_p0", "Standard treatment: event rate used for planning (%)", .01, .99, .3, step = .01),
          percent_slider("lab_p1", "Novel treatment: event rate used for planning (%)", .01, .99, .6, step = .01)),
        uiOutput("lab_link"),
        helpText("This transfers the entered analyzable count per group, without recalculating it from a power target."))
    )
  )
)

server <- function(input, output, session) {
  valid_n <- reactive({ validate(need(is.finite(input$n) && input$n == floor(input$n) && input$n >= 1, "Use a positive integer per group.")); input$n })
  output$lab_link <- renderUI({
    n <- valid_n()
    validate(need(n >= 2 && n <= 100000, "The lab supports 2 to 100,000 analyzable participants per group."))
    values <- list(outcome = input$lab_outcome, goal = "fixed", fixed_n = n, dropout = input$dropout)
    if (input$lab_outcome == "means") { values$plan_delta <- input$lab_delta; values$plan_sd <- input$lab_sd }
    else { values$plan_p0 <- input$lab_p0; values$plan_p1 <- input$lab_p1 }
    url <- tryCatch(lab_state_url(values), error = function(e) validate(need(FALSE, conditionMessage(e))))
    tags$a(href = url, target = "_blank", rel = "noopener", class = "btn btn-primary", "Explore this design in the lab")
  })
  output$result <- renderPrint({
    valid_n()
    cat("Participants for analysis, per group:", input$n, "\n")
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
      100 * dropout_values,
      targets,
      type = "l",
      lwd = 2,
      xlab = "Expected dropout (%)",
      ylab = "Recruitment target per group",
      main = "More dropout means more recruitment"
    )
    points(100 * input$dropout, adjust_for_dropout(input$n, input$dropout), pch = 19, cex = 1.3)
    text(100 * input$dropout, adjust_for_dropout(input$n, input$dropout), labels = " current", pos = 4)
  })
}

shinyApp(ui, server)

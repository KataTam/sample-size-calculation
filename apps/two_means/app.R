library(shiny)

source("../../R/sample_size_functions.R")
source("../../R/activity_bridge.R")
source("../../R/app_presentation.R")
source("../../R/basic_calculator.R")

ui <- basic_calculator_ui("means")
server <- basic_calculator_server("means")
shinyApp(ui, server)

check_app_presentation <- function() {
  library(shiny)
  source("R/sample_size_functions.R", local = TRUE)
  source("R/activity_bridge.R", local = TRUE)
  source("R/app_presentation.R", local = TRUE)
  source("R/basic_calculator.R", local = TRUE)
  for (outcome in c("means", "proportions")) {
    testServer(basic_calculator_server(outcome), {
      session$setInputs(delta = 3, sd = 5, pi1 = .6, pi2 = .3, alpha = .05, power = .9, dropout = 0,
        compare_delta = 2, compare_pi1 = .5)
      stopifnot(result()$n_per_group == if (outcome == "means") 59 else 56,
        !is.null(output$result), !is.null(output$allocation_plot), !is.null(output$sample_size_plot),
        !is.null(output$comparison_table), grepl("ceiling", output$worked_method$html),
        grepl("Current report", output$report_preview$html))
      revised <- if (outcome == "means") calculate(difference = 2) else calculate(probability = .5)
      stopifnot(revised$n_per_group > result()$n_per_group)
      session$setInputs(dropout = .2)
      stopifnot(result()$total_with_dropout == 2*ceiling(result()$n_per_group/.8),
        grepl(as.character(result()$total_with_dropout), paste(report_paragraphs(), collapse = " ")))
      if (outcome == "proportions") {
        session$setInputs(pi1 = .1, compare_pi1 = .2)
        stopifnot(!is.null(output$sample_size_plot))
        session$setInputs(pi1 = .3)
        stopifnot(inherits(tryCatch(result(), error = identity), "error"))
      }
    })
  }
  html <- app_report_document("Test report", "two_means", c("<script>learner text</script>", "A & B"), data.frame(Input = "SD", Value = 5))
  stopifnot(grepl("<head>", html, fixed=TRUE), grepl("<style>", html, fixed=TRUE), grepl("<title>Test report</title>", html, fixed=TRUE), grepl("&lt;script&gt;", html, fixed=TRUE), grepl("A &amp; B", html, fixed=TRUE),
    grepl("https://creativecommons.org/licenses/by-sa/4.0/", html, fixed=TRUE), grepl("https://opensource.org/license/mit", html, fixed=TRUE))
  message("Shared app presentation: current/revised calculations, recruitment rounding, invalid inputs, rendered methods and escaped report content passed.")
}
if (identical(environment(), globalenv())) check_app_presentation()

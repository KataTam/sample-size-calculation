check_recruitment <- function() {
  source("R/sample_size_functions.R", local = TRUE)
  rejects <- function(expr) stopifnot(inherits(tryCatch(force(expr), error = identity), "error"))
  # Reproduce existing shared-loss examples and the unequal-loss planning criterion.
  stopifnot(recruitment_plan(56, .05)$per_group == 59,
    recruitment_plan(56, .10)$total == 126,
    recruitment_plan(56, .20, .10)$per_group == 70,
    identical(unname(recruitment_plan(56, .20, .10)$expected_retained), c(56, 63)))
  # Independent threshold checks: one fewer recruit falls short in at least one arm.
  for (n in c(1, 56, 100)) for (r1 in c(0, .05, .2)) for (r0 in c(0, .1, .3)) {
    x <- recruitment_plan(n, r1, r0, .10, .05)
    stopifnot(all(x$expected_retained * .85^2 >= n - 1e-10),
      any((x$per_group - 1) * (1 - c(r1, r0)) * .85^2 < n),
      x$per_group == recruitment_plan(n, r0, r1, .05, .10)$per_group)
  }
  # Rounding only at the final step avoids a spurious extra participant.
  x <- recruitment_plan(100, .05, .05, .1, .05)
  stopifnot(x$per_group == 146, x$total == 292,
    ceiling(ceiling(x$after_switching) / .95) == 147)
  rejects(recruitment_plan(0)); rejects(recruitment_plan(2.5))
  rejects(recruitment_plan(100, 1)); rejects(recruitment_plan(100, -.1))
  rejects(recruitment_plan(100, switch_novel = .5, switch_standard = .5))
  rejects(recruitment_plan(100, switch_novel = NA_real_))
  old <- getwd(); on.exit(setwd(old)); setwd("apps/dropout_adjustment")
  app <- new.env(parent = globalenv()); sys.source("app.R", envir = app)
  shiny::testServer(app$server, {
    session$setInputs(n = 100, dropout = .05, different_losses = FALSE, loss_standard = .10,
      switching = FALSE, starting_assumption = "full", switch_novel = .10, switch_standard = .05,
      reasoning = "Evidence from comparable trials", lab_outcome = "means", lab_delta = 3, lab_sd = 5)
    stopifnot(plan()$per_group == 106)
    session$setInputs(switching = TRUE)
    stopifnot(plan()$per_group == 146, grepl("292", output$result$html),
      grepl("Evidence from comparable trials", report_text()), grepl("Shiny", report_text()))
    session$setInputs(starting_assumption = "included")
    stopifnot(plan()$per_group == 106, plan()$multiplier == 1,
      grepl("already accounts", output$result$html), grepl("Applied switching, novel to standard: 0%", report_text()))
    session$setInputs(starting_assumption = "full", switch_novel = .5, switch_standard = .5)
    rejects(plan())
    session$setInputs(switching = FALSE, n = 56, dropout = .20, different_losses = TRUE)
    stopifnot(plan()$per_group == 70, grepl("140", output$result$html),
      grepl("standard-group loss remains 10%", output$plot_caption))
    session$setInputs(different_losses = FALSE)
    stopifnot(plan()$per_group == 70, all(plan()$losses == .2))
    session$setInputs(n = -1)
    rejects(plan())
  })
  message("Recruitment thresholds, rounding, invalid inputs, switching controls and reports passed.")
}
if (identical(environment(), globalenv())) check_recruitment()

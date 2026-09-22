check_simulation <- function() {
  source("R/sample_size_functions.R", local = TRUE)
  expect_error <- function(code) stopifnot(inherits(tryCatch({ force(code); NULL }, error = identity), "error"))
  stopifnot(abs(power_normal_known(40, 0, 5) - .05) < 1e-12,
    abs(power_two_means(40, 0, 5) - .05) < 1e-12,
    abs(power_two_proportions(40, .3, .3) - .05) < 1e-12)
  expect_error(study_spec(n = 2.5)); expect_error(study_spec(sd = Inf))
  expect_error(study_spec(seed = -1)); expect_error(study_spec(B = NA_real_))
  expect_error(plan_n(study_spec(delta = 0)))
  expect_error(plan_n(study_spec(width_target = 1e-10), "precision"))
  stopifnot(2 * sample_size_two_proportions(.9, .8, power = .8) == 394,
            2 * sample_size_two_proportions(.96, .8, power = .9) == 164)
  x <- sample_size_two_means_details(10, 20, power = .8, dropout_rate = .15)
  stopifnot(x$total_with_dropout == 150)

  s <- study_spec(n = 45, B = 30000)
  one <- simulate_one_study(s)
  ref <- t.test(outcome ~ group, data = transform(one$data,
    group = factor(group, levels = c("Treatment", "Control"))), var.equal = TRUE)
  stopifnot(abs(one$result$p_value - ref$p.value) < 1e-12,
    max(abs(c(one$result$lower, one$result$upper) - ref$conf.int)) < 1e-12)
  b <- analyse_binary(32, 18, 60, .05)
  pref <- prop.test(c(32, 18), c(60, 60), correct = FALSE)
  stopifnot(abs(b$p_value - pref$p.value) < 1e-12)
  for (counts in list(c(0,0), c(60,60), c(60,0), c(0,60))) {
    z <- analyse_binary(counts[1], counts[2], 60, .05)
    stopifnot(all(is.finite(unlist(z))), z$lower >= -1, z$upper <= 1,
      z$p_value >= 0, z$p_value <= 1)
  }
  # Compare binary Monte Carlo output against exact enumeration at small n.
  n <- 12; p0 <- .2; p1 <- .4
  grid <- expand.grid(treatment = 0:n, control = 0:n)
  result <- analyse_binary(grid$treatment, grid$control, n, .05)
  weights <- dbinom(grid$treatment, n, p1) * dbinom(grid$control, n, p0)
  exact_reject <- sum(weights * (result$p_value < .05))
  exact_cover <- sum(weights * (result$lower <= p1-p0 & result$upper >= p1-p0))
  sparse <- simulate_trials(study_spec(outcome = "proportions", n = n,
    p_control = p0, p_treatment = p1, B = 50000))
  stopifnot(abs(mean(sparse$results$reject) - exact_reject) < .015,
            abs(mean(sparse$results$cover) - exact_cover) < .015)
  rows <- list()
  for (outcome in c("means", "proportions")) for (null in c(FALSE, TRUE)) {
    spec <- study_spec(outcome = outcome, n = 60, B = 30000,
      delta = if (null) 0 else 3, p_treatment = if (null) .3 else .6)
    sim <- simulate_trials(spec); reject <- mean(sim$results$reject)
    cover <- mean(sim$results$cover)
    stopifnot(abs(reject - spec_power(spec)) < .02, abs(cover - .95) < .02)
    if (outcome == "means") stopifnot(abs(mean(sim$results$width) - anticipated_width(spec)) < .025)
    rows[[length(rows)+1]] <- data.frame(outcome, null, rejection = reject,
      analytical_power = spec_power(spec), coverage = cover)
  }
  print(do.call(rbind, rows))
  set.seed(91); before <- .Random.seed
  a <- simulate_trials(s); stopifnot(identical(.Random.seed, before))
  stopifnot(identical(a, simulate_trials(s)), length(unique(a$results$estimate)) > 100)
  s2 <- s; s2$seed <- s$seed + 1; stopifnot(!identical(a$results, simulate_trials(s2)$results))
  extreme <- a; extreme$results$reject <- FALSE
  sm <- simulation_summary(extreme); stopifnot(sm$MC_upper_95[1] > 0)
  for (outcome in c("means", "proportions")) for (goal in c("testing", "precision")) {
    spec <- study_spec(outcome = outcome, width_target = if (outcome == "means") 4 else .2)
    n <- plan_n(spec, goal)
    if (goal == "testing") stopifnot(spec_power(spec, n) >= .8, spec_power(spec, n-1) < .8)
    else stopifnot(anticipated_width(spec, n) <= spec$width_target,
                  anticipated_width(spec, n-1) > spec$width_target)
  }
  message("Simulation reference, null, coverage, rounding, seed and edge checks passed.")
  invisible(TRUE)
}

check_lab_server <- function() {
  old <- getwd(); on.exit(setwd(old)); setwd("apps/power_explorer")
  app <- new.env(parent = globalenv()); sys.source("app.R", envir = app)
  button <- app$downloadButton("check_download", "Download")
  stopifnot(is.null(button$attribs$download), identical(button$attribs$target, "_self"))
  shiny::testServer(app$server, {
    session$setInputs(outcome = "means", goal = "testing", plan_delta = 3, plan_sd = 5,
      threshold_m = 2, width_m = 4, plan_p0 = .3, plan_p1 = .6, threshold_p = .3, width_p = .2,
      alpha = .05, target_power = .8, fixed_n = 60, dropout = .1, reality = "same",
      true_delta = 1, true_sd = 7, true_p0 = .3, true_p1 = .4, seed = 20260914, B = 1000,
      run_one = 0, run_many = 0, recruit_cap = 200, justification = "A hypothetical test plan")
    stopifnot(planned()$n == 45)
    stopifnot(comparison()$cap_n == 90,
      identical(comparison()$effects, c(1.5, 2, 3)))
    stopifnot(!is.null(output$comparison_plot), !is.null(output$effect_plot))
    session$setInputs(run_one = 1, run_many = 1)
    stopifnot(nrow(one()$data) == 90, nrow(many()$results) == 1000)
    stopifnot(!is.null(output$p_values))
    saved <- many(); session$setInputs(reality = "null")
    stopifnot(planned()$n == 45, generating()$delta == 0, identical(saved, many()))
    stopifnot(grepl("Inputs changed", output$many_status))
    session$setInputs(run_many = 2); stopifnot(many()$spec$delta == 0)
    session$setInputs(goal = "fixed", fixed_n = 80, reality = "custom")
    stopifnot(planned()$n == 80, generating()$sd == 7)
    session$setInputs(outcome = "proportions", goal = "precision", reality = "same")
    stopifnot(anticipated_width(planned()) <= .2)
    stopifnot(max(abs(comparison()$effects - c(.15,.20,.30))) < 1e-12,
      !is.null(output$comparison_plot), !is.null(output$effect_plot))
    session$setInputs(run_one = 2, run_many = 3)
    stopifnot(nrow(one()$data) == 2 * planned()$n, all(one()$data$outcome %in% 0:1))
    stopifnot(nrow(many()$results) == 1000)
    exported <- export_rows(many()$results, many()$meta)
    stopifnot(all(c("plan_n", "generating_seed", "planning_goal", "method") %in% names(exported)))
    session$setInputs(goal = "testing", plan_p1 = .3, plan_p0 = .3)
    stopifnot(inherits(tryCatch(planned(), error = identity), "error"))
  })
  message("Shiny server goal, outcome, simulation, stale-state and export checks passed.")
}

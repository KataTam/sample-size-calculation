# Numerical reference and server checks for the added precision/error activities.
check_feedback_methods <- function() {
  source("R/sample_size_functions.R", local = TRUE)
  source("R/teaching_cases.R", local = TRUE)
  expect_error <- function(code) stopifnot(inherits(tryCatch({ force(code); NULL }, error = identity), "error"))
  x <- proportion_precision_plan(.20, .10, .95)
  conservative <- proportion_precision_plan(.20, .10, .95, unknown_p = TRUE)
  stopifnot(x$n == 246, conservative$n == 385, conservative$planning_p == .50,
    x$half_width == .05, x$recruitment_n == 246,
    proportion_precision_plan(.20, .10, .95, dropout_rate = .15)$recruitment_n == 290)
  # Independent inversion of the normal half-width criterion checks upward rounding.
  half <- function(n, p) stats::qnorm(.975) * sqrt(p*(1-p)/n)
  stopifnot(half(x$n, .20) <= .05, half(x$n-1, .20) > .05)
  narrow <- proportion_precision_plan(.20, .05, .95)
  stopifnot(abs(narrow$raw_n / x$raw_n - 4) < 1e-12)
  p_grid <- seq(.01,.99,.01)
  ns <- vapply(p_grid, function(p) proportion_precision_plan(p)$raw_n, numeric(1))
  stopifnot(which.max(ns) == 50, max(abs(ns - rev(ns))) < 1e-10)
  stopifnot(proportion_precision_plan(.001, .10)$sparse)
  expect_error(proportion_precision_plan(0)); expect_error(proportion_precision_plan(1))
  expect_error(proportion_precision_plan(.2, full_width = 0))
  expect_error(proportion_precision_plan(.2, confidence = 1))
  expect_error(proportion_precision_plan(.2, unknown_p = NA))
  stopifnot(proportion_precision_plan(0, unknown_p = TRUE)$n == 385)

  # prop.test's uncorrected one-proportion score interval is an independent
  # reference for the Wilson calculation, including all-failure/all-success data.
  for (events in c(0, 1, 19, 49, 245, 246)) {
    r <- single_proportion_interval(events, 246)
    ref <- stats::prop.test(events, 246, correct = FALSE)$conf.int
    stopifnot(max(abs(c(r$lower,r$upper)-ref)) < 1e-12,
      r$lower >= 0, r$upper <= 1, r$lower <= r$estimate, r$upper >= r$estimate)
  }
  expect_error(single_proportion_interval(41,40))
  expect_error(single_proportion_interval(4.5,40))
  # Enumeration establishes that realised width varies and the target is not
  # a guaranteed-width statement.
  intervals <- do.call(rbind,lapply(0:x$n, single_proportion_interval,n=x$n))
  mass <- stats::dbinom(0:x$n,x$n,.20)
  coverage <- sum(mass * (intervals$lower <= .20 & intervals$upper >= .20))
  width_rate <- sum(mass * (intervals$full_width <= .10))
  stopifnot(coverage > .93, coverage < .97, width_rate > 0, width_rate < 1)
  set.seed(93); old_seed <- .Random.seed
  a <- simulate_proportion_study(246,.20,seed=20260942)
  stopifnot(identical(old_seed,.Random.seed),
    identical(a,simulate_proportion_study(246,.20,seed=20260942)))
  stopifnot(simulate_proportion_study(10,0)$result$events == 0,
    simulate_proportion_study(10,1)$result$events == 10)

  # Numerical integration of density over rejection verifies power without
  # reusing the helper's pnorm formula.
  for (direction in c("greater","less","two.sided")) {
    s <- normal_sampling_operating_characteristics(sidedness=direction)
    tail_mass <- function(mean) {
      low <- if (is.finite(s$lower)) integrate(function(z) dnorm(z,mean,s$se),-Inf,s$lower)$value else 0
      high <- if (is.finite(s$upper)) integrate(function(z) dnorm(z,mean,s$se),s$upper,Inf)$value else 0
      low+high
    }
    stopifnot(abs(s$power-tail_mass(s$mu1)) < 1e-8,
      abs(s$type1-tail_mass(s$mu0)) < 1e-8,
      abs(s$power+s$beta-1) < 1e-12)
    null <- normal_sampling_operating_characteristics(mu1=120,sidedness=direction)
    stopifnot(abs(null$power-.05) < 1e-12)
  }
  s <- normal_sampling_operating_characteristics()
  stopifnot(s$se == 3, abs(s$critical-124.934560880854) < 1e-10,
    abs(s$power-.508701453763092) < 1e-10)
  stopifnot(normal_sampling_operating_characteristics(n=100)$power > s$power,
    normal_sampling_operating_characteristics(mu1=115)$power < .05)
  expect_error(normal_sampling_operating_characteristics(n=0))
  expect_error(normal_sampling_operating_characteristics(sigma=0))
  expect_error(normal_sampling_operating_characteristics(sidedness="post-hoc"))

  cases <- teaching_cases()
  required <- c("pain_one_many","pain_curves","pain_simulation","mean_precision",
    "own_study","rehabilitation","discharge","adherence","prevalence","pilot_feasibility","alpha_beta")
  stopifnot(setequal(names(cases),required), !anyDuplicated(names(cases)))
  for (id in names(cases)) {
    z <- teaching_case(id)
    stopifnot(identical(z$id,id),
      all(c("id","title","prompt","return_path","app","outcome","goal","inputs") %in% names(z)),
      !is.null(names(z$inputs)), grepl("^book/Sample_size_open_module.html#",z$return_path))
    if (z$app == "power_explorer") {
      spec <- teaching_case_spec(id)
      stopifnot(spec$outcome == z$outcome,spec$seed == z$inputs$seed,
        spec$n == z$inputs$fixed_n,spec$B == z$inputs$B)
    }
  }
  expect_error(teaching_case("unknown"))
  expect_error(teaching_case_spec("prevalence"))
  message(sprintf("Feedback numerical checks passed: enumerated Wilson coverage %.4f; width attainment %.4f.",coverage,width_rate))
  invisible(TRUE)
}

check_feedback_servers <- function() {
  root <- getwd(); on.exit(setwd(root))
  setwd(file.path(root,"apps/prevalence_precision"))
  app <- new.env(parent=globalenv()); sys.source("app.R",envir=app)
  shiny::testServer(app$server, {
    do.call(session$setInputs,app$precision_defaults())
    session$setInputs(simulate=0,case_id="prevalence",justification="A hypothetical survey.")
    stopifnot(plan()$n == 246,analysable_n() == 246,
      !is.null(output$plan_table),!is.null(output$sample_plot))
    session$setInputs(unknown_p=TRUE)
    stopifnot(plan()$n == 385,plan()$planning_p == .5)
    session$setInputs(simulate=1)
    saved <- study(); stopifnot(saved$n == 385,!is.null(output$study_table),!is.null(output$interval_plot))
    session$setInputs(anticipated_p=.8,goal="fixed",fixed_n=40,full_width=.20,unknown_p=FALSE)
    stopifnot(analysable_n() == 40,identical(saved,study()),
      grepl("Inputs changed",output$saved_status))
    session$setInputs(simulate=2)
    stopifnot(study()$n == 40,study()$p == .8)
    session$setInputs(activity_request=list(activity="pilot_feasibility",nonce=1))
    stopifnot(active_case() == "pilot_feasibility",grepl("Pilot",output$case_title))
    session$setInputs(activity_request=list(activity="pain_curves",nonce=2))
    stopifnot(grepl("different activity",output$bridge_status))
    session$setInputs(state_request=list(state=list(goal="fixed",fixed_n=40),nonce=3))
    stopifnot(grepl("Restored",output$bridge_status))
    session$setInputs(state_request=list(state=list(unsupported=1),nonce=4))
    stopifnot(grepl("Unsupported",output$bridge_status))
    session$setInputs(state_request=list(state=list(goal="fixed",fixed_n=40,case_id="pilot_feasibility"),nonce=5))
    stopifnot(active_case() == "pilot_feasibility",grepl("Restored",output$bridge_status))
    session$setInputs(state_request=list(state=list(full_width=-1,case_id="prevalence"),nonce=6))
    stopifnot(active_case() == "pilot_feasibility",grepl("Invalid",output$bridge_status))
    session$setInputs(anticipated_p=.001)
    stopifnot(grepl("Few expected",output$approximation_note))
  })
  setwd(file.path(root,"apps/sampling_distributions"))
  app <- new.env(parent=globalenv()); sys.source("app.R",envir=app)
  shiny::testServer(app$server, {
    do.call(session$setInputs,app$sampling_defaults())
    session$setInputs(effect=5)
    session$setInputs(interpretation="A hypothetical known-SD reference.")
    stopifnot(abs(operating()$power-.508701453763092) < 1e-10,
      !is.null(output$distributions),!is.null(output$operating_table),!is.null(output$power_curve))
    session$setInputs(effect=0)
    stopifnot(abs(operating()$power-.05) < 1e-12)
    session$setInputs(sidedness="two.sided")
    stopifnot(length(operating()$critical) == 2,abs(operating()$power-.05) < 1e-12)
    session$setInputs(activity_request=list(activity="alpha_beta",nonce=1))
    stopifnot(grepl("Loaded",output$bridge_status))
    session$setInputs(state_request=list(state=list(mu0=120,mu1=125,sigma=15,n=25,alpha=.05,sidedness="less"),nonce=2))
    stopifnot(grepl("Restored",output$bridge_status))
    session$setInputs(state_request=list(state=list(alpha=0),nonce=3))
    stopifnot(grepl("Invalid",output$bridge_status))
  })
  message("Feedback Shiny checks passed: precision, fixed n, shared cases, input validation, saved results and error regions.")
  invisible(TRUE)
}

if (identical(environment(),globalenv())) {
  check_feedback_methods()
  check_feedback_servers()
}
